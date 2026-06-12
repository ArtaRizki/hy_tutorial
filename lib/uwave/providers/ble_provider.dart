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
  BluetoothCharacteristic? _notifyChar;
  double? _currentValue;
  String _currentUnit = 'mm';
  String? _errorMessage;

  StreamSubscription<List<ScanResult>>? _scanSub;
  StreamSubscription<BluetoothConnectionState>? _connStateSub;
  StreamSubscription<List<int>>? _notifySub;
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
        _notifySub?.cancel();
        _scheduleReconnect(device);
      }
    });
  }

  Future<void> _discoverAndSubscribe(BluetoothDevice device) async {
    final services = await device.discoverServices();
    for (final svc in services) {
      for (final char in svc.characteristics) {
        final charUuid = char.characteristicUuid.toString().toLowerCase();
        if (charUuid.contains(BleConstants.characteristicUuid.toLowerCase()) ||
            char.properties.notify) {
          _notifyChar = char;
          await char.setNotifyValue(true);
          _notifySub = char.lastValueStream.listen(_onNotify);
          log('[BLE] subscribed to char ${char.characteristicUuid}');
          _setState(BleState.connected);
          return;
        }
      }
    }
    // Fallback: jika UUID tidak cocok, coba characteristic NOTIFY pertama
    log('[BLE] WARN: characteristic UUID tidak ditemukan, coba fallback');
    _setState(BleState.connected);
  }

  void _onNotify(List<int> bytes) {
    if (bytes.isEmpty) return;
    final value = BleDecoder.decode(bytes);
    final unit = BleDecoder.extractUnit(bytes);
    log('[BLE] notify → bytes=$bytes value=$value unit=$unit');
    _hylog.save('[BLE] notify → bytes=$bytes value=$value unit=$unit');
    if (value != null) {
      _currentValue = value;
      _currentUnit = unit;
      notifyListeners();
    }
  }

  // ── Disconnect ─────────────────────────────────────────────────

  Future<void> disconnect() async {
    _hylog.save('[BLE] disconnect: User requested disconnect from ${_connectedDevice?.platformName}');
    _reconnectTimer?.cancel();
    await _notifySub?.cancel();
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
    _notifySub?.cancel();
    super.dispose();
  }
}
