# Task Breakdown — Penyelarasan Penuh Math Workout (v6.4) ke Mathall

Dokumen ini melacak setiap langkah pengerjaan untuk menyelaraskan UI/UX dan fitur aplikasi **Mathall** dengan aplikasi referensi **Math Workout Pro (v6.4)** tanpa merusak atau menghapus fitur yang sudah ada.

---

## 🛡️ Prinsip Keamanan & Integritas Kode
- [x] **Zero Feature Loss**: Fitur lanjutan Mathall (Faktorial, Nilai Mutlak, Logaritma, Modulo, Pangkat, Akar, Persentase, Duration Mode, Brain Game N-Back, Custom Presets 1-Var & 2-Var) **100% dipertahankan**.
- [x] **Zero Structural Overhaul**: Tidak merombak struktur arsitektur folder atau state management yang sudah berjalan dengan baik.
- [x] **Additive & Polishing Only**: Menambahkan fitur referensi yang belum ada dan memoles tampilan UI/UX agar identik dengan referensi.

---

## 📋 Daftar Rincian Tugas (Task Checklist)

### Tahap 1: Persiapan & Integrasi Aset Referensi
- [x] **1.1 Penyalinan Efek Suara Asli**
  - Salin `success.mp3` dan `error.mp3` dari ekstraksi APK referensi ke `assets/sounds/`.
  - Daftarkan `assets/sounds/` dan `assets/icons/` di `pubspec.yaml`.
- [x] **1.2 Penyalinan Ikon & Visual Asli**
  - Salin ikon kategori asli (`assets/images/category-icons/*.svg`) ke direktori `assets/icons/`.
- [x] **1.3 Integrasi Sound Manager di Sesi Workout**
  - Buat `WorkoutAudioService` menggunakan `audioplayers` untuk membunyikan `success.mp3` saat jawaban benar dan `error.mp3` saat salah (hanya jika setting `sounds` aktif).
  - Hubungkan ke `WorkoutProvider._checkAnswer()`.

---

### Tahap 2: Penyelarasan UI Home Screen & Menu
- [x] **2.1 Penyelarasan AppBar & Header**
  - Warna AppBar diselaraskan dengan palet biru khas Math Workout (`#0288D1`).
  - Judul "Math Workout" dengan tipografi tebal dan ikon Pengaturan (Gear) di pojok kanan atas.
- [x] **2.2 Pengelompokan & Penataan Tombol Mode Latihan**
  - Tombol-tombol berbentuk rounded rectangle tebal (border radius 14px, tinggi 52px, warna biru solid dengan teks putih di tengah).
  - Susunan mode latihan utama (sesuai urutan Math Workout referensi):
    1. Addition
    2. Subtraction
    3. Multiplication
    4. Division
    5. Customizable (Custom Presets 1-Var & 2-Var)
    6. Multiplication Tables
    7. Addition & Subtraction
    8. Multiplication & Division
    9. Mixed
    10. Arithmetic Memory
  - **Seksi Mode Lanjutan (Keunggulan Mathall)**: Dikelompokkan dalam expandable seksi ("Operasi Lanjutan"):
    - Pangkat, Akar, Persentase, Faktorial, Nilai Mutlak, Logaritma, Modulo, Custom Mixed, dan Mode Belajar.
- [x] **2.3 Footer Bar**
  - Tambahkan footer bar dengan tombol aksi rating (ikon hati) dan share seperti di referensi.
- [x] **2.4 Keutuhan Launcher YormathHome**
  - Layar pembuka `YormathHome` (pilihan BRAINGAME vs MATHALL) tetap berfungsi utuh.

---

### Tahap 3: Alur Menjelang Latihan & Countdown
- [x] **3.1 Pembuatan Widget Countdown 3-2-1**
  - Animasi lingkaran countdown minimalis Math Workout (`3 -> 2 -> 1`) dengan latar biru `#0288D1`.
  - Dilengkapi fitur *tap-to-skip* agar pengguna dapat langsung memulai kuis tanpa harus menunggu 3 detik.
- [x] **3.2 Integrasi Alur Countdown**
  - Terintegrasi langsung dalam state `WorkoutStatus.countdown` di `WorkoutScreen`.

---

### Tahap 4: Penyempurnaan Layar Latihan (WorkoutScreen & Keypad)
- [x] **4.1 Header Sesi Latihan**
  - Header bersih: Tombol kembali di kiri + Timer berjalan di tengah dengan format `Time MM:SS`.
- [x] **4.2 Tampilan Kartu Soal & Kotak Input**
  - Kotak soal: Kartu putih berbingkai rapi (`#CFD8DC`) dengan font angka besar tebal.
  - Kotak jawaban: Kotak input responsif tepat di bawah soal dengan feedback warna halus (hijau jika benar, merah jika salah).
- [x] **4.3 Penyelarasan Keypad Kustom**
  - Tata letak keypad 3 kolom flat tile:
    - **Phone**: `1 2 3` di baris atas.
    - **Calculator**: `7 8 9` di baris atas.
    - Baris bawah: `[– / .]`, `0`, dan `⌫` (Backspace).
  - Pilihan ukuran keypad: **Normal** vs **Large**.
  - Fitur **Auto Confirm (Lazy Mode)** tetap berfungsi sempurna.

---

### Tahap 5: Fitur Tabel Perkalian & Pembagian Interaktif (Tables Screen)
- [x] **5.1 Tampilan Grid Pemilih Angka (1 s.d. 36)**
  - Tampilan grid 3 kolom berisi kartu angka 1 sampai 36 yang rapi dan responsif di `LearnNumberScreen`.
- [x] **5.2 Tampilan Isi Tabel (1 s.d. 50)**
  - Tampilkan daftar persamaan (misal: $1 \times 11 = 11$, dst.) dengan indikator visual garis biru di sisi kiri.
  - Tab navigasi rentang angka: `[1-10]`, `[11-20]`, `[21-30]`, `[31-40]`, `[41-50]`.
  - Tombol switcher instan antara mode Perkalian (`×`) dan Pembagian (`÷`).
  - Tombol toggle grafik statistik di kiri.
  - Tombol "Practice" di bagian bawah layar untuk langsung latihan kuis tabel angka yang dipilih.

---

### Tahap 6: Halaman Evaluasi & Peninjauan Jawaban (Results & Answers)
- [x] **6.1 Format Tampilan Jawaban Salah (Coret Merah)**
  - Pada `AnswersScreen`:
    - Rekapitulasi: `Correct [N]` (hijau) dan `Wrong [M]` (merah).
    - Centang hijau (✓) untuk jawaban benar.
    - Silang merah (✗) untuk jawaban salah, dengan jawaban salah dicoret merah (`~56~`) diikuti jawaban yang benar (`54`).
- [x] **6.2 Tombol Aksi**
  - Tombol "Play Again" di footer untuk langsung mengulang sesi latihan.

---

### Tahap 7: Layar Pengaturan (Settings Parity)
- [x] **7.1 Penyesuaian Tingkat Kesulitan Standar**
  - Pilihan tingkat kesulitan mencakup: *Easy*, *Medium*, *Hard*, *Challenging*, *Expert*, serta *Custom*.
- [x] **7.2 Pengaturan Terpadu**
  - Akses langsung ke `Language`, `Theme`, `Notifications`, `Keypad`, `Display Time`, `Negative Numbers`, dan `Overall Progress`.
  - Styling AppBar konsisten dengan warna biru `#0288D1`.

---

### Tahap 8: Pengujian, Verifikasi, & QA
- [x] **8.1 Analisis Statis**: `flutter analyze` -> **0 issues found**.
- [x] **8.2 Unit & Integration Test**: `flutter test` -> **3/3 test suite passed**.
- [x] **8.3 Uji Regresi Fitur Eksisting**:
  - Brain Game (Dual N-back) -> Normal.
  - Custom Presets (1-Var & 2-Var) -> Normal.
  - Operasi Lanjutan (Pangkat, Akar, Log, Modulo, Faktorial, Nilai Mutlak) -> Normal.
