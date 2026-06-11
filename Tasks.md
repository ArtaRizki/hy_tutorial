# Tasks.md — Development Roadmap & Task Checklist
## U-WAVE QC Inspector — Flutter App

---

> Kerjakan berurutan. Setiap fase harus selesai dan bisa di-run sebelum lanjut ke fase berikutnya.
> Tandai dengan `[x]` setelah selesai.

---

## Phase 0 — Setup Project

- [ ] `flutter create uwave_qc_inspector`
- [ ] Set `minSdkVersion 23` di `android/app/build.gradle`
- [ ] Tambahkan semua dependency ke `pubspec.yaml` (lihat `TechStack.md`)
- [ ] Buat struktur folder sesuai `TechStack.md`
- [ ] Tambahkan permission BLE & storage ke `AndroidManifest.xml`
- [ ] Buat file `lib/core/constants/ble_constants.dart`
- [ ] Buat file `lib/core/constants/app_constants.dart`
- [ ] Buat `lib/core/theme/app_theme.dart` dengan warna dari `Design.md`
- [ ] Setup `MaterialApp` dengan theme di `main.dart`
- [ ] **Test:** App bisa di-run, tampil halaman kosong tanpa error

---

## Phase 1 — Database Layer

- [ ] Buat `lib/data/models/session_model.dart`
- [ ] Buat `lib/data/models/measurement_model.dart`
- [ ] Buat `lib/data/local/database_helper.dart`
  - [ ] Method `initDatabase()` — buat tabel `sessions` dan `measurements`
  - [ ] Method `insertSession(Session s)` → return `int` (id baru)
  - [ ] Method `getSessions()` → return `List<Session>`
  - [ ] Method `getSessionById(int id)` → return `Session?`
  - [ ] Method `updateSession(Session s)` → return `int`
  - [ ] Method `insertMeasurement(Measurement m)` → return `int`
  - [ ] Method `getMeasurementsBySession(int sessionId)` → return `List<Measurement>`
  - [ ] Method `deleteMeasurement(int id)` → return `int`
- [ ] **Test:** Tulis unit test atau test manual lewat `main()` — insert session, insert 3 measurement, query kembali, pastikan data benar

---

## Phase 2 — BLE Layer

- [ ] Buat `lib/providers/ble_provider.dart`
  - [ ] State: `scanResults`, `connectedDevice`, `connectionState`, `currentValue`
  - [ ] Method `startScan()` — scan 10 detik, filter nama "UWAVE"
  - [ ] Method `stopScan()`
  - [ ] Method `connectToDevice(BluetoothDevice device)`
  - [ ] Method `disconnect()`
  - [ ] Subscribe ke characteristic `notifyCharUUID` setelah connect
  - [ ] Stream handler: bytes masuk → panggil `BleDecoder.decode()` → update `currentValue`
  - [ ] Auto-reconnect logic (max 3x)
- [ ] Buat `lib/core/utils/ble_decoder.dart`
  - [ ] Method `decode(List<int> bytes)` → return `double?`
  - [ ] `// TODO: update decoder setelah raw bytes dari nRF Connect dikonfirmasi`
- [ ] **Test:** Koneksi ke U-WAVE, gerakkan spindle, pastikan `currentValue` di provider berubah

---

## Phase 3 — Screen: Scan & Connect

- [ ] Buat `lib/ui/screens/home_screen.dart`
  - [ ] Tampilkan tombol "Scan Perangkat"
  - [ ] Tampilkan `ListView` hasil scan (filter nama "UWAVE")
  - [ ] Setiap item: nama device + MAC + tombol "Hubungkan"
  - [ ] Indikator loading saat scanning
- [ ] Buat `lib/ui/widgets/ble_status_indicator.dart`
  - [ ] Titik hijau/merah + teks status
- [ ] **Test:** Bisa scan, lihat UWAVE muncul di list, tap connect, status berubah "Terhubung"

---

## Phase 4 — Screen: Buat Sesi

- [ ] Buat `lib/providers/session_provider.dart`
  - [ ] State: `activeSession`, `sessions`
  - [ ] Method `createSession(Session s)`
  - [ ] Method `loadSessions()`
  - [ ] Method `finishSession(int id)`
- [ ] Buat `lib/ui/screens/session_form_screen.dart`
  - [ ] Form: nama sesi, nomor part, nama operator
  - [ ] Input toleransi min & max (dengan validasi: min < max)
  - [ ] Pilih satuan: mm / inch
  - [ ] Tombol "Mulai Sesi"
- [ ] **Test:** Isi form, simpan, sesi aktif tersimpan di DB

---

## Phase 5 — Screen: Pengukuran (Core Feature)

- [ ] Buat `lib/providers/measurement_provider.dart`
  - [ ] Method `addMeasurement(double value, Session session)`
    - Hitung status OK/NG berdasarkan toleransi
    - Insert ke DB
    - Update stats
  - [ ] Method `undoLast()` — hapus pengukuran terakhir
  - [ ] Computed: `stats` (SessionStats)
- [ ] Buat `lib/ui/widgets/measurement_value_display.dart`
  - [ ] Angka besar 72px
  - [ ] Warna hijau jika OK, merah jika NG, abu jika null
  - [ ] Satuan di bawah angka
- [ ] Buat `lib/ui/widgets/status_badge.dart`
  - [ ] Badge besar OK (hijau) / NG (merah)
- [ ] Buat `lib/ui/widgets/session_stats_card.dart`
  - [ ] Total, OK, NG, rata-rata
- [ ] Buat `lib/ui/screens/measurement_screen.dart`
  - [ ] Tampilkan `MeasurementValueDisplay`
  - [ ] Tampilkan `StatusBadge`
  - [ ] Tombol "SIMPAN PENGUKURAN" (full-width, 56px)
  - [ ] Tombol "Batalkan Terakhir" (undo)
  - [ ] `SessionStatsCard` di bawah
  - [ ] Haptic feedback saat terima data & saat NG
- [ ] Buat `lib/ui/widgets/measurement_table.dart`
  - [ ] Kolom: No, Nilai, Status, Waktu
  - [ ] Baris NG highlight merah
  - [ ] Scroll jika banyak data
- [ ] **Test:** Konek BLE, gerakkan spindle → nilai muncul → simpan → muncul di tabel → NG highlight merah

---

## Phase 6 — Export & Share

- [ ] Buat `lib/core/utils/export_helper.dart`
  - [ ] Method `exportToCsv(Session session, List<Measurement> data)` → return `File`
  - [ ] Method `exportToExcel(Session session, List<Measurement> data)` → return `File`
    - Header: nama sesi, part number, operator, toleransi, tanggal
    - Tabel data dengan warna merah untuk baris NG
    - Summary: total, OK, NG, rata-rata
- [ ] Tambahkan tombol "Export" di `MeasurementScreen` atau `HistoryScreen`
- [ ] Integrasi `share_plus` untuk share file
- [ ] **Test:** Export Excel, buka di Google Sheets / WA, pastikan format benar

---

## Phase 7 — History & Settings

- [ ] Buat `lib/ui/screens/history_screen.dart`
  - [ ] Daftar sesi lama (nama, tanggal, jumlah data, % OK)
  - [ ] Tap sesi → tampilkan detail dan tabel pengukurannya
- [ ] Buat `lib/ui/screens/settings_screen.dart`
  - [ ] Pilih satuan default (mm/inch)
  - [ ] Input nama operator / perusahaan default
  - [ ] Simpan ke `SharedPreferences`
- [ ] **Test:** History tampil, detail sesi bisa dilihat, setting tersimpan

---

## Phase 8 — Polish & Testing

- [ ] Test koneksi BLE selama 30 menit tanpa drop
- [ ] Test auto-reconnect (matikan U-WAVE lalu hidupkan lagi)
- [ ] Test export Excel dengan 100+ data
- [ ] Pastikan tidak ada memory leak (dispose semua stream/subscription)
- [ ] Pastikan app tidak crash jika BLE dimatikan tiba-tiba
- [ ] Review semua string UI — pastikan semua Bahasa Indonesia
- [ ] Build APK release: `flutter build apk --release`
- [ ] Install dan test di device fisik (bukan emulator — BLE tidak jalan di emulator)

---

## Catatan Penting

> ⚠️ **BLE Decoder belum final!**  
> Sebelum Phase 5, pastikan sudah dapat screenshot raw bytes dari nRF Connect saat spindle digerakkan. Update `ble_decoder.dart` berdasarkan format aktual bytes dari U-WAVE.

> ⚠️ **Test HARUS di device fisik**  
> Bluetooth tidak bisa ditest di Android Emulator. Siapkan HP Android fisik dari awal.
