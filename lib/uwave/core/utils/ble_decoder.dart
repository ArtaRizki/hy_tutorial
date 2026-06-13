import 'dart:developer';
import 'dart:math' as math;

/// Decoder untuk raw bytes dari Mitutoyo U-WAVE-T BLE notification.
class BleDecoder {
  BleDecoder._();

  /// Decode bytes BLE notification menjadi nilai double (mm atau inch).
  /// Mendukung Custom Binary Protocol & Fallback ASCII.
  static double? decode(List<int> bytes) {
    if (bytes.isEmpty) return null;

    // 1. Cek Custom Binary Protocol Mitutoyo
    // Format: [16, Seq, Status/Decimal, LSB, MSB, Reserved, Reserved]
    if (bytes.length >= 5 && bytes[0] == 0x10) {
      try {
        int rawValue = (bytes[4] << 8) | bytes[3];
        // Konversi ke signed 16-bit integer (Two's complement)
        if (rawValue > 32767) {
          rawValue -= 65536;
        }

        // Byte 2 (Status): 4 bit terbawah biasanya menunjukkan jumlah angka desimal
        int decimalPlaces = bytes[2] & 0x0F;
        double divisor = math.pow(10, decimalPlaces).toDouble();

        double value = rawValue / divisor;
        log('[BleDecoder] binary parsed: raw=$rawValue, dec=$decimalPlaces -> $value');
        return value;
      } catch (e) {
        log('[BleDecoder] binary parse error: $e');
      }
    }

    // 2. Fallback: Parse sebagai ASCII String
    try {
      // Hapus byte non-printable (header, terminator)
      final filtered = bytes.where((b) => b >= 0x20 && b < 0x7F).toList();
      final raw = String.fromCharCodes(filtered).trim();
      log('[BleDecoder] ascii raw string: "$raw"');

      // Cek apakah ada tanda negatif '-' di dalam string
      final bool isNegative = raw.contains('-');

      // Ambil hanya karakter numerik dan titik desimal
      final numStr = raw.replaceAll(RegExp(r'[^\d.]'), '').trim();
      if (numStr.isEmpty) return null;

      final parsed = double.tryParse(numStr);
      if (parsed == null) return null;

      return isNegative ? -parsed : parsed;
    } catch (e) {
      log('[BleDecoder] ascii error: $e');
      return null;
    }
  }

  /// Ekstrak satuan dari bytes: 'mm' atau 'inch'
  static String extractUnit(List<int> bytes) {
    // Pada binary protocol, sementara asumsikan 'mm'
    if (bytes.isNotEmpty && bytes[0] == 0x10) {
      return 'mm';
    }

    // Pada ASCII protocol, cek keberadaan teks 'in'
    final raw = String.fromCharCodes(
      bytes.where((b) => b >= 0x20 && b < 0x7F).toList(),
    );
    if (raw.toLowerCase().contains('in')) return 'inch';
    return 'mm';
  }
}
