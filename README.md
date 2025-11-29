# KasirPro Mobile

Aplikasi KasirPro versi Mobile (Flutter).

## Persiapan Sebelum Menjalankan

Karena aplikasi ini menggunakan Firebase, Anda perlu mengkonfigurasi Firebase untuk Android/iOS terlebih dahulu.

1.  Pastikan Anda memiliki **FlutterFire CLI** terinstall:
    ```bash
    dart pub global activate flutterfire_cli
    ```

2.  Jalankan perintah berikut di terminal (di dalam folder ini):
    ```bash
    flutterfire configure
    ```
    - Pilih project `kasir-pro-a9442`.
    - Pilih platform `android` dan `ios`.
    - Ini akan membuat file `lib/firebase_options.dart`.

3.  Update `lib/main.dart`:
    - Hapus inisialisasi manual `FirebaseOptions(...)`.
    - Ganti dengan:
      ```dart
      import 'firebase_options.dart';
      
      // ...
      
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      ```

## Cara Menjalankan

```bash
flutter pub get
flutter run
```

## Fitur Saat Ini
- **Login**: Support login Staff (dengan Nama Toko) dan Super Admin.
- **Dashboard**: Menampilkan ringkasan omzet dan menu utama.
- **Integrasi**: Terhubung langsung ke database Firestore yang sama dengan Web.
