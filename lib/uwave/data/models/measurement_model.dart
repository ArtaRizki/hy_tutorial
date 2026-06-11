/// Model data untuk satu pengukuran dalam sesi QC.
class Measurement {
  final int? id;
  final int sessionId;
  final double valueMm;
  final String status; // 'OK' | 'NG'
  final DateTime timestamp;
  final String? note;

  const Measurement({
    this.id,
    required this.sessionId,
    required this.valueMm,
    required this.status,
    required this.timestamp,
    this.note,
  });

  bool get isOk => status == 'OK';

  Map<String, dynamic> toMap() => {
        'id': id,
        'session_id': sessionId,
        'value_mm': valueMm,
        'status': status,
        'timestamp': timestamp.toIso8601String(),
        'note': note,
      };

  factory Measurement.fromMap(Map<String, dynamic> map) => Measurement(
        id: map['id'] as int?,
        sessionId: map['session_id'] as int,
        valueMm: (map['value_mm'] as num).toDouble(),
        status: map['status'] as String,
        timestamp: DateTime.parse(map['timestamp'] as String),
        note: map['note'] as String?,
      );
}
