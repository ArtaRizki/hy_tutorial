import 'dart:async';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../core/constants/ble_constants.dart';
import '../core/utils/ble_decoder.dart';
import '../../common/helper/hylog.dart';

enum BleState { idle, scanning, connecting, connected, disconnected, error }

/// Provider yang mengelola seluruh lifecycle BLE:
/// scan → connect → subscribe NOTIFY → stream nilai → auto-reconnect
class BleProvider extends ChangeNotifier {
  final HYLog _hylog = HYLog("uwave_tester");
  BleState _bleState = BleState.idle;
  List<ScanResult> _scanResults = [];
  BluetoothDevice? _connectedDevice;
  final List<BluetoothCharacteristic> _subscribedCharacteristics = [];
  double? _currentValue;
  String _currentUnit = 'mm';
  String? _errorMessage;

  List<Map<String, double>> _calibrationTable = [];

  StreamSubscription<List<ScanResult>>? _scanSub;
  StreamSubscription<BluetoothConnectionState>? _connStateSub;
  final List<StreamSubscription<List<int>>> _notifySubs = [];
  Timer? _reconnectTimer;

  // ── Getters ────────────────────────────────────────────────────
  BleState get bleState => _bleState;
  List<ScanResult> get scanResults => _scanResults;
  BluetoothDevice? get connectedDevice => _connectedDevice;
  BluetoothCharacteristic? get notifyChar => _subscribedCharacteristics.isNotEmpty ? _subscribedCharacteristics.first : null;
  double? get currentValue => _currentValue;
  // Expose the raw ADC value for calibration purpose
  double? get currentRawValue => _currentRawValue;
  double? _currentRawValue;

  String get currentUnit => _currentUnit;
  String? get errorMessage => _errorMessage;
  bool get isConnected => _bleState == BleState.connected;
  bool get isScanning => _bleState == BleState.scanning;

  void updateCalibrationTable(List<Map<String, double>> table) {
    _calibrationTable = table;
    // We could recalculate current value here if needed, but the next notification will fix it.
  }


  // ── Scan ───────────────────────────────────────────────────────

  Future<void> startScan() async {
    if (_bleState == BleState.scanning) return;
    _scanResults = [];
    _setState(BleState.scanning);
    _errorMessage = null;
    _hylog.save('[BLE] startScan: Scanning started');

    try {
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: BleConstants.scanTimeoutSeconds),
        withKeywords: [BleConstants.deviceName],
      );

      _scanSub = FlutterBluePlus.scanResults.listen((results) {
        _scanResults = results;
        _hylog.save('[BLE] scanResults found: ${results.map((r) => "${r.device.platformName} (${r.device.remoteId})").toList()}');
        notifyListeners();
      });

      await Future.delayed(
          const Duration(seconds: BleConstants.scanTimeoutSeconds + 1));
      _setState(BleState.idle);
    } catch (e) {
      log('[BLE] scan error: $e');
      _hylog.save('[BLE] scan error: $e');
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
    _hylog.save('[BLE] connectTo: Attempting to connect to ${device.platformName} (${device.remoteId})');

    try {
      await device.connect(
        timeout: const Duration(seconds: BleConstants.connectTimeoutSeconds),
        autoConnect: false,
      );
      _listenConnectionState(device);
      await _discoverAndSubscribe(device);
      _hylog.save('[BLE] connectTo: Connection and subscription successful for ${device.platformName}');
    } catch (e) {
      log('[BLE] connect error: $e');
      _hylog.save('[BLE] connect error for ${device.platformName}: $e');
      _errorMessage = e.toString();
      _setState(BleState.error);
      _scheduleReconnect(device);
    }
  }

  void _listenConnectionState(BluetoothDevice device) {
    _connStateSub?.cancel();
    _connStateSub = device.connectionState.listen((state) {
      log('[BLE] connection state: $state');
      _hylog.save('[BLE] connection state for ${device.platformName}: $state');
      if (state == BluetoothConnectionState.disconnected) {
        _setState(BleState.disconnected);
        for (final sub in _notifySubs) {
          sub.cancel();
        }
        _notifySubs.clear();
        _subscribedCharacteristics.clear();
        _scheduleReconnect(device);
      }
    });
  }

  Future<void> _discoverAndSubscribe(BluetoothDevice device) async {
    final services = await device.discoverServices();
    
    // Bersihkan subscription sebelumnya jika ada
    for (final sub in _notifySubs) {
      await sub.cancel();
    }
    _notifySubs.clear();
    _subscribedCharacteristics.clear();

    bool subscribedAny = false;

    for (final svc in services) {
      final svcUuid = svc.serviceUuid.toString().toLowerCase();
      if (svcUuid == BleConstants.serviceUuid.toLowerCase()) {
        for (final char in svc.characteristics) {
          final charUuid = char.characteristicUuid.toString().toLowerCase();
          if (BleConstants.notifyUuids.any((uuid) => charUuid == uuid.toLowerCase())) {
            try {
              await char.setNotifyValue(true);
              final sub = char.lastValueStream.listen((bytes) => _onNotify(charUuid, bytes));
              _notifySubs.add(sub);
              _subscribedCharacteristics.add(char);
              subscribedAny = true;
              log('[BLE] subscribed to U-WAVE char $charUuid');
              _hylog.save('[BLE] subscribed to U-WAVE char $charUuid');
            } catch (e) {
              log('[BLE] failed to subscribe to $charUuid: $e');
              _hylog.save('[BLE] failed to subscribe to $charUuid: $e');
            }
          }
        }
      }
    }

    if (subscribedAny) {
      _setState(BleState.connected);
    } else {
      // Fallback: jika service U-WAVE tidak ditemukan, cari characteristic notify pertama yang tersedia
      log('[BLE] WARN: U-WAVE service/characteristics tidak ditemukan, coba fallback ke any notify');
      _hylog.save('[BLE] WARN: U-WAVE service/characteristics tidak ditemukan, coba fallback');
      for (final svc in services) {
        for (final char in svc.characteristics) {
          if (char.properties.notify) {
            final charUuid = char.characteristicUuid.toString().toLowerCase();
            try {
              await char.setNotifyValue(true);
              final sub = char.lastValueStream.listen((bytes) => _onNotify(charUuid, bytes));
              _notifySubs.add(sub);
              _subscribedCharacteristics.add(char);
              subscribedAny = true;
              log('[BLE] subscribed to fallback notify char $charUuid');
              _hylog.save('[BLE] subscribed to fallback notify char $charUuid');
              _setState(BleState.connected);
              return;
            } catch (e) {
              log('[BLE] failed to subscribe to fallback char $charUuid: $e');
            }
          }
        }
      }
      _setState(BleState.connected);
    }
  }

  void _onNotify(String charUuid, List<int> bytes) {
    if (bytes.isEmpty) return;

    // Format byte ke HEX
    final hexString = bytes.map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase()).join(' ');

    // Format byte ke ASCII printable representation
    final asciiString = bytes.map((b) {
      if (b >= 32 && b <= 126) {
        return String.fromCharCode(b);
      } else if (b == 10) {
        return r'\n';
      } else if (b == 13) {
        return r'\r';
      } else if (b == 9) {
        return r'\t';
      } else {
        return '\\x${b.toRadixString(16).padLeft(2, '0')}';
      }
    }).join('');

    final timestamp = DateTime.now().toIso8601String();

    // Log detail format: Timestamp | Characteristic UUID | Raw Bytes | HEX | ASCII
    final logMessage = '[BLE_DATA] Timestamp: $timestamp | UUID: $charUuid | Raw: $bytes | HEX: $hexString | ASCII: $asciiString';
    log(logMessage);
    _hylog.save(logMessage);

    final value = BleDecoder.decode(bytes, calibrationTable: _calibrationTable);
    final rawValue = BleDecoder.extractRawValue(bytes);
    final unit = BleDecoder.extractUnit(bytes);
    log('[BLE] parsed value: $value $unit (Raw: $rawValue)');

    if (value != null) {
      _currentValue = value;
      _currentRawValue = rawValue;
      _currentUnit = unit;
      notifyListeners();
    }
  }

  // ── Disconnect ─────────────────────────────────────────────────

  Future<void> disconnect() async {
    _hylog.save('[BLE] disconnect: User requested disconnect from ${_connectedDevice?.platformName}');
    _reconnectTimer?.cancel();
    for (final sub in _notifySubs) {
      await sub.cancel();
    }
    _notifySubs.clear();
    _subscribedCharacteristics.clear();
    await _connStateSub?.cancel();
    await _connectedDevice?.disconnect();
    _connectedDevice = null;
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
    _notifySubs.clear();
    _subscribedCharacteristics.clear();
    super.dispose();
  }
}
