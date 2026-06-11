/// Model data untuk sesi pengukuran QC.
class Session {
  final int? id;
  final String name;
  final String? partNumber;
  final String? operatorName;
  final double toleranceMin;
  final double toleranceMax;
  final String unit; // 'mm' | 'inch'
  final DateTime createdAt;
  final DateTime? finishedAt;

  const Session({
    this.id,
    required this.name,
    this.partNumber,
    this.operatorName,
    required this.toleranceMin,
    required this.toleranceMax,
    this.unit = 'mm',
    required this.createdAt,
    this.finishedAt,
  });

  Session copyWith({
    int? id,
    String? name,
    String? partNumber,
    String? operatorName,
    double? toleranceMin,
    double? toleranceMax,
    String? unit,
    DateTime? createdAt,
    DateTime? finishedAt,
  }) {
    return Session(
      id: id ?? this.id,
      name: name ?? this.name,
      partNumber: partNumber ?? this.partNumber,
      operatorName: operatorName ?? this.operatorName,
      toleranceMin: toleranceMin ?? this.toleranceMin,
      toleranceMax: toleranceMax ?? this.toleranceMax,
      unit: unit ?? this.unit,
      createdAt: createdAt ?? this.createdAt,
      finishedAt: finishedAt ?? this.finishedAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'part_number': partNumber,
        'operator_name': operatorName,
        'tolerance_min': toleranceMin,
        'tolerance_max': toleranceMax,
        'unit': unit,
        'created_at': createdAt.toIso8601String(),
        'finished_at': finishedAt?.toIso8601String(),
      };

  factory Session.fromMap(Map<String, dynamic> map) => Session(
        id: map['id'] as int?,
        name: map['name'] as String,
        partNumber: map['part_number'] as String?,
        operatorName: map['operator_name'] as String?,
        toleranceMin: (map['tolerance_min'] as num).toDouble(),
        toleranceMax: (map['tolerance_max'] as num).toDouble(),
        unit: map['unit'] as String? ?? 'mm',
        createdAt: DateTime.parse(map['created_at'] as String),
        finishedAt: map['finished_at'] != null
            ? DateTime.parse(map['finished_at'] as String)
            : null,
      );
}
