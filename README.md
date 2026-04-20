# ☕ Panasea Order System | Smart Cashier & Management System 📊

Selamat datang di repository **Panasea Order System**. Aplikasi ini adalah solusi digital untuk manajemen operasional kedai kopi, mulai dari sistem kasir (Point of Sale) hingga pelaporan penjualan harian untuk manajemen/owner.

---

## 👤 Anggota Team The Kuncir (Kelompok 6) Kelas C

1. **Nabil Daffa Athalasyah** | 2409116090
2. **Moreno Ferdinand Farhantino** | 2409116097
3. **Danial Hirzan Akbary** | 2409116098
4. **Reswara Ganendra Rashi Dewa** | 2409116100
   
* **Mata Kuliah**: Praktikum Pemrograman Aplikasi Bergerak 2026
* **Framework**: Flutter
* **Backend**: Supabase (Database & Auth)

---

## 📝 Deskripsi Aplikasi

**Panasea Order System** hadir sebagai solusi digital untuk memodernisasi operasional kedai kopi dari sistem manual ke ekosistem berbasis cloud. Aplikasi ini dirancang untuk mengatasi masalah klasik UMKM, seperti risiko kehilangan data transaksi dan ketidakakuratan rekapitulasi harian. Dengan integrasi Flutter dan Supabase, kasir dapat memproses pesanan pelanggan dengan jauh lebih cepat dan akurat, sementara seluruh data tersimpan secara aman di server pusat.

Keunggulan utama sistem ini terletak pada transparansi dan aksesibilitasnya, pemilik usaha dapat memantau total omzet serta riwayat transaksi secara real-time dari mana saja tanpa harus berada di lokasi. Selain meminimalisir human error, aplikasi ini memastikan manajemen keuangan menjadi lebih rapi, profesional, dan terkontrol. Dengan antarmuka yang intuitif, Panasea Order System mengubah cara pengelolaan kedai menjadi lebih efisien, membantu pemilik usaha mengambil keputusan berbasis data yang akurat untuk kemajuan bisnis ke depannya.

---

## 🚀 Fitur Utama

1.  **Sistem Kasir (Order Entry)**: Input menu pesanan customer secara dinamis.
2.  **Manajemen Transaksi (CRUD)**: Menambah, melihat, mengedit, dan menghapus data transaksi/pesanan.
3.  **Laporan Penjualan Harian**: Dashboard khusus bagi Manager/Owner untuk melihat total pendapatan per hari.
4.  **Autentikasi User**: Login aman menggunakan Supabase Auth untuk Staff dan Owner.
5.  **Real-time Database**: Sinkronisasi data instan antara aplikasi kasir dan dashboard owner.
6.  **Dual Theme Support**: Mendukung tampilan Light Mode dan Dark Mode.

---

## 🛠️ Widget yang Digunakan

Aplikasi ini dibangun menggunakan berbagai widget Flutter untuk menciptakan UI yang responsif:
* **Layout**: `Scaffold`, `Container`, `Column`, `Row`, `Padding`, `SizedBox`, `Expanded`, `Stack`.
* **Navigation**: `GetMaterialApp`, `BottomNavigationBar`, `Drawer`.
* **Form & Input**: `TextField`, `TextFormField`, `IconButton`, `ElevatedButton`.
* **Data Display**: `ListView.builder` (untuk daftar menu & riwayat), `Card`, `ListTile`, `FutureBuilder`, `Obx`.
* **Feedback**: `Get.snackbar`, `CircularProgressIndicator`.

---

## 📦 Penjelasan Package

Untuk meningkatkan fungsionalitas aplikasi, kami menggunakan beberapa library pihak ketiga:

1.  **`get` (GetX)**: Digunakan sebagai *State Management* untuk mengelola logika keranjang belanja dan navigasi antar halaman tanpa *context*.
2.  **`supabase_flutter`**: Library utama untuk menghubungkan aplikasi dengan database PostgreSQL dan sistem autentikasi Supabase.
3.  **`flutter_dotenv`**: Digunakan untuk keamanan data sensitif (API Key dan URL Supabase) agar tidak terekspos langsung di dalam kode sumber.
4.  **`google_fonts`**: Digunakan untuk kustomisasi tipografi agar tampilan aplikasi lebih modern dan profesional.
5.  **`intl`**: Digunakan untuk memformat mata uang (IDR) dan tanggal pada laporan penjualan agar mudah dibaca.

---

## 📸 Dokumentasi Aplikasi

| Landing Page | Login Page | Input Pesanan | Riwayat Penjualan |
| :---: | :---: | :---: | :---: |
|<img width="608" height="868" alt="Screenshot 2026-04-20 210821" src="https://github.com/user-attachments/assets/a0643b5c-6395-4bbf-8298-0e163b0147ec" />|<img width="608" height="866" alt="image" src="https://github.com/user-attachments/assets/2981c33d-2059-4c9f-adb5-be38799d813d" />|<img width="607" height="865" alt="image" src="https://github.com/user-attachments/assets/d69fcd3e-86c8-4d83-8328-b3ac1cbd388a" />|<img width="606" height="866" alt="image" src="https://github.com/user-attachments/assets/0cb1f6f2-1cbf-44d1-a1c3-6e54093e086c" />


---

## ⚙️ Cara Menjalankan Project

1.  Pastikan Flutter SDK sudah terinstall.
2.  Clone repository ini: `git clone [URL_REPO]`.
3.  Buat file `.env` di root project dan masukkan kredensial Supabase Anda.
4.  Jalankan `flutter pub get`.
5.  Hubungkan device/emulator, lalu jalankan `flutter run`.

---

*Project ini dibuat oleh The Kuncir team (Kelompok 6) untuk memodernisasi operasional Panasea Zone Coffee - Praktikum Pemrograman Aplikasi Bergerak 2026.*
