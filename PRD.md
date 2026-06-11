# PRD.md — Product Requirements Document
## U-WAVE QC Inspector — Flutter App

---

## 1. Ringkasan Produk

**Nama Aplikasi:** U-WAVE QC Inspector  
**Platform:** Android (Flutter)  
**Versi MVP:** 1.0  
**Dibuat untuk:** Operator QC / Quality Control di lingkungan manufaktur atau workshop

Aplikasi ini menghubungkan smartphone Android ke alat ukur **Mitutoyo Dial Indicator** melalui adapter **Mitutoyo U-WAVE-T** via Bluetooth Low Energy (BLE). Setiap kali operator mengukur sebuah part, nilai pengukuran masuk secara otomatis ke aplikasi tanpa perlu mengetik manual — lalu disimpan ke database lokal, ditampilkan dalam tabel, dan bisa diekspor ke Excel/CSV untuk laporan QC.

---

## 2. Masalah yang Diselesaikan

| Masalah Saat Ini | Solusi App |
|---|---|
| Operator catat ukuran manual ke kertas / Excel → rentan salah ketik | Data masuk otomatis dari alat ukur via BLE |
| Tidak ada rekapitulasi real-time | Dashboard langsung tampilkan status OK/NG |
| Laporan QC butuh waktu rekap manual | Export Excel/CSV 1 klik |
| Susah tahu part mana yang out-of-spec | Visual highlight merah/hijau otomatis |

---

## 3. Target Pengguna

- **Operator QC** — mengukur part satu per satu, butuh UI simpel
- **Supervisor QC** — butuh laporan ringkas dan export data
- Lingkungan: workshop / lantai produksi, tangan mungkin kotor → UI besar & tombol besar

---

## 4. Fitur MVP (Versi 1.0)

### 4.1 Koneksi BLE
- [ ] Scan device BLE di sekitar
- [ ] Filter & tampilkan hanya device dengan nama "UWAVE"
- [ ] Connect / disconnect ke U-WAVE-T
- [ ] Subscribe ke characteristic NOTIFY (`7eafd361-f151-4785-b307-47d34ed52c3c`)
- [ ] Indikator status koneksi (terhubung / terputus)
- [ ] Auto-reconnect jika koneksi terputus

### 4.2 Terima & Decode Data
- [ ] Terima raw bytes dari BLE notification
- [ ] Decode bytes ke nilai desimal (mm atau inch)
- [ ] Deteksi tanda +/- dan satuan
- [ ] Tampilkan nilai real-time di layar utama (font besar)

### 4.3 Manajemen Sesi Pengukuran
- [ ] Buat sesi baru (nama part, nomor job, toleransi min/max)
- [ ] Simpan setiap pengukuran ke sesi aktif
- [ ] Tandai otomatis: OK (dalam toleransi) / NG (out of spec)
- [ ] Hitung statistik: jumlah OK, jumlah NG, rata-rata, min, max

### 4.4 Tampilan Tabel Data
- [ ] Tampilkan daftar pengukuran dalam sesi aktif
- [ ] Kolom: No, Nilai (mm), Status (OK/NG), Waktu
- [ ] Highlight baris NG dengan warna merah
- [ ] Hapus data terakhir (undo) jika salah ukur

### 4.5 Export & Laporan
- [ ] Export data sesi ke file CSV
- [ ] Export ke Excel (.xlsx) dengan format laporan QC
- [ ] Share file via WhatsApp / Email langsung dari app

### 4.6 Pengaturan
- [ ] Pilih satuan: mm / inch
- [ ] Set toleransi default
- [ ] Nama operator / perusahaan untuk header laporan

---

## 5. Fitur yang TIDAK ada di MVP (Future)
- Sync ke server / cloud
- Multi-device BLE (lebih dari 1 alat ukur)
- Analisis SPC (Statistical Process Control)
- Grafik tren pengukuran
- Login / manajemen user

---

## 6. User Flow Utama

```
[Buka App]
    ↓
[Scan BLE] → [Pilih UWAVE] → [Terhubung ✓]
    ↓
[Buat Sesi Baru]
  → Input: nama part, nomor job, toleransi min/max
    ↓
[Layar Pengukuran]
  → Tempel spindle ke benda
  → Nilai muncul otomatis (besar di tengah layar)
  → Tekan "SIMPAN" atau otomatis simpan
  → Status OK/NG langsung muncul
    ↓
[Ulangi untuk setiap part]
    ↓
[Selesai Sesi] → [Export Excel/CSV] → [Share]
```

---

## 7. Kriteria Sukses MVP
- Koneksi BLE stabil, tidak drop dalam 30 menit pemakaian
- Nilai pengukuran tampil dalam < 500ms setelah spindle menyentuh benda
- Data tidak hilang meski app ditutup (persistent storage)
- Export Excel bisa dibuka di Microsoft Excel / Google Sheets
