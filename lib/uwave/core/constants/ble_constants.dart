/// Konstanta BLE untuk U-WAVE-T Mitutoyo
class BleConstants {
  BleConstants._();

  /// Nama device yang akan di-filter saat scanning
  static const String deviceName = 'UWAVE';

  /// Service UUID U-WAVE-T (perlu dikonfirmasi via nRF Connect)
  static const String serviceUuid = '7eafd361-f150-4785-b307-47d34ed52c3c';

  /// Characteristic UUID — NOTIFY (data pengukuran)
  static const String characteristicUuid =
      '7eafd361-f151-4785-b307-47d34ed52c3c';

  /// Timeout scan BLE dalam detik
  static const int scanTimeoutSeconds = 10;

  /// Timeout koneksi dalam detik
  static const int connectTimeoutSeconds = 15;

  /// Interval auto-reconnect dalam detik
  static const int reconnectDelaySeconds = 3;
}
