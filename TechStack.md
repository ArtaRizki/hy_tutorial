# TechStack.md — Technology Stack & Architecture
## U-WAVE QC Inspector — Flutter App

---

## 1. Stack Utama

| Layer | Teknologi | Versi | Alasan |
|---|---|---|---|
| **UI Framework** | Flutter | ^3.x | Cross-platform, widget kaya, performa tinggi |
| **Bahasa** | Dart | ^3.x | Null-safe, async/await native |
| **BLE** | `flutter_blue_plus` | ^1.x | Paling aktif maintained, support Android & iOS |
| **Database Lokal** | SQLite via `sqflite` | ^2.x | Ringan, offline-first, SQL familiar |
| **State Management** | Provider + ChangeNotifier | ^6.x | Simpel, cukup untuk scope project ini |
| **Export Excel** | `syncfusion_flutter_xlsio` | latest | Bisa format cell, header, warna |
| **Export CSV** | `csv` | ^5.x | Ringan, cukup untuk format sederhana |
| **Share File** | `share_plus` | ^7.x | Share ke WA, email, dll |
| **Permission** | `permission_handler` | ^11.x | Handle izin Bluetooth & storage |
| **Path** | `path_provider` | ^2.x | Lokasi penyimpanan file di device |

---

## 2. Struktur Folder

```
lib/
├── main.dart
├── app/
│   └── app.dart                  # MaterialApp, routing, theme
│
├── core/
│   ├── constants/
│   │   ├── ble_constants.dart    # UUID, nama device, timeout
│   │   └── app_constants.dart    # warna status, satuan, dll
│   ├── utils/
│   │   ├── ble_decoder.dart      # decode raw bytes → nilai mm
│   │   ├── measurement_helper.dart # hitung status OK/NG, statistik
│   │   └── export_helper.dart    # generate Excel & CSV
│   └── theme/
│       └── app_theme.dart        # MaterialTheme, warna, font
│
├── data/
│   ├── local/
│   │   ├── database_helper.dart  # SQLite setup, CRUD
│   │   └── tables/
│   │       ├── session_table.dart
│   │       └── measurement_table.dart
│   └── models/
│       ├── session_model.dart
│       └── measurement_model.dart
│
├── providers/
│   ├── ble_provider.dart         # scan, connect, terima data BLE
│   ├── session_provider.dart     # manajemen sesi aktif
│   └── measurement_provider.dart # CRUD data pengukuran
│
└── ui/
    ├── screens/
    │   ├── home_screen.dart         # scan BLE, pilih device
    │   ├── measurement_screen.dart  # layar ukur real-time
    │   ├── session_form_screen.dart # buat/edit sesi
    │   ├── history_screen.dart      # daftar sesi lama
    │   └── settings_screen.dart     # pengaturan app
    └── widgets/
        ├── measurement_value_display.dart  # angka besar di tengah
        ├── status_badge.dart               # badge OK/NG
        ├── measurement_table.dart          # tabel data
        ├── ble_status_indicator.dart       # indikator koneksi
        └── session_stats_card.dart         # ringkasan statistik
```

---

## 3. BLE Architecture

```
flutter_blue_plus
    │
    ├── BluetoothDevice       → represent U-WAVE-T
    ├── BluetoothService      → service UUID: 7eafd361-f150-...
    └── BluetoothCharacteristic → char UUID: 7eafd361-f151-... (NOTIFY)
                                          └── setNotifyValue(true)
                                          └── lastValueStream → Stream<List<int>>
                                                    │
                                                    ▼
                                          BleDecoder.decode(bytes)
                                                    │
                                                    ▼
                                          double value (mm/inch)
                                                    │
                                                    ▼
                                          MeasurementProvider.addMeasurement()
```

---

## 4. State Management Flow

```
BleProvider (ChangeNotifier)
  - scanResults: List<ScanResult>
  - connectedDevice: BluetoothDevice?
  - connectionState: BleState (scanning/connected/disconnected)
  - currentValue: double?           ← update setiap notifikasi BLE
  - isConnected: bool

SessionProvider (ChangeNotifier)
  - activeSession: Session?
  - sessions: List<Session>
  
MeasurementProvider (ChangeNotifier)
  - measurements: List<Measurement>
  - stats: SessionStats (ok, ng, avg, min, max)
```

---

## 5. Dependencies (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter

  # BLE
  flutter_blue_plus: ^1.31.0

  # Database
  sqflite: ^2.3.0
  path: ^1.9.0

  # State management
  provider: ^6.1.0

  # Export
  syncfusion_flutter_xlsio: ^25.1.0
  csv: ^5.1.1
  share_plus: ^7.2.0
  path_provider: ^2.1.0

  # Permission & utility
  permission_handler: ^11.3.0
  intl: ^0.18.1
```

---

## 6. Android Permissions (AndroidManifest.xml)

```xml
<!-- Bluetooth -->
<uses-permission android:name="android.permission.BLUETOOTH_SCAN"
    android:usesPermissionFlags="neverForLocation" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />

<!-- Storage (untuk export file) -->
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"
    android:maxSdkVersion="28" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"
    android:maxSdkVersion="32" />

<!-- BLE feature -->
<uses-feature android:name="android.hardware.bluetooth_le" android:required="true" />
```

---

## 7. Minimum Requirements
- Android 6.0 (API 23) — minimum untuk BLE
- Android 12+ — butuh `BLUETOOTH_SCAN` & `BLUETOOTH_CONNECT` permission baru
- Bluetooth Low Energy support (semua HP modern punya)
- Storage untuk export file
