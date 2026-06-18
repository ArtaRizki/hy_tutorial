import 'dart:developer';
import 'dart:math' as math;

/// Hasil decode yang lengkap, termasuk detail internal yang dipakai
/// untuk menghasilkan [value] -- dibuat khusus supaya proses logging
/// di [BleProvider] bisa mencatat SEMUA variabel penting dalam satu
/// baris (decimalPlaces yang dipakai, apakah itu hasil fallback,
/// protokol yang terdeteksi, dst), tanpa harus memanggil ulang/menebak
/// ulang logic decode secara terpisah.
class DecodedMeasurement {
  /// Nilai akhir hasil decode (mm/inch), null jika gagal di-parse.
  final double? value;

  /// Nilai integer mentah sebelum dibagi divisor (hanya untuk binary protocol).
  final int? rawInt;

  /// decimalPlaces yang BENAR-BENAR dipakai untuk menghasilkan [value].
  /// Bisa berbeda dari bytes[2] asli jika [decimalPlacesWasFallback] true.
  final int? decimalPlacesUsed;

  /// Nilai asli bytes[2] sebelum divalidasi (untuk audit, walau di luar rentang wajar).
  final int? decimalPlacesRaw;

  /// True jika decimalPlacesRaw di luar rentang wajar (0-4) sehingga
  /// sistem memakai nilai fallback alih-alih bytes[2] asli.
  final bool decimalPlacesWasFallback;

  /// Protokol yang terdeteksi: 'binary', 'ascii', atau 'unknown'.
  final String protocol;

  /// True jika [value] di luar rentang fisik wajar caliper/micrometer.
  final bool valueOutOfPlausibleRange;

  const DecodedMeasurement({
    required this.value,
    required this.rawInt,
    required this.decimalPlacesUsed,
    required this.decimalPlacesRaw,
    required this.decimalPlacesWasFallback,
    required this.protocol,
    required this.valueOutOfPlausibleRange,
  });

  /// Representasi satu baris yang ringkas untuk keperluan log diagnostik.
  /// Sengaja mencantumkan SEMUA variabel kunci yang relevan untuk
  /// diagnosis "kenapa value tidak akurat", supaya tidak perlu lagi
  /// hitung manual dari raw bytes setiap kali analisis.
  @override
  String toString() {
    return 'protocol=$protocol, rawInt=$rawInt, '
        'decimalPlaces(raw=$decimalPlacesRaw, used=$decimalPlacesUsed, '
        'fallback=$decimalPlacesWasFallback), '
        'value=$value, outOfRange=$valueOutOfPlausibleRange';
  }
}

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
  ///
  /// Method ini sekarang adalah wrapper tipis di atas [decodeDetailed] --
  /// dipertahankan agar caller lama (mis. kode UI yang hanya butuh angka)
  /// tidak perlu berubah.
  static double? decode(List<int> bytes, {List<Map<String, double>> calibrationTable = const []}) {
    return decodeDetailed(bytes, calibrationTable: calibrationTable).value;
  }

  /// Sama seperti [decode], tapi mengembalikan SEMUA detail internal
  /// yang dipakai untuk menghasilkan nilai akhirnya -- decimalPlaces yang
  /// terpakai, apakah itu hasil fallback, protokol yang terdeteksi, dst.
  ///
  /// Dibuat khusus untuk keperluan diagnostik: supaya satu baris log bisa
  /// menjawab langsung "kenapa value ini muncul", tanpa harus membongkar
  /// ulang raw bytes secara manual setiap kali ada laporan nilai aneh.
  static DecodedMeasurement decodeDetailed(
    List<int> bytes, {
    List<Map<String, double>> calibrationTable = const [],
  }) {
    if (bytes.isEmpty) {
      return const DecodedMeasurement(
        value: null,
        rawInt: null,
        decimalPlacesUsed: null,
        decimalPlacesRaw: null,
        decimalPlacesWasFallback: false,
        protocol: 'unknown',
        valueOutOfPlausibleRange: false,
      );
    }

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
          return DecodedMeasurement(
            value: value,
            rawInt: rawInt,
            decimalPlacesUsed: null,
            decimalPlacesRaw: bytes[2],
            decimalPlacesWasFallback: false,
            protocol: 'binary_calibrated',
            valueOutOfPlausibleRange:
                value < _plausibleMinMm || value > _plausibleMaxMm,
          );
        } else {
          // Gunakan Byte[2] sebagai jumlah angka desimal (standar Mitutoyo protocol)
          // Contoh: Byte[2]=2, rawInt=346 -> 346/100 = 3.46 mm
          final int decimalPlacesRaw = bytes[2];
          int decimalPlaces = decimalPlacesRaw;
          bool wasFallback = false;

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
            wasFallback = true;
          }

          double divisor = math.pow(10, decimalPlaces).toDouble();
          double value = rawInt / divisor;
          final bool outOfRange = value < _plausibleMinMm || value > _plausibleMaxMm;

          if (outOfRange) {
            log('[BleDecoder] WARNING: value=$value mm di luar rentang fisik '
                'wajar caliper/micrometer ($_plausibleMinMm..$_plausibleMaxMm). '
                'Kemungkinan decimalPlaces salah, origin device drift, atau '
                'data corrupt. Cek raw bytes: $bytes');
          }

          log('[BleDecoder] binary parsed: rawInt=$rawInt, decPlacesRaw=$decimalPlacesRaw, '
              'decPlacesUsed=$decimalPlaces, fallback=$wasFallback, divisor=$divisor -> $value mm');

          return DecodedMeasurement(
            value: value,
            rawInt: rawInt,
            decimalPlacesUsed: decimalPlaces,
            decimalPlacesRaw: decimalPlacesRaw,
            decimalPlacesWasFallback: wasFallback,
            protocol: 'binary',
            valueOutOfPlausibleRange: outOfRange,
          );
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
      if (numStr.isEmpty) {
        return DecodedMeasurement(
          value: null,
          rawInt: null,
          decimalPlacesUsed: null,
          decimalPlacesRaw: null,
          decimalPlacesWasFallback: false,
          protocol: 'ascii',
          valueOutOfPlausibleRange: false,
        );
      }

      final parsed = double.tryParse(numStr);
      final double? finalValue = parsed == null ? null : (isNegative ? -parsed : parsed);

      return DecodedMeasurement(
        value: finalValue,
        rawInt: null,
        decimalPlacesUsed: null,
        decimalPlacesRaw: null,
        decimalPlacesWasFallback: false,
        protocol: 'ascii',
        valueOutOfPlausibleRange: finalValue != null &&
            (finalValue < _plausibleMinMm || finalValue > _plausibleMaxMm),
      );
    } catch (e) {
      log('[BleDecoder] ascii error: $e');
      return const DecodedMeasurement(
        value: null,
        rawInt: null,
        decimalPlacesUsed: null,
        decimalPlacesRaw: null,
        decimalPlacesWasFallback: false,
        protocol: 'ascii',
        valueOutOfPlausibleRange: false,
      );
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
