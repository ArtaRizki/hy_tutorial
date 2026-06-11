# Design.md — UI/UX Guidelines
## U-WAVE QC Inspector — Flutter App

---

## 1. Prinsip Desain

Aplikasi ini dipakai di **lantai produksi / workshop**:
- Tangan operator mungkin kotor atau pakai sarung tangan → **tombol besar**
- Pencahayaan workshop mungkin terang atau redup → **kontras tinggi**
- Operator butuh lihat nilai dengan cepat → **angka besar, mudah dibaca**
- Tidak perlu estetika mewah → **UI fungsional, bersih, langsung ke poin**

---

## 2. Warna

```dart
// lib/core/theme/app_theme.dart

// Primary - biru industrial
const Color kPrimary     = Color(0xFF1565C0);  // Blue 800
const Color kPrimaryLight = Color(0xFF1E88E5); // Blue 600

// Status
const Color kStatusOK    = Color(0xFF2E7D32);  // Green 800 → background badge OK
const Color kStatusNG    = Color(0xFFC62828);  // Red 800  → background badge NG
const Color kStatusOKText = Color(0xFFE8F5E9); // Green 50 → teks di atas badge OK
const Color kStatusNGText = Color(0xFFFFEBEE); // Red 50   → teks di atas badge NG

// Baris tabel
const Color kRowNG       = Color(0xFFFFEBEE);  // Red 50  → highlight baris NG
const Color kRowOK       = Colors.transparent;

// Neutral
const Color kBackground  = Color(0xFFF5F5F5);  // Grey 100
const Color kSurface     = Colors.white;
const Color kBorder      = Color(0xFFE0E0E0);  // Grey 300
```

---

## 3. Tipografi

```dart
// Nilai pengukuran (angka utama di layar ukur)
TextStyle kValueDisplay = TextStyle(
  fontSize: 72,          // sangat besar, bisa dibaca dari jarak ~50cm
  fontWeight: FontWeight.w700,
  fontFeatures: [FontFeature.tabularFigures()],  // angka lebar sama
  letterSpacing: -1.0,
);

// Label unit (mm / inch)
TextStyle kUnitLabel = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.w400,
  color: Colors.grey[600],
);

// Body tabel
TextStyle kTableCell = TextStyle(fontSize: 16);

// Badge status
TextStyle kBadgeText = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w600,
  letterSpacing: 0.5,
);
```

---

## 4. Komponen UI

### 4.1 Layar Pengukuran (Measurement Screen)
Ini layar paling penting — dipakai selama proses QC.

```
┌─────────────────────────────────┐
│ 🔵 UWAVE Connected    [PUTUS]   │  ← AppBar tipis
├─────────────────────────────────┤
│                                 │
│   Poros Ø12 - Batch 001        │  ← Nama sesi
│   Toleransi: 11.990 ~ 12.010   │  ← Info toleransi
│                                 │
│         ┌───────────┐           │
│         │  +12.002  │           │  ← Nilai besar (72px)
│         │    mm     │           │  ← Satuan (24px)
│         └───────────┘           │
│              ✅ OK              │  ← Badge besar
│                                 │
│   [    SIMPAN PENGUKURAN    ]   │  ← Tombol besar full-width
│                                 │
├─────────────────────────────────┤
│  Total: 24  |  OK: 22  |  NG: 2│  ← Statistik mini
└─────────────────────────────────┘
```

**Aturan warna nilai:**
- Dalam toleransi → teks hijau (`kStatusOK`)
- Luar toleransi → teks merah (`kStatusNG`)
- Belum ada data → abu-abu, tampilkan "---"

### 4.2 Tabel Pengukuran
```
┌────┬──────────┬──────┬──────────────────┐
│ No │ Nilai    │ Sts  │ Waktu            │
├────┼──────────┼──────┼──────────────────┤
│  1 │ +12.002  │ ✅OK │ 08:01:15         │
│  2 │ +12.015  │ ❌NG │ 08:02:30  ← merah│
│  3 │ +11.998  │ ✅OK │ 08:03:45         │
└────┴──────────┴──────┴──────────────────┘
```

### 4.3 Badge Status
```dart
// Widget StatusBadge
Container(
  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  decoration: BoxDecoration(
    color: isOk ? kStatusOK : kStatusNG,
    borderRadius: BorderRadius.circular(8),
  ),
  child: Text(
    isOk ? '✓  OK' : '✗  NG',
    style: kBadgeText.copyWith(
      color: isOk ? kStatusOKText : kStatusNGText,
    ),
  ),
)
```

### 4.4 BLE Status Indicator
```dart
// Titik indikator di AppBar
Row(children: [
  Container(
    width: 10, height: 10,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: isConnected ? Colors.green : Colors.red,
    ),
  ),
  SizedBox(width: 6),
  Text(isConnected ? 'UWAVE Terhubung' : 'Tidak Terhubung'),
])
```

---

## 5. Ukuran Tombol

Di lingkungan workshop, semua tombol interaktif minimum **48×48px** (Material touch target), dan tombol utama minimum **height: 56px, full width**.

```dart
// Tombol utama
ElevatedButton(
  style: ElevatedButton.styleFrom(
    minimumSize: Size(double.infinity, 56),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  ),
  ...
)
```

---

## 6. Navigasi (Routing)

```
/ (HomeScreen)
  ↓
/scan          → ScanScreen (pilih device BLE)
/session/new   → SessionFormScreen (buat sesi)
/measure       → MeasurementScreen (layar ukur utama)
/history       → HistoryScreen (daftar sesi lama)
/settings      → SettingsScreen
```

Gunakan **named routes** atau **GoRouter** untuk navigasi.

---

## 7. Feedback & Interaksi

- Saat data BLE diterima → **getaran haptic ringan** (`HapticFeedback.lightImpact()`)
- Saat status NG → **getaran lebih kuat** (`HapticFeedback.mediumImpact()`)
- Saat simpan berhasil → **SnackBar** "Pengukuran disimpan"
- Saat koneksi BLE terputus → **Dialog / Banner** peringatan

---

## 8. Dark Mode

Tidak diprioritaskan di MVP. Default Light Mode saja. Warna sudah dirancang untuk kontras tinggi di light mode.
