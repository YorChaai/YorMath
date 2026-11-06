# Product Requirements Document (PRD) — Math Workout

## 1. Gambaran Umum

**Math Workout** adalah aplikasi latihan matematika berbasis kuis yang memungkinkan pengguna berlatih operasi aritmatika dan meningkatkan kemampuan berhitung melalui soal yang dapat disesuaikan.

Berdasarkan tampilan yang diberikan, aplikasi memiliki fokus utama pada:

- Latihan operasi matematika.
- Pemilihan tingkat kesulitan.
- Jumlah soal.
- Berbagai mode latihan.
- Pengaturan bahasa.
- Pengaturan tema.
- Pengaturan keypad.
- Pengaturan suara, notifikasi, dan tampilan waktu.
- Fitur Arithmetic Memory.
- Fitur Multiplication Tables.
- Mode soal gabungan/mixed.
- Fitur Customizable.Berdasarkan tampilan yang diberikan, aplikasi memiliki fokus utama pada:

Latihan operasi matematika.

Pemilihan tingkat kesulitan.

Jumlah soal.

Berbagai mode latihan.

Pengaturan bahasa.

Pengaturan tema.

Pengaturan keypad.

Pengaturan suara, notifikasi, dan tampilan waktu.

Fitur Arithmetic Memory.

Fitur Multiplication Tables.

Mode soal gabungan/mixed.

Fitur Customizable.

---

# 2. Struktur Aplikasi

Struktur utama aplikasi yang terlihat:

```text
Math Workout
│
├── Home
│   ├── Addition
│   ├── Subtraction
│   ├── Multiplication
│   ├── Division
│   ├── Customizable
│   ├── Multiplication Tables
│   ├── Addition & Subtraction
│   ├── Multiplication & Division
│   ├── Mixed
│   └── Arithmetic Memory
│
└── Settings
    ├── Sounds
    ├── Difficulty
    ├── Questions
    ├── Language
    ├── Theme
    ├── Notifications
    ├── Keypad
    ├── Rate
    ├── Feedback
    └── Display Time
```

Selain itu, dari screenshot terlihat terdapat tambahan mode:

- Square Root
- Exponents

Keduanya muncul pada bagian bawah daftar latihan.

---

# 3. Home Screen

## 3.1 Header

Home screen memiliki:

- Judul **Math Workout**
- Tombol **Settings** berbentuk ikon gear.
- Area scroll untuk daftar latihan.

## 3.2 Mode Latihan

### Addition

Latihan khusus operasi penjumlahan.

Contoh jenis soal:

```text
12 + 8 = ?
25 + 17 = ?
```

### Subtraction

Latihan khusus operasi pengurangan.

```text
20 - 7 = ?
45 - 18 = ?
```

### Multiplication

Latihan perkalian.

```text
7 × 8 = ?
12 × 6 = ?
```

### Division

Latihan pembagian.

```text
48 ÷ 6 = ?
81 ÷ 9 = ?
```

### Customizable

Mode yang memungkinkan pengguna menentukan konfigurasi latihan sendiri.

Konfigurasi yang idealnya dapat disediakan:

- Operasi matematika.
- Rentang angka.
- Tingkat kesulitan.
- Jumlah soal.
- Penggunaan angka negatif.
- Penggunaan desimal jika level mendukung.
- Penggunaan pangkat/akar jika diaktifkan.

### Multiplication Tables

Mode khusus untuk menghafal dan melatih tabel perkalian.

Contoh:

```text
7 × 8 = ?
9 × 6 = ?
12 × 7 = ?
```

Mode ini berbeda dari **Multiplication** karena fokusnya adalah latihan tabel perkalian.

### Addition & Subtraction

Menggabungkan:

```text
+
-
```

Soal dapat muncul secara bergantian.

### Multiplication & Division

Menggabungkan:

```text
×
÷
```

### Mixed

Mode latihan gabungan.

Dapat mencampurkan:

```text
+
-
×
÷
```

Pada pengembangan berikutnya dapat diperluas dengan:

```text
√
x²
xⁿ
%
mod
```

### Arithmetic Memory

Mode latihan yang berfokus pada kemampuan mengingat dan menghitung informasi aritmatika.

Mode ini sebaiknya memiliki mekanisme khusus sehingga tidak hanya menjadi soal matematika biasa.

### Square Root

Latihan akar kuadrat.

Contoh:

```text
√25 = ?
√81 = ?
√144 = ?
```

### Exponents

Latihan perpangkatan.

Contoh:

```text
2² = ?
3³ = ?
5² = ?
```

---

# 4. Sistem Soal

Setiap mode latihan menggunakan sistem soal matematika yang dapat menghasilkan soal secara dinamis.

## 4.1 Question Generator

Generator bertanggung jawab untuk:

- Membuat operand.
- Memilih operator.
- Menentukan rentang angka.
- Menentukan tingkat kesulitan.
- Memastikan soal valid.
- Menghasilkan jawaban yang benar.
- Menghindari soal yang terlalu mudah/berulang apabila diperlukan.

## 4.2 Validasi Jawaban

Pengguna memasukkan jawaban melalui keypad.

Sistem kemudian:

```text
Input User
    ↓
Parse Answer
    ↓
Compare dengan Answer
    ↓
Correct / Incorrect
    ↓
Update Score
    ↓
Next Question
```

---

# 5. Difficulty

Pengguna dapat memilih lima tingkat kesulitan:

1. **Easy**
2. **Medium**
3. **Hard**
4. **Challenging**
5. **Expert**

Tingkat kesulitan harus memengaruhi kompleksitas soal, bukan sekadar memperbesar angka.

Contoh:

### Easy

```text
7 + 4
12 - 5
3 × 6
20 ÷ 4
```

### Medium

```text
47 + 38
82 - 47
12 × 8
144 ÷ 12
```

### Hard

```text
125 × 24
864 ÷ 18
347 - 189
```

### Challenging

Dapat mulai menggunakan kombinasi operasi atau angka yang lebih kompleks.

### Expert

Dapat mencakup:

- angka lebih besar;
- operasi gabungan;
- pangkat;
- akar;
- pecahan;
- modulus;
- operasi negatif;
- dan kombinasi beberapa konsep matematika.

---

# 6. Question Count

Pengguna dapat memilih jumlah pertanyaan:

- **10**
- **20**
- **40**

Jumlah ini menentukan panjang satu sesi latihan.

Contoh:

```text
Questions: 20

Question 1 / 20
Question 2 / 20
...
Question 20 / 20
```

---

# 7. Language

Aplikasi memiliki sistem multi-language.

Bahasa yang terlihat pada screenshot:

- English
- Español
- Português
- Français
- Deutsch
- Italiano
- Русский
- Հայերեն
- 简体中文
- 繁體中文

Sistem harus menggunakan localization sehingga teks UI tidak ditulis secara hard-code.

Struktur ideal:

```text
English
Indonesian
Spanish
Portuguese
French
German
Italian
Russian
Armenian
Simplified Chinese
Traditional Chinese
...
```

Bahasa dapat dikembangkan tanpa mengubah logic aplikasi.

---

# 8. Theme

Aplikasi memiliki menu pemilihan tema.

Tema yang terlihat:

- Default
- Dark Green
- Dark Blue
- Light Green
- Dark Purple
- Light Purple
- Light Red
- Light Orange

Setiap tema memiliki kombinasi warna:

```text
Primary Color
Secondary Color
Background Color
```

Tema harus diterapkan secara global ke seluruh aplikasi.

---

# 9. Settings

## 9.1 Sounds

Toggle untuk mengaktifkan/nonaktifkan suara.

Jika aktif, aplikasi dapat memberikan feedback suara ketika:

- Jawaban benar.
- Jawaban salah.
- Sesi selesai.
- Tombol ditekan.

---

## 9.2 Difficulty

Membuka dialog pilihan:

```text
○ Easy
○ Medium
○ Hard
○ Challenging
○ Expert
```

Terdapat tombol:

```text
Cancel
Confirm
```

Pemilihan tidak langsung diterapkan sampai pengguna menekan confirm.

---

## 9.3 Questions

Pilihan jumlah soal:

```text
10 | 20 | 40
```

Pilihan yang aktif ditandai dengan indikator warna/garis.

---

## 9.4 Language

Dropdown bahasa.

Saat pengguna memilih bahasa, seluruh UI harus berubah mengikuti bahasa tersebut.

---

## 9.5 Theme

Membuka halaman pemilihan tema.

Setiap tema ditampilkan sebagai:

```text
Theme Name    ● ● ●
```

Tiga lingkaran merepresentasikan warna utama tema.

---

## 9.6 Notifications

Menu untuk mengatur notifikasi aplikasi.

Contoh penggunaan:

- Reminder latihan.
- Pengingat latihan harian.
- Notifikasi progress.

---

## 9.7 Keypad

Menu konfigurasi keypad.

Memiliki dua pengaturan utama.

### Keypad Size

```text
Normal
Large
```

### Keypad Type

```text
Phone
Calculator
```

### Auto Confirm

Toggle:

```text
ON / OFF
```

Jika aktif, sistem dapat otomatis memproses jawaban setelah input dianggap lengkap.

---

# 10. Keypad

Keypad merupakan input utama untuk menjawab soal.

Mode **Phone** menggunakan layout seperti:

```text
1 2 3
4 5 6
7 8 9
  0 ←
```

Terdapat tombol delete/backspace.

Mode **Calculator** dapat menggunakan layout yang lebih menyerupai kalkulator.

Ukuran keypad:

```text
Normal
Large
```

harus memengaruhi ukuran tombol tanpa mengubah fungsi.

---

# 11. Feedback Jawaban

Setiap jawaban harus menghasilkan feedback yang jelas.

### Correct

```text
Correct
```

Sistem:

- Menambah jumlah jawaban benar.
- Menghitung skor.
- Melanjutkan ke soal berikutnya.

### Incorrect

```text
Incorrect
```

Sistem:

- Menambah jumlah kesalahan.
- Memberikan jawaban yang benar bila fitur tersebut tersedia.
- Melanjutkan atau meminta pengguna mencoba kembali sesuai mode.

---

# 12. Session / Workout

Setiap latihan merupakan sebuah session.

Contoh:

```text
Addition

Question 7 / 20

15 + 28 = ?

[ 43 ]
```

Data yang perlu dicatat:

```text
Total Questions
Correct Answers
Wrong Answers
Accuracy
Time
Score
```

---

# 13. Hasil Latihan

Setelah semua pertanyaan selesai, aplikasi menampilkan hasil.

Contoh:

```text
Workout Complete

Score       17 / 20
Accuracy    85%
Correct     17
Incorrect   3
Time        01:42
```

Kemudian tersedia:

```text
Retry
Back to Home
```

---

# 14. Display Time

Pengaturan **Display Time** menentukan apakah informasi waktu ditampilkan selama latihan.

Jika ON:

```text
Time: 01:24
```

Jika OFF:

informasi waktu disembunyikan.

Pengaturan ini sebaiknya tidak mengubah mekanisme scoring kecuali memang terdapat mode time-based.

---

# 15. Arithmetic Memory

Mode ini perlu dipisahkan dari latihan aritmatika biasa.

Konsep yang dapat digunakan:

```text
5 + 7 = 12
```

Jawaban atau ekspresi ditampilkan sebentar.

Kemudian disembunyikan.

Pengguna harus mengingat informasi tersebut dan menjawab pertanyaan berikutnya.

Tujuannya adalah melatih:

- Working memory.
- Mental arithmetic.
- Konsentrasi.
- Kecepatan menghitung.

---

# 16. Progress & Statistics

Aplikasi sebaiknya menyimpan statistik latihan secara lokal.

Data:

```text
Mode
Difficulty
Questions
Correct
Incorrect
Accuracy
Time
Score
Date
```

Statistik dapat digunakan untuk:

- Melihat perkembangan.
- Mengetahui operasi yang paling lemah.
- Melihat akurasi.
- Melihat jumlah latihan.

Contoh:

```text
Addition       94%
Subtraction    88%
Multiplication 76%
Division       71%
```

Dengan demikian aplikasi tidak hanya menjadi generator soal, tetapi menjadi sistem latihan.

---

# 17. Navigation

Struktur navigasi:

```text
Home
 │
 ├── Addition ──────────> Workout
 ├── Subtraction ──────> Workout
 ├── Multiplication ────> Workout
 ├── Division ──────────> Workout
 ├── Customizable ──────> Custom Workout
 ├── Multiplication Tables
 ├── Addition & Subtraction
 ├── Multiplication & Division
 ├── Mixed
 ├── Arithmetic Memory
 ├── Square Root
 └── Exponents

Settings
 │
 ├── Sounds
 ├── Difficulty
 ├── Questions
 ├── Language
 ├── Theme
 ├── Notifications
 ├── Keypad
 ├── Rate
 ├── Feedback
 └── Display Time
```

---

# 18. Rate

Menu **Rate** digunakan untuk mengarahkan pengguna memberikan rating aplikasi pada platform tempat aplikasi didistribusikan.

---

# 19. Feedback

Menu **Feedback** digunakan untuk mengirimkan feedback kepada developer.

Jenis feedback dapat berupa:

- Bug.
- Saran fitur.
- Masalah UI.
- Masalah soal.
- Masalah terjemahan.

---

# 20. Data & Persistence

Pengaturan pengguna harus disimpan sehingga tidak kembali ke default setiap aplikasi dibuka.

Minimal yang disimpan:

```text
language
theme
difficulty
questionCount
soundEnabled
notificationEnabled
displayTime
keypadSize
keypadType
autoConfirm
```

Progress latihan juga dapat disimpan secara lokal.

---

# 21. Prinsip Question Generation

Ini bagian penting.

Jangan membuat generator yang hanya menghasilkan angka random.

Generator harus mempertimbangkan:

```text
Operation
+
Difficulty
+
Number Range
+
Valid Result
+
Question Variety
```

Contohnya untuk division:

Jangan menghasilkan:

```text
17 ÷ 5 = 3.4
```

jika level tersebut memang ditujukan untuk pembagian bilangan bulat.

Lebih baik:

```text
45 ÷ 5 = 9
```

Sedangkan level lebih tinggi dapat memperkenalkan desimal atau pecahan.

---

# 22. Operator Matematika yang Dapat Dikembangkan

Saat ini screenshot menunjukkan:

```text
+
-
×
÷
√
Exponent
```

Untuk pengembangan berikutnya, aplikasi dapat menambahkan:

```text
%
Modulus
Floor Division
Fraction
Decimal
Negative Numbers
Absolute Value
Logarithm
Factorial
```

Namun **jangan memasukkan semuanya sekaligus ke Mixed**. Itu akan membuat mode Mixed kehilangan struktur kesulitan.

Lebih baik operator diperkenalkan secara bertahap berdasarkan difficulty.

---

# 23. Prioritas Fitur

## P0 — Core

Wajib:

- Addition
- Subtraction
- Multiplication
- Division
- Question Generator
- Answer Input
- Correct/Incorrect
- Score
- Difficulty
- Question Count
- Keypad
- Workout Result

## P1 — Existing Features

- Customizable
- Multiplication Tables
- Addition & Subtraction
- Multiplication & Division
- Mixed
- Arithmetic Memory
- Square Root
- Exponents
- Theme
- Language
- Sounds
- Display Time
- Auto Confirm

## P2 — Enhancement

- Statistics
- Progress
- History
- Daily Workout
- Streak
- Weak-operation detection
- More advanced operators
- Achievement system

---

# 24. Kesimpulan Produk

Secara konsep, **Math Workout** bukan sekadar kalkulator. Produk ini lebih tepat didefinisikan sebagai:

> **Aplikasi latihan mental arithmetic yang menggunakan generator soal, tingkat kesulitan, mode latihan, konfigurasi pengguna, dan tracking progress untuk meningkatkan kemampuan berhitung.**

Struktur yang terlihat sekarang sudah memiliki fondasi yang cukup jelas:

**Home → pilih jenis latihan → konfigurasi → workout → hasil → statistik.**

Bagian yang belum terlihat dari screenshot adalah **layar pengerjaan soal dan layar hasil akhir**. Dua bagian tersebut merupakan bagian inti yang masih perlu ditentukan desain dan behavior-nya sebelum implementasi final.
