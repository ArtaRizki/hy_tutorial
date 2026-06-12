import 'package:intl/intl.dart';

/// Model untuk mencatat logs payload data raw dari BLE U-WAVE
class BleDiagnosticLog {
  final DateTime timestamp;
  final String deviceName;
  final String deviceId;
  final String characteristicUuid;
  final List<int> bytes;

  BleDiagnosticLog({
    required this.timestamp,
    required this.deviceName,
    required this.deviceId,
    required this.characteristicUuid,
    required this.bytes,
  });

  String get timeStr => DateFormat('HH:mm:ss.SSS').format(timestamp);

  String get hex => bytes
      .map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase())
      .join(' ');

  String get ascii {
    return String.fromCharCodes(
      bytes.map((b) => (b >= 32 && b < 127) ? b : 46), // . jika non-printable
    );
  }

  String get formatForLogging {
    return '[$timeStr] UUID: ...${characteristicUuid.substring(Math.max(0, characteristicUuid.length - 4))} | Bytes: $bytes | HEX: $hex | ASCII: $ascii';
  }
}

class Math {
  static int max(int a, int b) => a > b ? a : b;
}
