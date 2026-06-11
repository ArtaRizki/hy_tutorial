# DataModel.md — Data Model & Database Schema
## U-WAVE QC Inspector — Flutter App

---

## 1. Overview

Database: **SQLite** via `sqflite`  
Semua data disimpan lokal di device, tidak ada koneksi internet.

```
┌─────────────────┐         ┌──────────────────────┐
│    sessions     │ 1 ──── * │    measurements      │
│─────────────────│         │──────────────────────│
│ id (PK)         │         │ id (PK)              │
│ name            │         │ session_id (FK)       │
│ part_number     │         │ value_mm             │
│ operator_name   │         │ status               │
│ tolerance_min   │         │ timestamp            │
│ tolerance_max   │         └──────────────────────┘
│ unit            │
│ created_at      │
│ finished_at     │
└─────────────────┘
```

---

## 2. Tabel: `sessions`

| Kolom | Tipe | Constraint | Deskripsi |
|---|---|---|---|
| `id` | INTEGER | PK, AUTOINCREMENT | ID unik sesi |
| `name` | TEXT | NOT NULL | Nama sesi, misal "Poros Ø12 - Batch 001" |
| `part_number` | TEXT | nullable | Nomor part / kode drawing |
| `operator_name` | TEXT | nullable | Nama operator |
| `tolerance_min` | REAL | NOT NULL | Batas bawah toleransi (mm) |
| `tolerance_max` | REAL | NOT NULL | Batas atas toleransi (mm) |
| `unit` | TEXT | DEFAULT 'mm' | Satuan: 'mm' atau 'inch' |
| `created_at` | TEXT | NOT NULL | ISO8601: '2024-06-08T10:30:00' |
| `finished_at` | TEXT | nullable | Diisi saat sesi ditutup |

**SQL Create:**
```sql
CREATE TABLE sessions (
  id            INTEGER PRIMARY KEY AUTOINCREMENT,
  name          TEXT    NOT NULL,
  part_number   TEXT,
  operator_name TEXT,
  tolerance_min REAL    NOT NULL,
  tolerance_max REAL    NOT NULL,
  unit          TEXT    NOT NULL DEFAULT 'mm',
  created_at    TEXT    NOT NULL,
  finished_at   TEXT
);
```

---

## 3. Tabel: `measurements`

| Kolom | Tipe | Constraint | Deskripsi |
|---|---|---|---|
| `id` | INTEGER | PK, AUTOINCREMENT | ID unik pengukuran |
| `session_id` | INTEGER | FK → sessions.id | Sesi induk |
| `value_mm` | REAL | NOT NULL | Nilai pengukuran dalam mm |
| `status` | TEXT | NOT NULL | 'OK' atau 'NG' |
| `timestamp` | TEXT | NOT NULL | ISO8601 waktu pengukuran |
| `note` | TEXT | nullable | Catatan manual operator (opsional) |

**SQL Create:**
```sql
CREATE TABLE measurements (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  session_id  INTEGER NOT NULL,
  value_mm    REAL    NOT NULL,
  status      TEXT    NOT NULL CHECK(status IN ('OK','NG')),
  timestamp   TEXT    NOT NULL,
  note        TEXT,
  FOREIGN KEY (session_id) REFERENCES sessions(id) ON DELETE CASCADE
);
```

---

## 4. Dart Model Classes

### Session Model
```dart
class Session {
  final int? id;
  final String name;
  final String? partNumber;
  final String? operatorName;
  final double toleranceMin;
  final double toleranceMax;
  final String unit;         // 'mm' | 'inch'
  final DateTime createdAt;
  final DateTime? finishedAt;

  Session({
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
    id: map['id'],
    name: map['name'],
    partNumber: map['part_number'],
    operatorName: map['operator_name'],
    toleranceMin: map['tolerance_min'],
    toleranceMax: map['tolerance_max'],
    unit: map['unit'] ?? 'mm',
    createdAt: DateTime.parse(map['created_at']),
    finishedAt: map['finished_at'] != null
        ? DateTime.parse(map['finished_at'])
        : null,
  );
}
```

### Measurement Model
```dart
class Measurement {
  final int? id;
  final int sessionId;
  final double valueMm;
  final String status;    // 'OK' | 'NG'
  final DateTime timestamp;
  final String? note;

  Measurement({
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
    id: map['id'],
    sessionId: map['session_id'],
    valueMm: map['value_mm'],
    status: map['status'],
    timestamp: DateTime.parse(map['timestamp']),
    note: map['note'],
  );
}
```

### Session Stats (computed, tidak disimpan ke DB)
```dart
class SessionStats {
  final int totalCount;
  final int okCount;
  final int ngCount;
  final double? average;
  final double? minValue;
  final double? maxValue;
  final double? range;       // max - min

  double get okRate => totalCount == 0 ? 0 : okCount / totalCount * 100;
}
```

---

## 5. BLE Raw Data Format

Data yang diterima dari U-WAVE-T sebagai `List<int>` (bytes):

```
Contoh bytes: [02, 31, 32, 2E, 35, 34, 30, 2B, 6D, 6D, 0D]

Interpretasi (perlu dikonfirmasi dari nRF Connect):
  Byte 0     : Header / SOH (Start of Header) = 0x02
  Byte 1–6   : ASCII value = "12.540"
  Byte 7     : Tanda = '+' (0x2B) atau '-' (0x2D)
  Byte 8–9   : Satuan = "mm" (0x6D, 0x6D)
  Byte 10    : Terminator = CR (0x0D)
```

**Decoder (sementara — update setelah dapat raw bytes dari nRF Connect):**
```dart
// lib/core/utils/ble_decoder.dart
class BleDecoder {
  static double? decode(List<int> bytes) {
    try {
      final raw = String.fromCharCodes(bytes).trim();
      // Coba parse langsung sebagai string angka
      return double.tryParse(raw.replaceAll(RegExp(r'[^\d.\-+]'), ''));
    } catch (_) {
      return null;
    }
  }
}
```

> ⚠️ **Format aktual harus dikonfirmasi** dengan screenshot nilai dari nRF Connect saat spindle digerakkan. Decoder di atas adalah perkiraan awal.

---

## 6. Contoh Data di Database

**sessions:**
```json
{
  "id": 1,
  "name": "Poros Ø12 - Batch 001",
  "part_number": "DRW-2024-001",
  "operator_name": "Alifano",
  "tolerance_min": 11.990,
  "tolerance_max": 12.010,
  "unit": "mm",
  "created_at": "2024-06-08T08:00:00",
  "finished_at": "2024-06-08T10:30:00"
}
```

**measurements:**
```json
[
  { "id": 1, "session_id": 1, "value_mm": 12.002, "status": "OK", "timestamp": "2024-06-08T08:01:15" },
  { "id": 2, "session_id": 1, "value_mm": 12.015, "status": "NG", "timestamp": "2024-06-08T08:02:30" },
  { "id": 3, "session_id": 1, "value_mm": 11.998, "status": "OK", "timestamp": "2024-06-08T08:03:45" }
]
```
