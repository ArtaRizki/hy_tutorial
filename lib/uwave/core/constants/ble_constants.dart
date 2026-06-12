/// Konstanta BLE untuk U-WAVE-T Mitutoyo
class BleConstants {
  BleConstants._();

  /// Nama device yang akan di-filter saat scanning
  static const String deviceName = 'UWAVE';

  /// Service UUID U-WAVE-T
  static const String serviceUuid = '7eafd361-f150-4785-b307-47d34ed52c3c';

  /// Characteristic UUIDs — NOTIFY (perekaman data / status)
  static const String notify1 = '7eafd361-f151-4785-b307-47d34ed52c3c';
  static const String notify2 = '7eafd361-f152-4785-b307-47d34ed52c3c';
  static const String notify3 = '7eafd361-f153-4785-b307-47d34ed52c3c';

  /// Characteristic UUIDs — WRITE (pengiriman trigger / command)
  static const String write1 = '7eafd361-f154-4785-b307-47d34ed52c3c';
  static const String write2 = '7eafd361-f155-4785-b307-47d34ed52c3c';

  /// Timeout scan BLE dalam detik
  static const int scanTimeoutSeconds = 15;

  /// Timeout koneksi dalam detik
  static const int connectTimeoutSeconds = 15;

  /// Interval auto-reconnect dalam detik
  static const int reconnectDelaySeconds = 3;
}
