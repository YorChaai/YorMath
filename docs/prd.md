# Product Requirements Document (PRD) — Math Workout (MVP)

## 1. Gambaran Umum Produk
**Math Workout** adalah aplikasi latihan matematika kilat (mental arithmetic) berbasis kuis yang berjalan secara offline. Aplikasi ini bertujuan melatih kemampuan berhitung pengguna melalui operasi matematika mulai dari tingkat dasar hingga lanjut. 

Sesuai dengan pendekatan *Agile*, MVP (Minimum Viable Product) tahap pertama ini akan berfokus penuh pada fundamental aplikasi, yaitu halaman **Home** dan **Settings**, sebelum mengimplementasikan logic kuis secara utuh.

**Keputusan Arsitektur**: **Flutter Only**
Untuk MVP, kita akan menggunakan **Flutter Only** tanpa backend Python/FastAPI. Semua logika (Question Generator, Evaluasi Jawaban, Penyimpanan Setting & Statistik) dapat dijalankan secara efisien di sisi client (local device) menggunakan Flutter dan penyimpanan lokal (seperti `shared_preferences` atau `hive`). Backend tidak diperlukan untuk saat ini karena aplikasi bersifat personal dan tidak membutuhkan sinkronisasi cloud.

## 2. Fitur Utama MVP (Fokus Sprint 1)

### A. Home Screen
- Menampilkan judul aplikasi "Math Workout".
- Menampilkan daftar mode latihan dalam bentuk *scrollable list*.
- Pada layar besar (seperti monitor PC), lebar daftar kuis (tombol-tombol latihan) dibatasi maksimum 500 pixel agar tidak memanjang secara tidak wajar, posisi di tengah layar (*Center*).
- Mode latihan yang akan ditampilkan (UI Only pada tahap ini):
  - Operasi Dasar: Addition, Subtraction, Multiplication, Division.
  - Mode Tambahan: Multiplication Tables, Mixed, Square Root, Exponents, Arithmetic Memory.
  - **Customizable Mode / Custom Presets**: Untuk menjalankan latihan dari preset kustomisasi pengguna.
- Tombol navigasi menuju halaman Settings.

### B. Settings Screen
Halaman pengaturan utama dengan opsi:
- **Sounds**: Toggle ON/OFF.
- **Difficulty**: Pilihan Preset Standard (Easy, Medium, Hard, Challenging, Expert) dan pintu masuk untuk opsi **Custom**.
- **Questions Count**: Pilihan 10, 20, atau 40.
- **Language**: Dropdown pilihan bahasa (implementasi UI multi-bahasa dasar).
- **Theme**: Pilihan tema warna aplikasi.
- **Keypad**: Pengaturan ukuran (Normal/Large) dan tipe (Phone vs Calculator), serta toggle Auto Confirm.
- **Display Time**: Toggle ON/OFF untuk menampilkan timer saat latihan.

### C. Advanced Custom Difficulty (Fitur Baru Khusus Custom)
Jika pengguna memilih **Custom** pada menu Difficulty, pengguna akan diarahkan ke halaman khusus pengaturan Custom:
- **Tab 1: Operasi 2 Variabel ($x$ dan $y$)**
  - Pilih jenis operasi (Penjumlahan, Pengurangan, Perkalian, Pembagian, Pecahan, Perbandingan).
  - Set panjang digit untuk $x$ (1–10 digit) dan $y$ (1–10 digit).
- **Tab 2: Operasi 1 Variabel ($x$)**
  - Pilih jenis operasi (Pangkat, Akar, Persentase, Faktorial, Nilai Mutlak, Logaritma, Modulo).
  - Set panjang digit untuk $x$ (1–10 digit).
- **Simpan Preset**: Pop-up untuk memasukkan nama preset (misal: "Latihan Log & Faktorial").
- **Saved Presets**: Menampilkan daftar preset custom yang sudah disimpan agar bisa dipanggil kembali.

## 3. Scope di Luar MVP Tahap 1
- Logika Question Generator yang kompleks (termasuk validasi hasil desimal, negatif, overflow faktorial).
- Halaman Sesi Latihan (Workout Session) dan Keypad Input layar penuh.
- Halaman Hasil Latihan dan Statistik.
- Integrasi Backend/API.
