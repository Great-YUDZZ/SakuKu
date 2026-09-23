# SakuKu (Pengelola Keuangan & Portofolio)

SakuKu adalah aplikasi pengelola keuangan pribadi, hutang-piutang, dan portofolio investasi multiaset berbasis lokal (offline-first & privacy-focused) yang dibangun menggunakan Flutter dan Dart. Aplikasi ini mengusung arsitektur visual IT-Toolbox Neumorphism Light (Luminous Frosted Glass over Cool Ambient Ice) yang bersih, presisi, dan responsif di berbagai platform: Linux Desktop, Windows, dan Android.

---

## Fitur Utama

### 1. Dasbor Analitik & Statistik Interaktif
- **Statistik Arus Kas (Cash Flow):** Ringkasan total saldo, akumulasi pemasukan, pengeluaran, dan rasio tabungan (Savings Ratio).
- **Grafik Arus Kas Dinamis:** Grafik visual tren keuangan (pemasukan vs pengeluaran) dengan pilihan rentang waktu: Harian, Bulanan, dan Tahunan.
- **Tooltip Rincian Transaksi:** Pratinjau detail transaksi saat titik data pada grafik disentuh atau disorot kursor.
- **Diagram Lingkaran Kategori (Donut Chart):** Visualisasi proporsi pengeluaran dan asal pemasukan berbasis koordinat polar dengan kalkulasi sudut busur dinamis, transisi halus, dan sinkronisasi dua arah (two-way highlight).

### 2. Portofolio Investasi Multiaset
- Mendukung berbagai kelas aset investasi:
  - Saham (Stocks)
  - Reksadana (Mutual Funds)
  - Kripto (Crypto)
  - Obligasi / SBN (Bonds)
  - Emas (Gold)
  - Deposito (Deposit) dan Aset Lainnya
- **Unrealized PnL Real-time:** Perhitungan otomatis nominal keuntungan/kerugian dan persentase ROI (Return on Investment).
- **Quick Price Update:** Pembaruan nilai pasar terkini secara langsung pada kartu aset.
- **Target Progress Tracker:** Visualisasi capaian portofolio terhadap target nominal yang ditentukan.

### 3. Pengelola Hutang & Piutang (Debt & Receivable Manager)
- Mendukung 2 mode pencatatan: Hutang Saya (kewajiban bayar) dan Piutang Saya (hak tagih).
- **Pelunasan Bertahap (Installment):** Fitur pencatatan cicilan/angsuran dengan pembaruan otomatis sisa saldo dan status lunas saat saldo mencapai 0.
- **Due Date Urgency Tracker:**
  - Overdue: Peringatan tegas jika pinjaman telah melewati tanggal jatuh tempo.
  - Due Soon: Peringatan siaga jika jatuh tempo kurang dari atau sama dengan 7 hari.
  - Safe: Status aman jika tanggal jatuh tempo masih di atas 7 hari.

### 4. Kalkulator Finansial & Proyeksi Majemuk
- **Kalkulator Pinjaman Real-time:** Simulasi perbandingan bunga Flat vs Efektif / Anuitas dengan rincian cicilan per bulan, akumulasi bunga, dan total pembayaran akhir.
- **Simulasi Investasi Majemuk (Compound Interest DCA):** Proyeksi nilai masa depan (Future Value) berdasarkan modal awal, setoran bulanan berkala (Dollar-Cost Averaging), dan estimasi imbal hasil tahunan.

### 5. Keamanan, Privasi & Backup Lokal
- **100% Offline-First:** Seluruh data tersimpan secara lokal pada perangkat pengguna menggunakan database SQLite tanpa ketergantungan server eksternal.
- **Pencadangan & Pemulihan (Backup & Restore):** Ekspor dan impor data dalam format JSON yang dilengkapi dengan verifikasi integritas SHA-256 Checksum untuk mencegah manipulasi atau kerusakan berkas.

---

## Desain: IT-Toolbox Neumorphism Light

SakuKu menerapkan standar desain antarmuka IT-Toolbox Neumorphism Light:
- **Warna Latar:** Cool Ambient Ice (#EFF4FA) dengan Sidebar (#E8EEF7) dan Kartu Putih Murni (#FFFFFF).
- **Dual-Layer Shadows:** Kombinasi refleksi cahaya putih (#FFFFFF) di sudut kiri-atas dan bayangan sejuk (#C2D0E2) di sudut kanan-bawah.
- **Debossed Wells:** Input formulir dan selektor bergaya cekung (inset debossed) #F4F7FB.
- **Aksen Warna Semantik:**
  - Cobalt (#2563EB): Aset Investasi & Saham
  - Coral (#DC2626): Pengeluaran, Hutang, Overdue
  - Emerald (#059669): Pemasukan, Keuntungan, Lunas
  - Amber (#D97706): Peringatan Jatuh Tempo Segera
  - Violet (#7C3AED): Proyeksi Majemuk & DCA

---

## Arsitektur & Teknologi

- **Framework:** Flutter (Channel stable, Dart 3.x)
- **Arsitektur:** Model-View-ViewModel (MVVM) dengan Provider / ChangeNotifier
- **Database Lokal:** SQLite (sqflite & sqflite_common_ffi dengan native C-engine)
- **Pemformatan:** intl (Standar mata uang Rupiah id_ID dan tanggal lokal)
- **Tipografi:** Google Fonts (Outfit / Inter)
- **Kriptografi:** crypto (SHA-256 integrity verification)

---

## Memulai (Getting Started)

### Prasyarat
- Flutter SDK >= 3.19.0
- Dart SDK >= 3.2.0
- Untuk Linux: clang, cmake, ninja-build, pkg-config, libgtk-3-dev, libsqlite3-dev

### Menjalankan Aplikasi

1. **Clone repository:**
   ```bash
   git clone https://github.com/Great-YUDZZ/SakuKu.git
   cd SakuKu
   ```

2. **Pasang dependensi:**
   ```bash
   flutter pub get
   ```

3. **Jalankan pengujian (Unit & Widget Tests):**
   ```bash
   flutter test
   ```

4. **Jalankan aplikasi di perangkat pilihan:**
   ```bash
   # Desktop Linux
   flutter run -d linux

   # Desktop Windows
   flutter run -d windows

   # Android Device / Emulator
   flutter run -d android
   ```

---

## Pengujian Otomatis

Aplikasi ini dilengkapi pengujian unit dan widget otomatis:
- `test/unit/financial_calculator_test.dart`: Formula bunga flat, anuitas efektif, compound growth DCA, dan urgensi jatuh tempo.
- `test/unit/portfolio_test.dart`: Kalkulasi entitas hutang, piutang, dan ROI investasi.
- `test/unit/category_pie_chart_test.dart`: Kalkulasi sudut busur diagram lingkaran dan koordinat polar.
- `test/unit/cashflow_chart_test.dart`: Model agregasi arus kas harian, bulanan, dan tahunan.
- `test/unit/backup_test.dart`: Validasi integritas checksum SHA-256 dan verifikasi payload cadangan.
- `test/unit/currency_formatter_test.dart`: Pemformatan dan parsing angka Rupiah.

---

## Lisensi

Didistribusikan di bawah lisensi MIT. Silakan lihat berkas LICENSE untuk informasi lebih lanjut.
