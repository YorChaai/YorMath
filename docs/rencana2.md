Berikut adalah **dokumen PRD yang sudah disempurnakan, dirapikan, dan diperbarui** secara menyeluruh.

Bagian **Customizable Mode/Difficulty** telah disesuaikan dengan konsep terbaru (2 jenis kategori operasi, rentang 1–10 digit untuk $x$ dan $y$, alur pembuatan preset, _pop-up_ simpan, hingga _slot management_). Cakupan operator matematika juga telah diperluas dan dikelompokkan secara rapi.

---

# Product Requirements Document (PRD) — Math Workout

## 1. Gambaran Umum

**Math Workout** adalah aplikasi latihan matematika berbasis kuis yang dirancang untuk membantu pengguna mengasah kemampuan berhitung kilat (_mental arithmetic_) secara sistematis, terstruktur, dan dapat disesuaikan (_customizable_).

### Fokus Utama Aplikasi

- **Latihan Operasi Matematika:** Mendukung aritmatika dasar hingga tingkat lanjut (pangkat, akar, faktorial, logarithm, dll.).
- **Sistem Fleksibilitas Tinggi:** Dukungan preset tingkat kesulitan maupun _Custom Difficulty_ berbasis jumlah digit.
- **Berbagai Mode Latihan:** Mode Spesifik, Mode Kombinasi (_Mixed_), Mode Tabel Perkalian, dan _Arithmetic Memory_.
- **Pengalaman Pengguna (UX) & Kustomisasi UI:** Pengaturan Bahasa, Tema Tampilan (Dark/Light), Ukuran & Tata Letak _Keypad_, Efek Suara, Notifikasi, serta _Display Time_.

---

## 2. Cakupan Operasi Matematika

Untuk menjaga struktur logika soal, operasi matematika dibagi menjadi 2 kategori utama berdasarkan jumlah variabelnya:

### A. Operasi 2 Variabel ($x$ dan $y$)

1. **Penjumlahan:** $+$
2. **Pengurangan:** $-$
3. **Perkalian:** $\times$
4. **Pembagian:** $\div$
5. **Pecahan:** $\frac{a}{b}$
6. **Perbandingan:** $<, >, \le, \ge$

### B. Operasi 1 Variabel ($x$)

1. **Pangkat / Eksponen:** $x^2, x^3, x^n$
2. **Akar:** $\sqrt{x}, \sqrt[3]{x}$
3. **Persentase:** $\%$
4. **Faktorial:** $n!$
5. **Nilai Mutlak:** $\vert{}x\vert{}$
6. **Logaritma:** $\log(x)$
7. **Modulo / Sisa Pembagian:** $\%$ _(konsep pemrograman)_

---

## 3. Sistem Tingkat Kesulitan (Difficulty)

Aplikasi memiliki dua metode pemilihan tingkat kesulitan:

### 3.1 Preset Standard (Default)

Terdapat 5 tingkatan default yang terkonfigurasi secara otomatis:

1. **Easy:** Operasi dasar 1–2 digit, tanpa komplikasi.
2. **Medium:** Operasi 2 digit atau kombinasi angka lebih besar.
3. **Hard:** Operasi 3 digit atau pembagian/perkalian kompleks.
4. **Challenging:** Angka besar dengan variasi operasi.
5. **Expert:** Angka kompleks (hingga 4+ digit), desimal, atau gabungan fungsi khusus.

### 3.2 Advanced Custom Difficulty (Fitur Baru)

Jika pengguna memilih **Custom**, aplikasi tidak menggunakan preset Easy–Expert, melainkan memberikan kendala digit yang diset penuh oleh pengguna (rentang **1 hingga 10 digit**).

#### Alur & Mekanisme Pengaturan Custom (_User Flow_)

```
[ Dropdown Difficulty ] ───> Pilih "Custom" ───> [ Halaman Custom Settings ]
                                                          │
                                     ┌────────────────────┴────────────────────┐
                                     ▼                                         ▼
                        [ Tab Operasi 2 Variabel ]                [ Tab Operasi 1 Variabel ]
                        (Penjumlahan, Pecahan, dll)               (Faktorial, Log, Mutlak, dll)
                                     │                                         │
                        Set Digit x & Digit y                     Set Digit x
                        (Rentang 1–10 Digit)                      (Rentang 1–10 Digit)
                                     │                                         │
                                     └────────────────────┬────────────────────┘
                                                          │
                                                 [ Klik "Simpan" ]
                                                          │
                                               [ Pop-up Input Nama ]
                                                          │
                                         [ Tersimpan di Kolom Saved Presets ]

```

1. **Akses Halaman Custom:** Ketika pengguna memilih opsi _Custom_ di menu _Difficulty_, sistem secara otomatis mengarahkan pengguna ke halaman **Custom Difficulty Settings**.
2. **Pengelompokan Dua Jenis (Tab):**

- **Jenis 1 (Operasi 2 Variabel - $x, y$):** Pengguna memilih jenis operasi (misal: Penjumlahan) lalu mengatur panjang digit untuk $x$ (1–10) dan $y$ (1–10). _Contoh: $xx + xxx$ (2 digit $+ 3$ digit)._
- **Jenis 2 (Operasi 1 Variabel - $x$ saja):** Pengguna memilih operasi single-variable (misal: Faktorial, Logaritma, Nilai Mutlak) dan cukup mengisi panjang digit untuk $x$ (1–10). _Contoh: $xxx!$ (3 digit faktorial)._

3. **Penyimpanan Preset:** Pengguna menekan tombol **Simpan**.
4. **Pop-up Naming:** Tampil _pop-up modal_ untuk memasukkan nama preset (misal: _"Latihan Log & Faktorial 2 Digit"_).
5. **Saved Presets Column:** Preset tersimpan di slot/kolom _Saved Custom Presets_ dan dapat dipanggil kembali kapan saja di menu utama.

---

## 4. Struktur Navigasi Aplikasi

```
Math Workout
│
├── Home
│   ├── Addition
│   ├── Subtraction
│   ├── Multiplication
│   ├── Division
│   ├── Multiplication Tables
│   ├── Addition & Subtraction
│   ├── Multiplication & Division
│   ├── Mixed
│   ├── Square Root
│   ├── Exponents
│   ├── Arithmetic Memory
│   └── Customizable Mode / Custom Presets
│
└── Settings
    ├── Sounds (Toggle ON/OFF)
    ├── Difficulty (Easy, Medium, Hard, Challenging, Expert, Custom)
    ├── Questions Count (10, 20, 40)
    ├── Language (Multi-language Support)
    ├── Theme (Light/Dark variants)
    ├── Notifications (Daily Reminders)
    ├── Keypad (Size & Layout Configuration)
    ├── Display Time (Toggle Timer ON/OFF)
    ├── Rate App
    └── Feedback

```

---

## 5. Detail Mode Latihan Utama

| Mode Latihan                  | Deskripsi & Contoh                                                                                                              |
| ----------------------------- | ------------------------------------------------------------------------------------------------------------------------------- |
| **Addition**                  | Latihan khusus penjumlahan. _Contoh: $12 + 8 = ?$_                                                                              |
| **Subtraction**               | Latihan khusus pengurangan. _Contoh: $45 - 18 = ?$_                                                                             |
| **Multiplication**            | Latihan perkalian acak. _Contoh: $7 \times 8 = ?$_                                                                              |
| **Division**                  | Latihan pembagian bilangan bulat valid. _Contoh: $81 \div 9 = ?$_                                                               |
| **Multiplication Tables**     | Mode fokus hafalan tabel perkalian ($1 \times 1$ hingga $12 \times 12$).                                                        |
| **Addition & Subtraction**    | Kombinasi acak antara $+$ dan $-$.                                                                                              |
| **Multiplication & Division** | Kombinasi acak antara $\times$ dan $\div$.                                                                                      |
| **Mixed Mode**                | Pencampuran seluruh operator sesuai tingkatan _Difficulty_.                                                                     |
| **Square Root & Exponents**   | Operasi akar ($\sqrt{x}$) dan perpangkatan ($x^n$).                                                                             |
| **Arithmetic Memory**         | Soal ditampilkan dalam durasi singkat lalu disembunyikan. Pengguna menjawab berdasarkan ingatan untuk melatih _working memory_. |
| **Custom Mode**               | Menjalankan latihan dari preset kustomisasi yang telah dibuat pengguna.                                                         |

---

## 6. Logic & Engine Soal (Question Generator)

Generator soal **tidak boleh** sekadar memunculkan angka acak. Generator wajib mematuhi logika berikut:

### 6.1 Alur Validasi Soal

```
  [ Pilih Mode & Difficulty/Preset ]
                 │
                 ▼
     [ Generate Operand x (dan y) ]
                 │
                 ▼
     [ Evaluasi Validasi Hasil ] ──────> (Tidak Valid) ───┐
                 │                                         │
            (Valid)                                        │ (Generate Ulang)
                 ▼                                         │
       [ Tampilkan Soal ke User ] <────────────────────────┘

```

### 6.2 Aturan Validasi Khusus:

- **Pembagian ($\div$):** Hasil harus berupa bilangan bulat pada tingkat dasar (kecuali pada mode desimal/expert yang diizinkan). Hindari $17 \div 5 = 3.4$ jika di preset awal.
- **Pengurangan ($-$):** Menghindari hasil negatif pada tingkat _Easy_, kecuali pengguna mengaktifkan opsi _Negative Numbers_.
- **Akar ($\sqrt{x}$):** Menghasilkan angka kuadrat sempurna pada tingkat dasar ($\sqrt{144} = 12$).
- **Faktorial ($n!$):** Membatasi batas maksimum angka agar tidak terjadi _overflow_ angka pada UI.

---

## 7. Pengaturan Sistem & UI/UX

### 7.1 Configuration & Customization

- **Jumlah Soal:** Pilihan 10, 20, atau 40 soal per sesi latihan.
- **Sistem Tema:** Pilihan tema (_Default, Dark Green, Dark Blue, Light Green, Dark Purple, Light Red, Light Orange_) yang berdampak pada warna primer, sekunder, dan latar belakang secara global.
- **Localization:** Teks UI tidak di-_hardcode_ untuk mendukung Multi-Bahasa (_English, Indonesian, Spanish, French, German, Chinese_, dll.).

### 7.2 Keypad System

- **Layout Mode:**
- **Phone Layout:** Tombol $1\text{–}3$ di paling atas.
- **Calculator Layout:** Tombol $7\text{–}9$ di paling atas.

- **Keypad Size:** _Normal_ dan _Large_.
- **Auto Confirm Toggle:** Jika **ON**, jawaban diproses secara otomatis saat jumlah digit input memenuhi panjang jawaban yang benar. Jika **OFF**, pengguna menekan tombol _Submit/Enter_.

---

## 8. Sesi Latihan & Hasil (Workout Result)

### 8.1 Sesi Berjalan

Saat kuis berlangsung, layar menampilkan:

- Nomor Soal saat ini (misal: _Question 7 / 20_).
- Timer / _Display Time_ (jika diaktifkan).
- Input Jawaban & Keypad.

### 8.2 Layar Hasil (Workout Complete)

Setelah soal terakhir diselesaikan, tampil ringkasan statistik:

- **Total Score:** Jumlah jawaban benar vs total soal (misal: $17 / 20$).
- **Akurasi (%):** Persentase keberhasilan.
- **Correct / Incorrect Count:** Rincian jawaban benar dan salah.
- **Time Spent:** Total waktu pengerjaan.
- **Aksi Tambahan:** Tombol _Retry_ (Ulangi) & _Back to Home_.

---

## 9. Skala Prioritas Fitur (Product Roadmap)

### P0 — Core (Wajib Ada di MVP)

- Operasi Dasar ($+, -, \times, \div$).
- Question Generator Engine & Validasi Jawaban.
- Preset Difficulty Standard (Easy – Expert).
- Selection Question Count (10, 20, 40).
- Keypad Input (Phone & Calculator Layout).
- Layar Sesi Workout & Ringkasan Hasil.

### P1 — Existing & Extended Features

- Advanced Custom Difficulty (2 Kategori Operasi, 1–10 Digit, Pop-up Save, Saved Preset Slots).
- Mode Latihan Tambahan (_Multiplication Tables, Mixed, Square Root, Exponents, Arithmetic Memory_).
- Operasi Matematika Lanjutan ($\%, n!, \vert{}x\vert{}, \log(x), \frac{a}{b}, \text{Modulo}$).
- Pengaturan Tema, Multi-Bahasa, Suara, dan Timer.
- Auto Confirm & Keypad Resizing.

### P2 — Enhancement & Engagement

- Local Data Persistence & Statistics History.
- Grafis Perkembangan Akurasi & Deteksi Operasi Terlemah.
- Daily Streak & Achievement System.
