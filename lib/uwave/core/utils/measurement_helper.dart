/// Helper untuk kalkulasi status OK/NG dan statistik sesi.
class MeasurementHelper {
  MeasurementHelper._();

  /// Tentukan status: 'OK' jika value dalam [min, max], 'NG' jika di luar.
  static String calcStatus({
    required double value,
    required double toleranceMin,
    required double toleranceMax,
  }) {
    return (value >= toleranceMin && value <= toleranceMax) ? 'OK' : 'NG';
  }

  /// Hitung statistik dari list nilai pengukuran.
  static SessionStats calcStats(List<double> values, List<String> statuses) {
    if (values.isEmpty) {
      return SessionStats(
        totalCount: 0,
        okCount: 0,
        ngCount: 0,
        average: null,
        minValue: null,
        maxValue: null,
        range: null,
      );
    }

    final okCount = statuses.where((s) => s == 'OK').length;
    final ngCount = statuses.where((s) => s == 'NG').length;
    final avg = values.reduce((a, b) => a + b) / values.length;
    final minV = values.reduce((a, b) => a < b ? a : b);
    final maxV = values.reduce((a, b) => a > b ? a : b);

    return SessionStats(
      totalCount: values.length,
      okCount: okCount,
      ngCount: ngCount,
      average: avg,
      minValue: minV,
      maxValue: maxV,
      range: maxV - minV,
    );
  }
}

/// Model statistik sesi (computed, tidak disimpan ke DB).
class SessionStats {
  final int totalCount;
  final int okCount;
  final int ngCount;
  final double? average;
  final double? minValue;
  final double? maxValue;
  final double? range;

  const SessionStats({
    required this.totalCount,
    required this.okCount,
    required this.ngCount,
    required this.average,
    required this.minValue,
    required this.maxValue,
    required this.range,
  });

  double get okRate => totalCount == 0 ? 0 : okCount / totalCount * 100;
  double get ngRate => totalCount == 0 ? 0 : ngCount / totalCount * 100;
}
