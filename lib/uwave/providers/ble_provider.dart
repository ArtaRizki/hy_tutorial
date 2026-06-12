import 'dart:async';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../core/constants/ble_constants.dart';
import '../core/utils/ble_decoder.dart';
import '../data/models/diagnostic_log_model.dart';
import '../../common/helper/xenolog.dart';

enum BleState { idle, scanning, connecting, connected, disconnected, error }

/// Provider yang mengelola seluruh lifecycle BLE:
/// scan → connect → subscribe ke SEMUA NOTIFY characteristics → diagnostic logs → write commands
class BleProvider extends ChangeNotifier {
  BleState _bleState = BleState.idle;
  List<ScanResult> _scanResults = [];
  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _notifyChar;
  double? _currentValue;
  String _currentUnit = 'mm';
  String? _errorMessage;

  final List<BleDiagnosticLog> _diagnosticLogs = [];
  StreamSubscription<List<ScanResult>>? _scanSub;
  StreamSubscription<BluetoothConnectionState>? _connStateSub;
  final List<StreamSubscription<List<int>>> _notifySubs = [];
  Timer? _reconnectTimer;

  // ── Getters ────────────────────────────────────────────────────
  BleState get bleState => _bleState;
  List<ScanResult> get scanResults => _scanResults;
  BluetoothDevice? get connectedDevice => _connectedDevice;
  BluetoothCharacteristic? get notifyChar => _notifyChar;
  double? get currentValue => _currentValue;
  String get currentUnit => _currentUnit;
  String? get errorMessage => _errorMessage;
  bool get isConnected => _bleState == BleState.connected;
  bool get isScanning => _bleState == BleState.scanning;
  List<BleDiagnosticLog> get diagnosticLogs => _diagnosticLogs;

  // ── Clear Logs ─────────────────────────────────────────────────
  void clearDiagnosticLogs() {
    _diagnosticLogs.clear();
    notifyListeners();
  }

  // ── Scan ───────────────────────────────────────────────────────
  Future<void> startScan() async {
    if (_bleState == BleState.scanning) return;
    _scanResults = [];
    _setState(BleState.scanning);
    _errorMessage = null;

    try {
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: BleConstants.scanTimeoutSeconds),
        withKeywords: [BleConstants.deviceName],
      );

      _scanSub = FlutterBluePlus.scanResults.listen((results) {
        _scanResults = results;
        notifyListeners();
      });

      await Future.delayed(
          const Duration(seconds: BleConstants.scanTimeoutSeconds + 1));
      _setState(BleState.idle);
    } catch (e) {
      log('[BLE] scan error: $e');
      _errorMessage = e.toString();
      _setState(BleState.error);
    }
  }

  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
    await _scanSub?.cancel();
    _scanSub = null;
    if (_bleState == BleState.scanning) _setState(BleState.idle);
  }

  // ── Connect ────────────────────────────────────────────────────
  Future<void> connectTo(BluetoothDevice device) async {
    await stopScan();
    _setState(BleState.connecting);
    _errorMessage = null;
    _connectedDevice = device;

    try {
      await device.connect(
        timeout: const Duration(seconds: BleConstants.connectTimeoutSeconds),
        autoConnect: false,
      );
      _listenConnectionState(device);
      await _discoverAndSubscribe(device);
    } catch (e) {
      log('[BLE] connect error: $e');
      _errorMessage = e.toString();
      _setState(BleState.error);
      _scheduleReconnect(device);
    }
  }

  void _listenConnectionState(BluetoothDevice device) {
    _connStateSub?.cancel();
    _connStateSub = device.connectionState.listen((state) async {
      log('[BLE] connection state: $state');
      if (state == BluetoothConnectionState.disconnected) {
        _setState(BleState.disconnected);
        for (final sub in _notifySubs) {
          await sub.cancel();
        }
        _notifySubs.clear();
        _scheduleReconnect(device);
      }
    });
  }

  Future<void> _discoverAndSubscribe(BluetoothDevice device) async {
    final services = await device.discoverServices();
    
    // Clear previous notify subscriptions
    for (final sub in _notifySubs) {
      await sub.cancel();
    }
    _notifySubs.clear();

    for (final svc in services) {
      // Periksa apakah ini Service U-WAVE
      if (svc.serviceUuid.toString().toLowerCase() == BleConstants.serviceUuid.toLowerCase()) {
        log('[BLE] Found U-WAVE service ${svc.serviceUuid}');
        
        for (final char in svc.characteristics) {
          final uuid = char.characteristicUuid.toString().toLowerCase();
          
          // Subscribe ke semua Notify Characteristics (-f151, -f152, -f153)
          if (uuid.contains(BleConstants.notify1.toLowerCase()) ||
              uuid.contains(BleConstants.notify2.toLowerCase()) ||
              uuid.contains(BleConstants.notify3.toLowerCase())) {
            
            await char.setNotifyValue(true);
            final sub = char.lastValueStream.listen((bytes) {
              _onNotifyFromChar(device, char.characteristicUuid.toString(), bytes);
            });
            _notifySubs.add(sub);
            log('[BLE] Subscribed to: $uuid');
          }
        }
        _setState(BleState.connected);
        return;
      }
    }

    // Fallback jika Service UUID tidak cocok
    log('[BLE] U-WAVE service not found, trying fallback for any notify char');
    for (final svc in services) {
      for (final char in svc.characteristics) {
        if (char.properties.notify) {
          _notifyChar = char;
          await char.setNotifyValue(true);
          final sub = char.lastValueStream.listen(_onNotify);
          _notifySubs.add(sub);
          log('[BLE] Fallback subscribed to: ${char.characteristicUuid}');
          _setState(BleState.connected);
          return;
        }
      }
    }
  }

  void _onNotify(List<int> bytes) {
    if (bytes.isEmpty) return;
    final value = BleDecoder.decode(bytes);
    final unit = BleDecoder.extractUnit(bytes);
    log('[BLE] notify → bytes=$bytes value=$value unit=$unit');
    
    try {
      XenoLog('uwave_tester').save('[BLE] notify -> bytes=$bytes value=$value unit=$unit');
    } catch (_) {}

    if (value != null) {
      _currentValue = value;
      _currentUnit = unit;
      notifyListeners();
    }
  }

  void _onNotifyFromChar(BluetoothDevice device, String charUuid, List<int> bytes) {
    if (bytes.isEmpty) return;

    // Catat ke logs diagnostik
    final newLog = BleDiagnosticLog(
      timestamp: DateTime.now(),
      deviceName: device.platformName,
      deviceId: device.remoteId.toString(),
      characteristicUuid: charUuid,
      bytes: bytes,
    );

    _diagnosticLogs.add(newLog);
    if (_diagnosticLogs.length > 500) {
      _diagnosticLogs.removeAt(0);
    }

    log('[BLE] Notify UUID: $charUuid -> bytes=$bytes HEX=${newLog.hex} ASCII=${newLog.ascii}');

    // Integrasi dengan XenoLog milik Alifano
    try {
      XenoLog('uwave_tester').save('[BLE] notify -> UUID: ...${charUuid.substring(charUuid.length - 4)} bytes=$bytes HEX=${newLog.hex}');
    } catch (_) {}

    // Parse nilai jika data berupa decimal measurement yang valid
    final value = BleDecoder.decode(bytes);
    final unit = BleDecoder.extractUnit(bytes);
    if (value != null) {
      _currentValue = value;
      _currentUnit = unit;
    }

    notifyListeners();
  }

  // ── Write Command ──────────────────────────────────────────────
  /// Kirim bytes trigger ke write characteristic U-WAVE
  Future<void> writeCommand(String charUuid, List<int> bytes) async {
    if (_connectedDevice == null) {
      log('[BLE] writeCommand error: device not connected');
      return;
    }

    try {
      final services = await _connectedDevice!.discoverServices();
      for (final svc in services) {
        for (final char in svc.characteristics) {
          if (char.characteristicUuid.toString().toLowerCase() == charUuid.toLowerCase()) {
            await char.write(bytes, withoutResponse: false);
            log('[BLE] writeCommand success: wrote $bytes to $charUuid');

            // Log ke diagnostics console
            final writeLog = BleDiagnosticLog(
              timestamp: DateTime.now(),
              deviceName: _connectedDevice!.platformName,
              deviceId: _connectedDevice!.remoteId.toString(),
              characteristicUuid: '$charUuid (WRITE)',
              bytes: bytes,
            );
            _diagnosticLogs.add(writeLog);
            if (_diagnosticLogs.length > 500) {
              _diagnosticLogs.removeAt(0);
            }

            try {
              XenoLog('uwave_tester').save('[BLE] write -> wrote $bytes to ...${charUuid.substring(charUuid.length - 4)}');
            } catch (_) {}

            notifyListeners();
            return;
          }
        }
      }
      log('[BLE] writeCommand error: char $charUuid tidak ditemukan');
    } catch (e) {
      log('[BLE] writeCommand error: $e');
      _errorMessage = 'Write failed: $e';
      notifyListeners();
    }
  }

  // ── Disconnect ─────────────────────────────────────────────────
  Future<void> disconnect() async {
    _reconnectTimer?.cancel();
    for (final sub in _notifySubs) {
      await sub.cancel();
    }
    _notifySubs.clear();
    await _connStateSub?.cancel();
    await _connectedDevice?.disconnect();
    _connectedDevice = null;
    _notifyChar = null;
    _currentValue = null;
    _setState(BleState.idle);
  }

  // ── Auto-reconnect ─────────────────────────────────────────────
  void _scheduleReconnect(BluetoothDevice device) {
    _reconnectTimer?.cancel();
    _reconnectTimer =
        Timer(const Duration(seconds: BleConstants.reconnectDelaySeconds), () {
      log('[BLE] attempting auto-reconnect...');
      connectTo(device);
    });
  }

  // ── State Helper ───────────────────────────────────────────────
  void _setState(BleState state) {
    _bleState = state;
    notifyListeners();
  }

  @override
  void dispose() {
    _reconnectTimer?.cancel();
    _scanSub?.cancel();
    _connStateSub?.cancel();
    for (final sub in _notifySubs) {
      sub.cancel();
    }
    super.dispose();
  }
}
