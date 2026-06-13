import 'dart:developer';

/// Decoder untuk raw bytes dari Mitutoyo U-WAVE-T BLE notification.
///
/// Format perkiraan (konfirmasi via nRF Connect):
///   [0x02] [ASCII digits] [+/-] [mm/in] [0x0D]
///   Contoh: [02, 31, 32, 2E, 35, 34, 30, 2B, 6D, 6D, 0D]
///             →  "12.540+"  → +12.540 mm
///
/// ⚠️ Format aktual harus dikonfirmasi dengan nRF Connect.
class BleDecoder {
  BleDecoder._();

  /// Decode bytes BLE notification menjadi nilai double (mm atau inch).
  /// Returns null jika bytes tidak bisa di-parse.
  static double? decode(List<int> bytes) {
    if (bytes.isEmpty) return null;
    try {
      // Hapus byte non-printable (header, terminator)
      final filtered = bytes.where((b) => b >= 0x20 && b < 0x7F).toList();
      final raw = String.fromCharCodes(filtered).trim();
      log('[BleDecoder] raw string: "$raw"');

      // Cek apakah ada tanda negatif '-' di dalam string
      final bool isNegative = raw.contains('-');

      // Ambil hanya karakter numerik dan titik desimal
      final numStr = raw.replaceAll(RegExp(r'[^\d.]'), '').trim();
      if (numStr.isEmpty) return null;

      final parsed = double.tryParse(numStr);
      if (parsed == null) return null;

      return isNegative ? -parsed : parsed;
    } catch (e) {
      log('[BleDecoder] error: $e');
      return null;
    }
  }

  /// Ekstrak satuan dari bytes: 'mm' atau 'inch'
  static String extractUnit(List<int> bytes) {
    final raw = String.fromCharCodes(
      bytes.where((b) => b >= 0x20 && b < 0x7F).toList(),
    );
    if (raw.toLowerCase().contains('in')) return 'inch';
    return 'mm';
  }
}
