import 'dart:developer';
import 'dart:math' as math;

/// Decoder untuk raw bytes dari Mitutoyo U-WAVE-T BLE notification.
class BleDecoder {
  BleDecoder._();

  /// Jumlah desimal yang valid untuk caliper/micrometer Mitutoyo.
  /// Diverifikasi dari log device asli (lihat catatan kalibrasi):
  /// byte[2] selalu bernilai 2 pada sesi yang sudah dicocokkan manual
  /// (gerak caliper ke 1.00/2.00/3.00/4.00/5.00 mm, hasil akurat).
  /// Resolusi 0.001mm (decimalPlaces=3) juga valid untuk sebagian model,
  /// tapi di luar rentang 0-4 nyaris pasti byte rusak/salah-deteksi protokol.
  static const int _minValidDecimalPlaces = 0;
  static const int _maxValidDecimalPlaces = 4;

  /// Fallback aman kalau byte[2] di luar rentang wajar.
  /// 2 dipilih karena ini nilai yang sudah terbukti akurat dari log device.
  static const int _fallbackDecimalPlaces = 2;

  /// Rentang fisik wajar untuk caliper/micrometer umum (mm).
  /// Dipakai hanya untuk WARNING di log, tidak untuk menolak data,
  /// supaya Arta tetap bisa melihat data mentah saat debugging.
  static const double _plausibleMinMm = -300.0;
  static const double _plausibleMaxMm = 300.0;

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
    // Format: [0x10, Seq, DecimalPlaces, LSB, MSB, Reserved, Reserved]
    if (bytes.length >= 5 && bytes[0] == 0x10) {
      try {
        int rawInt = (bytes[4] << 8) | bytes[3];
        // Konversi ke signed 16-bit integer (Two's complement)
        if (rawInt > 32767) {
          rawInt -= 65536;
        }

        if (calibrationTable.isNotEmpty) {
          // Gunakan tabel kalibrasi jika tersedia (ADC sensor eksternal)
          double value = _interpolate(rawInt.toDouble(), calibrationTable);
          log('[BleDecoder] calibrated: raw=$rawInt -> $value mm');
          return value;
        } else {
          // Gunakan Byte[2] sebagai jumlah angka desimal (standar Mitutoyo protocol)
          // Contoh: Byte[2]=2, rawInt=346 -> 346/100 = 3.46 mm
          int decimalPlaces = bytes[2];

          // SANITY CHECK: decimalPlaces harus dalam rentang wajar (0-4).
          // Tanpa ini, byte[2] yang corrupt/salah-tafsir bisa membuat
          // divisor melompat 10x lipat per kenaikan 1 unit byte, sehingga
          // value hasil decode melonjak liar walau rawInt-nya valid.
          if (decimalPlaces < _minValidDecimalPlaces ||
              decimalPlaces > _maxValidDecimalPlaces) {
            log('[BleDecoder] WARNING: decimalPlaces=$decimalPlaces di luar '
                'rentang wajar ($_minValidDecimalPlaces-$_maxValidDecimalPlaces). '
                'Kemungkinan byte[2] rusak atau salah deteksi protokol. '
                'Fallback ke decimalPlaces=$_fallbackDecimalPlaces. '
                'Raw bytes: $bytes');
            decimalPlaces = _fallbackDecimalPlaces;
          }

          double divisor = math.pow(10, decimalPlaces).toDouble();
          double value = rawInt / divisor;

          if (value < _plausibleMinMm || value > _plausibleMaxMm) {
            log('[BleDecoder] WARNING: value=$value mm di luar rentang fisik '
                'wajar caliper/micrometer ($_plausibleMinMm..$_plausibleMaxMm). '
                'Kemungkinan decimalPlaces salah, origin device drift, atau '
                'data corrupt. Cek raw bytes: $bytes');
          }

          log('[BleDecoder] binary parsed: rawInt=$rawInt, decPlaces=$decimalPlaces, divisor=$divisor -> $value mm');
          return value;
        }
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
