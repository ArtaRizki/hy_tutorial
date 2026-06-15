import 'dart:developer';
import 'dart:math' as math;

/// Decoder untuk raw bytes dari Mitutoyo U-WAVE-T BLE notification.
class BleDecoder {
  BleDecoder._();

  /// Interpolasi linear (Lerp) untuk mengonversi raw ADC ke nilai ukur (mm)
  static double _interpolate(double rawValue, List<Map<String, double>> calibrationTable) {
    if (calibrationTable.isEmpty) return rawValue;

    // Cari segmen garis yang sesuai (extrapolate jika di luar rentang)
    int index = 0;
    while (index < calibrationTable.length - 2 && rawValue > calibrationTable[index + 1]['raw']!) {
      index++;
    }

    final p1 = calibrationTable[index];
    final p2 = calibrationTable[index + 1];

    final double x1 = p1['raw']!;
    final double y1 = p1['mm']!;
    final double x2 = p2['raw']!;
    final double y2 = p2['mm']!;

    // Rumus interpolasi linear: y = y1 + (x - x1) * (y2 - y1) / (x2 - x1)
    return y1 + (rawValue - x1) * (y2 - y1) / (x2 - x1);
  }

  /// Decode bytes BLE notification menjadi nilai double (mm atau inch).
  /// Mendukung Custom Binary Protocol & Fallback ASCII.
  static double? decode(List<int> bytes, {List<Map<String, double>> calibrationTable = const []}) {
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

        // --- MAPPING ADC CALIBRATION ---
        // Gunakan tabel kalibrasi (Lerp) karena nilai datang dari analog sensor / ESP32.
        double value = _interpolate(rawValue.toDouble(), calibrationTable);

        log('[BleDecoder] binary parsed ADC: raw=$rawValue -> $value mm');
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

  /// Ekstrak nilai raw ADC (sebelum kalibrasi)
  static double? extractRawValue(List<int> bytes) {
    if (bytes.length >= 5 && bytes[0] == 0x10) {
      int rawValue = (bytes[4] << 8) | bytes[3];
      if (rawValue > 32767) {
        rawValue -= 65536;
      }
      return rawValue.toDouble();
    }
    return null;
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
