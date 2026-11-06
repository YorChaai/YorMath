# Technical Implementation Plan — Penyelarasan Math Workout (v6.4) ke Mathall

Dokumen ini menjelaskan strategi teknis, arsitektur, dan rencana implementasi langkah demi langkah untuk menyempurnakan aplikasi **Mathall** agar mengadopsi tampilan UI/UX dan kelengkapan fitur dari aplikasi referensi **Math Workout Pro (v6.4)** tanpa merusak fitur eksisting.

---

## 1. Arsitektur & Prinsip Desain

### A. Zero-Regression Guarantee (Garansi Tanpa Regresi)
1. **Model & State**:
   - `AppSettings` dan `SettingsProvider` tetap mempertahankan seluruh state custom preset (`var1Presets`, `var2Presets`, `otherPresets`, `memoryPresets`) serta opsi `durationMinutes` dan `isDurationMode`.
   - Menambahkan getter/setter aman untuk preset difficulty baru jika diperlukan (`Challenging`, `Expert`) dengan fallback default yang aman.
2. **Modularitas**:
   - Seluruh penyesuaian UI dilakukan pada lapisan presentasi (`lib/presentation/` dan `lib/home_screen.dart`).
   - Logika generator matematika (`lib/core/utils/generators/`) tidak diubah fungsinya, melainkan hanya diintegrasikan dengan mode kuis baru (seperti latihan tabel perkalian/pembagian interaktif).
3. **Audio Service**:
   - Menggunakan package `audioplayers` yang sudah terpasang di `pubspec.yaml` untuk memutar audio efek `success.mp3` dan `error.mp3` secara asinkron tanpa memblokir thread UI.

---

## 2. Pemetaan Berkas yang Terlibat (Affected Files)

| Modul / Komponen | Berkas Terkait | Aksi | Deskripsi |
| :--- | :--- | :---: | :--- |
| **Aset & Konfigurasi** | `pubspec.yaml` | Edit | Menambahkan path aset audio dan ikon SVG jika diperlukan |
| **Aset Efek Suara** | `assets/sounds/success.mp3`<br>`assets/sounds/error.mp3` | Buat | Menyalin audio asli dari ekstraksi APK referensi |
| **Aset Ikon** | `assets/icons/*.svg` | Buat | Menyalin ikon kategori asli dari ekstraksi APK referensi |
| **Layanan Suara** | `lib/core/services/audio_service.dart` | Buat | Helper ringkas pemutar audio kuis dengan cek `isSoundEnabled` |
| **Menu Utama** | `lib/home_screen.dart` | Edit | Mengadopsi styling tombol rounded biru, footer bar, dan pengelompokan mode |
| **Portal Launcher** | `lib/yormath_home.dart` | Review | Memastikan kartu Brain Game & Math Workout tetap utuh |
| **Komponen Countdown** | `lib/presentation/workout/widgets/countdown_overlay.dart` | Buat | Widget animasi hitung mundur lingkaran (3-2-1) sebelum mulai |
| **Layar Latihan** | `lib/presentation/workout/screens/workout_screen.dart` | Edit | Integrasi countdown, live timer minimalis di header, trigger audio |
| **Keypad Kustom** | `lib/presentation/workout/widgets/keypad_widget.dart` | Edit | Penyesuaian layout *Phone* vs *Calculator*, ukuran *Normal* vs *Large* |
| **Tabel Interaktif** | `lib/presentation/learn/screens/learn_table_screen.dart` | Edit | Grid 1–36, tab rentang 1–50, toggle ×/÷, tombol Practice |
| **Peninjauan Jawaban** | `lib/presentation/workout/screens/answers_screen.dart` | Edit | Format persamaan salah dengan coret merah (`~56~ 54`) dan centang hijau |
| **Layar Hasil** | `lib/presentation/workout/screens/result_screen.dart` | Edit | Sinkronisasi tombol navigasi ke AnswersScreen & Play Again |
| **Layar Pengaturan** | `lib/settings_screen.dart`<br>`lib/presentation/settings/screens/keypad_settings_screen.dart` | Edit | Penyelarasan opsi kesulitan (*Challenging*, *Expert*) dan preview keypad |

---

## 3. Rencana Eksekusi Bertahap (Detailed Phased Rollout)

### Fase 1: Integrasi Aset Asli & Helper Suara
1. Salin file `success.mp3` dan `error.mp3` dari folder ekstraksi scratch ke `assets/sounds/`.
2. Pastikan file audio terbaca dalam build Flutter.
3. Buat file `lib/core/services/workout_audio_service.dart`:
   - Menggunakan `AudioPlayer` dari `audioplayers`.
   - Method `playSuccess()` dan `playError()` dengan proteksi try-catch dan pengecekan setting suara aktif.

### Fase 2: Penyelarasan UI Home Screen
1. Perbarui `HomeScreen`:
   - Warna tema primer diselaraskan dengan referensi (`#0288D1`).
   - Ubah tombol menu menjadi rounded card lebar penuh (tinggi 55px, borderRadius 14px, warna biru solid dengan elevation lembut).
   - Susun daftar menu utama:
     - *Addition*
     - *Subtraction*
     - *Multiplication*
     - *Division*
     - *Customizable* (Membuka pengaturan custom preset)
     - *Multiplication Tables* (Membuka tabel interaktif)
     - *Addition & Subtraction*
     - *Multiplication & Division*
     - *Mixed*
     - *Arithmetic Memory*
   - Buat seksi *"Operasi Lanjutan"* di bawahnya agar fitur khas Mathall (Pangkat, Akar, Persentase, Faktorial, Nilai Mutlak, Logaritma, Modulo) tetap mudah diakses.
   - Tambahkan footer bar dengan ikon hati (Rating) dan ikon Share.

### Fase 3: Komponen Countdown & Layar Latihan
1. Buat widget `CountdownOverlay`:
   - Animasi lingkaran besar di tengah layar dengan background biru.
   - Menghitung mundur dari `3` -> `2` -> `1` -> mulai kuis secara otomatis (atau tap untuk lewati).
2. Perbarui `WorkoutScreen`:
   - Munculkan countdown sebelum soal pertama ditampilkan.
   - Header dibuat minimalis: tombol kembali di kiri + `Time MM:SS.ms` di tengah.
   - Pemicu suara `playSuccess()` saat jawaban benar dan `playError()` saat salah.
3. Perbarui `KeypadWidget`:
   - Hubungkan setting `keypadType` (*Phone* vs *Calculator*).
   - Hubungkan setting `keypadSize` (*Normal* vs *Large*).
   - Pastikan fitur *Auto Confirm* langsung memproses jawaban jika tepat.

### Fase 4: Fitur Tabel Perkalian & Pembagian Interaktif (Tables Screen)
1. Perbarui `LearnTableScreen` agar sesuai dengan fitur tabel Math Workout:
   - Tampilan pemilihan angka berupa grid 3 kolom dari angka `1` sampai `36`.
   - Saat angka dipilih, buka tampilan isi tabel dengan tab rentang (`1-10`, `11-20`, `21-30`, `31-40`, `41-50`).
   - Tombol toggle instan antara mode Perkalian (`×`) dan Pembagian (`÷`).
   - Tombol "Practice" di bawah untuk langsung membuka sesi latihan tabel angka yang dipilih.

### Fase 5: Evaluasi & Review Jawaban (Answers Screen)
1. Perbarui `AnswersScreen`:
   - Header menampilkan ringkasan `Correct X` (hijau) dan `Wrong Y` (merah).
   - Setiap baris menampilkan tanda centang hijau atau silang merah.
   - Format jawaban salah: jawaban pengguna dicoret merah (`style: TextStyle(decoration: TextDecoration.lineThrough, color: Colors.red)`), diikuti jawaban benar dalam warna hijau.
   - Tombol "Latihan Lagi" / *Play Again* di bagian bawah.

### Fase 6: Pengujian, Verifikasi, & Deployment
1. Menjalankan `flutter analyze` dan memperbaiki jika ada linting/type warning.
2. Menjalankan `flutter test` untuk memverifikasi logika matematika dan generator soal.
3. Melakukan build debug APK dan instalasi langsung ke perangkat Xiaomi 15T Pro via ADB (`flutter run -d DEIVYTAMMJNJPR85` atau `adb install`).

---

## 4. Kriteria Keberhasilan & Persetujuan (Approval Gate)
- [x] Pengguna meninjau dan menyetujui rancangan di atas.
- [x] Tidak ada kode eksisting yang hilang atau rusak.
- [x] Semua tahapan dapat dieksekusi secara teratur dan transparan.
- [x] APK Release terkompilasi dan terpasang di Xiaomi 15T Pro tanpa kehilangan data.
