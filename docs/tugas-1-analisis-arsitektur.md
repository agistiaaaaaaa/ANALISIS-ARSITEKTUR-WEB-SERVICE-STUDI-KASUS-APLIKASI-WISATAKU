# Tugas 1. Analisis Arsitektur Web Service

## 1. Identitas Project

Aplikasi yang dibahas bernama WisataKu. Backend-nya menggunakan NestJS dengan arsitektur monolitik modular dan API berbasis REST. Klien yang dirancang untuk mengakses backend adalah aplikasi mobile dan web admin.

## 2. Latar Belakang

WisataKu menyediakan layanan informasi dan pengelolaan destinasi wisata. Backend NestJS berperan sebagai web service yang menyediakan data serta fungsi aplikasi melalui REST API.

Pengguna tidak mengakses NestJS secara langsung dari antarmuka framework, melainkan melalui aplikasi klien. Aplikasi mobile dipakai pengguna umum untuk melihat destinasi dan fitur terkait. Aplikasi web admin dipakai pengelola untuk mengatur data destinasi dan konten terkait. NestJS menjadi pusat logika bisnis dan titik akses data yang dihubungkan melalui REST API.

## 3. Arsitektur Monolitik Modular

Monolitik modular berarti backend tetap berada dalam satu aplikasi, tetapi isinya dibagi menjadi modul. Aplikasi tetap satu proses dan satu unit deployment, sementara keteraturan kode dijaga lewat pemisahan modul.

Pola ini cocok dengan NestJS karena framework tersebut memang mendukung struktur modular. Domain seperti Destinasi, User, atau Booking dapat memiliki module, controller, dan service sendiri tanpa harus memisahkan service secara fisik. Pada WisataKu, penerapan pola tersebut terlihat dari project `wisataku-api`, titik masuk `main.ts`, dan adanya `DestinasiModule`. Bagian-bagian di dalam aplikasi saling terhubung melalui import module dan dependency injection.

## 4. Alasan Memilih Monolitik Modular

Bagian ini menjawab pertanyaan: mengapa WisataKu memilih monolitik modular di tahap awal, bukan langsung microservices?

Alasannya sederhana. Project masih di tahap awal, sehingga yang dibutuhkan adalah fondasi yang jelas dan tidak terlalu berat secara operasional.

Pada tahap ini, mahasiswa cukup mengerjakan satu aplikasi NestJS dengan satu alur request-response. Deployment juga lebih mudah karena hanya ada satu service yang dijalankan, misalnya dengan `npm run start:dev`. Debugging lebih ringan karena log dan alur kode berada dalam satu proses. Komunikasi antar modul berlangsung di dalam aplikasi yang sama, sehingga belum perlu protokol jaringan antar service.

Microservices tetap bermanfaat pada sistem yang besar, terutama bila dibutuhkan skalabilitas mandiri atau isolasi kegagalan. Namun manfaat itu datang bersama kompleksitas infrastruktur dan pemantauan. Untuk praktikum ini, kompleksitas tersebut belum sebanding dengan kebutuhan. Endpoint yang ada masih terbatas pada `GET /` dan `GET /destinasi`.

Meski demikian, struktur modular tetap dibangun sejak awal. Jika nanti skala sistem meningkat, modul yang sudah terpisah secara logis dapat dikembangkan menjadi service mandiri. Monolitik modular dipakai sebagai langkah awal, bukan sebagai penolakan terhadap microservices.

## 5. Perbandingan Monolitik Modular dan Microservices

| Aspek | Monolitik Modular | Microservices |
| --- | --- | --- |
| Struktur aplikasi | Satu aplikasi dengan banyak module | Banyak service mandiri |
| Deployment | Satu unit deploy | Banyak unit deploy |
| Komunikasi antar bagian | Lokal melalui import atau DI | Melalui jaringan, misalnya API atau message broker |
| Debugging | Lebih sederhana | Lebih sulit karena tersebar |
| Kompleksitas | Lebih rendah di awal | Lebih tinggi sejak awal |
| Skalabilitas | Pada aplikasi secara keseluruhan | Dapat per service |
| Kebutuhan operasional | Lebih ringan | Lebih besar |

Kedua pendekatan dapat dipakai. Pilihannya bergantung pada tahap project, ukuran tim, kebutuhan skalabilitas, dan kesiapan operasional.

## 6. Arsitektur WisataKu

Mobile App dan Web Admin mengakses NestJS Backend melalui REST API. Backend kemudian, pada tahap penuh, akan mengakses database untuk membaca atau menulis data.

Kedua aplikasi tersebut bertindak sebagai klien. NestJS menerima permintaan, memproses logika aplikasi, lalu mengembalikan respons. Saat ini respons praktikum masih berupa teks sederhana. Backend menjadi pintu masuk utama bagi data dan logika bisnis.

## 7. Modul Backend

Pembagian modul berikut masih berupa rancangan dan belum seluruhnya diimplementasikan.

| Modul | Peran |
| --- | --- |
| Auth | Autentikasi dan otorisasi |
| User | Pengelolaan data pengguna |
| Destinasi | Pengelolaan dan penyajian destinasi wisata |
| Booking | Pemesanan destinasi |
| Review | Ulasan pengguna |
| Admin | Fungsi pengelolaan pada panel admin |

Pada tahap awal, seluruh modul dirancang berada dalam satu aplikasi NestJS. Yang sudah dibuat secara nyata baru modul Destinasi beserta endpoint dasarnya.

## 8. Implementasi Praktikum Saat Ini

Hasil implementasi pada project `wisataku-api` adalah sebagai berikut.

| Endpoint | Method | Response |
| --- | --- | --- |
| `/` | GET | `Hello World!` |
| `/destinasi` | GET | `Daftar destinasi wisata akan tampil di sini` |

`AppModule` mendaftarkan `DestinasiModule`, dan `DestinasiController` menangani route `/destinasi`. Aplikasi dijalankan dengan `npm run start:dev` pada port 3000. Database, autentikasi, Prisma, JWT, Docker, dan pemisahan microservices belum digunakan.

## 9. Kesimpulan

Monolitik modular dipilih karena memberi keteraturan kode tanpa membebani operasional di tahap awal. Backend NestJS tetap dapat dibagi menurut domain, tetapi masih dijalankan sebagai satu aplikasi.

Pendekatan ini memudahkan pengembangan dan pengujian pada praktikum. Bila skala sistem bertambah, arsitektur masih terbuka untuk dikembangkan, termasuk mempertimbangkan microservices jika memang diperlukan.
