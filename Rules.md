# Rules.md — Coding Standards & AI Rules
## U-WAVE QC Inspector — Flutter App

---

## 1. Aturan Umum

- Bahasa kode: **English** (nama variabel, fungsi, kelas, komentar)
- Bahasa UI string: **Indonesia** (semua teks yang tampil ke pengguna)
- Dart version: **null-safe** — tidak boleh ada `!` paksa kecuali sudah dipastikan tidak null
- Selalu gunakan `const` constructor jika widget tidak berubah
- Tidak boleh ada `print()` di production code — gunakan logger atau hapus

---

## 2. Penamaan

```dart
// Kelas → PascalCase
class MeasurementProvider {}
class SessionFormScreen {}

// Variabel & fungsi → camelCase
final double valueMm;
Future<void> connectToDevice() {}

// Konstanta → kCamelCase (prefix k)
const Color kStatusOK = Color(0xFF2E7D32);
const String kServiceUUID = '7eafd361-f150-4785-b307-47d34ed52c3c';

// File → snake_case
// measurement_provider.dart
// session_model.dart
// ble_decoder.dart

// Private → prefix underscore
double _lastValue = 0.0;
void _handleNotification(List<int> bytes) {}
```

---

## 3. Struktur Widget

- **Satu widget per file** — tidak boleh taruh 2 class widget di 1 file
- Widget yang dipakai lebih dari 1 tempat → **wajib dijadikan widget terpisah** di folder `ui/widgets/`
- Screen tidak boleh berisi logika bisnis — logika ada di Provider
- Screen hanya boleh: `Consumer<XProvider>`, memanggil method provider, build UI

```dart
// ✅ BENAR — screen tipis
class MeasurementScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<BleProvider>(
      builder: (context, ble, _) {
        return MeasurementValueDisplay(value: ble.currentValue);
      },
    );
  }
}

// ❌ SALAH — logika di dalam screen
class MeasurementScreen extends StatefulWidget {
  void _decodeBytes(List<int> bytes) { ... } // jangan taruh di sini
}
```

---

## 4. BLE Rules

- UUID selalu simpan di `ble_constants.dart`, tidak boleh hardcode di widget/provider
- Selalu wrap operasi BLE dalam try-catch
- Selalu cek `isConnected` sebelum subscribe/write
- Auto-reconnect: maksimal **3 kali percobaan**, lalu tampilkan error ke user
- Dispose BluetoothDevice subscription saat screen di-dispose

```dart
// ble_constants.dart
class BleConstants {
  static const String deviceName        = 'UWAVE';
  static const String serviceUUID       = '7eafd361-f150-4785-b307-47d34ed52c3c';
  static const String notifyCharUUID    = '7eafd361-f151-4785-b307-47d34ed52c3c';
  static const String writeCharUUID1    = '7eafd361-f154-4785-b307-47d34ed52c3c';
  static const int    reconnectAttempts = 3;
  static const int    scanTimeoutSec    = 10;
}
```

---

## 5. Database Rules

- Selalu gunakan **parameterized query** — tidak boleh string concatenation untuk SQL
- DatabaseHelper adalah **singleton**
- Semua operasi DB adalah `async` dan dikerjakan di isolate via sqflite (sudah otomatis)
- Selalu handle `null` dari `db.query()` — bisa return list kosong

```dart
// ✅ BENAR
await db.insert('measurements', measurement.toMap());
await db.query('measurements', where: 'session_id = ?', whereArgs: [sessionId]);

// ❌ SALAH — rentan SQL injection
await db.rawQuery('SELECT * FROM measurements WHERE session_id = $sessionId');
```

---

## 6. Error Handling

- Semua operasi async yang bisa gagal → **wajib try-catch**
- Error BLE → log + tampilkan SnackBar ke user (jangan crash)
- Error DB → log + return null/empty list (jangan crash)
- Tidak boleh ada empty catch: `catch (e) {}` — minimal log errornya

```dart
// ✅ BENAR
try {
  await device.connect();
} on FlutterBluePlusException catch (e) {
  debugPrint('BLE Error: ${e.code} - ${e.description}');
  _showErrorSnackBar('Gagal terhubung: ${e.description}');
} catch (e) {
  debugPrint('Unknown BLE error: $e');
}
```

---

## 7. State Management Rules

- `notifyListeners()` hanya dipanggil setelah state benar-benar berubah
- Tidak boleh panggil `notifyListeners()` di constructor
- Provider tidak boleh depend ke Provider lain secara langsung — gunakan callback atau event

---

## 8. Aturan untuk AI (Cursor / Copilot)

Jika kamu adalah AI yang membantu project ini, ikuti aturan ini:

1. **Jangan generate kode lengkap sekaligus** untuk fitur besar — pecah per bagian kecil
2. **Selalu follow struktur folder** yang ada di `TechStack.md`
3. **Selalu gunakan UUID dari `BleConstants`** — jangan hardcode UUID di tempat lain
4. **Decoder BLE belum final** — tandai bagian decode dengan `// TODO: update after raw bytes confirmed`
5. **Jangan tambah dependency baru** tanpa konfirmasi — cek dulu apakah fungsi yang dibutuhkan sudah ada di package yang sudah ada
6. **Semua string UI** dalam Bahasa Indonesia
7. **Jangan hapus komentar TODO** yang sudah ada — itu penanda item yang belum selesai
8. Jika membuat widget baru → **wajib taruh di `ui/widgets/`**, bukan inline di screen
