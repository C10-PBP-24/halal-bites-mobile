# HalalBites

## i. Anggota Kelompok
- Christopher Matthew Hendarson - 2306245592 `gOnEbOnE`
- Emanuella Abygail Rotua Siahaan - 2306152185 `emanuellaabygail`
- Erdafa Andikri - 2306244993 `dafandikri`
- Imam Fajri - 2306165566 `imamfajri1`
- Syahirah Putri Aisyah - 2306275216 `Syahirahputrii`

## ii. Deskripsi
**_HalalBites_** adalah aplikasi yang dirancang khusus untuk membantu wisatawan yang berkunjung ke Bandung menemukan tempat makan dan minuman halal dengan mudah. Terinspirasi dari kebutuhan wisatawan Muslim yang sering kesulitan mencari makanan halal di tempat baru, **_HalalBites_** hadir sebagai solusi yang cepat dan dapat diandalkan.

Saat menggunakan HalalBites, pengguna dapat mencari restoran, kafe, atau warung yang menyediakan makanan dan minuman halal di berbagai daerah Bandung. Aplikasi ini juga menampilkan ulasan pengguna, peta lokasi, serta rekomendasi menu terbaik. Selain itu, HalalBites menyediakan filter berdasarkan kategori makanan (misalnya: makanan khas Sunda, Timur Tengah, atau makanan cepat saji), lokasi terdekat, dan harga yang sesuai dengan budget.

## iii. Daftar Modul
-   **Ulasan Pengguna**: Pengguna dapat memberikan ulasan berdasarkan pengalaman mereka.

    Dikerjakan oleh: **Erdafa Andikri**

-   **Food Tracker**: Pengguna dapat melihat history makanan yang pernah dimakan.

    Dikerjakan oleh: **Syahirah Putri Aisyah**

-   **Forum**: Pengguna dapat berbincang dengan user lain.

    Dikerjakan oleh: **Christopher Matthew Hendarson**

-   **Resto**: Pengguna dapat menemukan tempat makan halal terdekat dari lokasi pengguna.

    Dikerjakan oleh: **Emanuella Abygail Rotua Siahaan**

-   **Makanan**: Pengguna dapat menyaring makanan berdasarkan lokasi.

    Dikerjakan oleh: **Imam Fajri**


## iv. Role Pengguna
- **_User_**
- **_Admin_**

| No. | Modul                      | _Permission User_                                                                                              | _Permission Admin_                                                                                                                   |
| --- | -------------------------- | -------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------ |
| 1   | Ulasan Pengguna            | Pengguna dapat memberikan rating dan ulasan berdasarkan pengalaman mereka.                                     | Admin dapat menghapus ulasan yang tidak sesuai.                                                                                      |
| 2   | Food Tracker (history)     | Pengguna dapat melihat history makanan yang pernah dimakan.                                                    | Admin dapat mengelola data history makanan pengguna.                                                                                 |
| 3   | Forum                      | Pengguna dapat melihat rekomendasi menu terbaik berdasarkan ulasan pengguna dan berbincang dengan user lain.   | Admin dapat mengelola dan menghapus postingan yang tidak sesuai.                                                                     |
| 4   | Resto                      | Pengguna dapat menemukan tempat makan halal terdekat dari lokasi pengguna.                                     | Admin dapat menambahkan, mengelola, dan menghapus data lokasi tempat makan halal.                                                    |
| 5   | Food                       | Pengguna dapat menyaring makanan berdasarkan budget                                                            | Admin dapat menambahkan, mengelola, dan menghapus harga                                                                              |

## v. Alur Pengintegrasian

1. **Penambahan Library HTTP**
    - Aplikasi Flutter akan ditambahkan library http agar dapat mengirim dan menerima data dari aplikasi web melalui API.

2. **Pemanfaatan Sistem Autentikasi**
    - Sistem autentikasi yang mencakup login, logout, dan registrasi, yang sudah dikembangkan sebelumnya, akan digunakan untuk memberikan akses sesuai dengan peran pengguna.

3. **Pengelolaan Cookie dengan `pbp_django_auth`**
    - Library pbp_django_auth akan dimanfaatkan untuk mengatur cookie sehingga semua permintaan (request) yang dikirim ke server bersifat autentik dan terotorisasi.

## vi. Tautan Desain Aplikasi
[Tautan Desain Figma Desain Aplikasi](https://www.figma.com/design/BHCWjaXI58h5ZtYrAYyXxu/quick-free-food-app-design-figma-template?node-id=2-213&t=nWv16YRA59dMkxQC-1)

## vii. Tautan APK Sementara (21/12/2024)
[Tautan APK Sementara](https://install.appcenter.ms/orgs/c10_pbp/apps/halal-bites/distribution_groups/public/releases/2)
    
