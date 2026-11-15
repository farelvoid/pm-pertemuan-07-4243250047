# Planner Tugas Kuliah: versi 1 (Provider)
Nama: ................ · NIM: ................ · Tugas Rutin 7, Pemrograman Mobile

## Menjalankan
```
flutter create --org id.ac.unimed planner_tugas
cd planner_tugas
flutter pub add material_ui go_router provider
# salin folder lib/ dan test/ dari repositori ini (timpa yang bawaan)
flutter run
flutter test
flutter analyze
```
Nama proyek harus `planner_tugas` agar impor di `test/tugas_test.dart` cocok. Jika memakai nama lain, ubah baris `import 'package:planner_tugas/...'`.

## Fitur
- Menambah tugas (judul, mata kuliah, tenggat), menandai selesai, dan menghapus.
- Filter Semua, Aktif, Selesai; tugas yang lewat tenggat ditandai terlambat.
- Badge jumlah tugas aktif pada tab Tugas, dan halaman statistik.
- Penggunaan `watch` di build, `read` di callback, dan `select` untuk badge.

## Rute (go_router)
| Rute | Halaman | Keterangan |
|---|---|---|
| `/` | DaftarTugas | daftar tugas + FilterChip/filter, cabang 0 pada shell |
| `/statistik` | Statistik | total, selesai, persentase, cabang 1 pada shell |
| `/tambah` | FormTambah | ditampilkan di atas shell lewat `context.push('/tambah')` |

## Diagram letak state
```
ChangeNotifierProvider<TugasModel>        <- state BERSAMA (di atas MaterialApp)
└─ PlannerApp (MaterialApp.router)
   ├─ KerangkaPlanner (NavigationBar)
   │   └─ IkonTugas ........ context.select(jumlahAktif) -> Badge
   ├─ DaftarTugas (Stateful)
   │   ├─ _filter ......... setState            <- state LOKAL
   │   ├─ watch<TugasModel> -> daftar disaring
   │   └─ KartuTugas ...... read -> tandaiSelesai / hapus
   ├─ Statistik ........... watch<TugasModel> -> total, selesai, %
   └─ FormTambah (Stateful)
       ├─ _judul, _mk (TextEditingController) <- LOKAL, dispose()
       ├─ _tenggat ........ setState            <- LOKAL
       └─ read -> tambah()
```

## Mengapa Provider
Daftar tugas dipakai tiga tempat sekaligus (daftar, statistik, badge di navigasi) di cabang rute yang berbeda, sehingga tidak cukup disimpan dengan `setState` di satu widget. Provider dipilih karena kebutuhannya sederhana: satu model `ChangeNotifier`, tiga method, dan `notifyListeners()`. Boilerplate-nya sedikit dan logikanya mudah diuji tanpa UI (hanya `flutter/foundation`).

Sedangkan filter dan isi form dibiarkan sebagai state lokal (`setState`, `TextEditingController`) karena hanya dipakai satu widget dan tidak perlu diketahui halaman lain.

## Unit test
`test/tugas_test.dart` menguji logika tanpa UI (`lib/tugas_model.dart`):
- Daftar tugas bertambah, tersortir per tenggat, memanggil `notifyListeners`.
- Penandaan selesai mengubah jumlah dan persentase.
- Hapus (termasuk id yang tidak ada).
- Judul kosong melempar `ArgumentError`.
- `saring`, `terlambat`, dan `formatTanggal` (fungsi murni).

## Tangkapan layar
| Daftar | Tambah | Statistik |
|---|---|---|
| ![daftar](docs/daftar.png) | ![tambah](docs/tambah.png) | ![statistik](docs/statistik.png) |

## Checklist syarat tugas
| Syarat | Letak di kode |
|---|---|
| Model `TugasKuliah` (judul, MK, tenggat, selesai) | `lib/tugas_model.dart` |
| State lokal: filter dengan `setState` | `_DaftarTugasState` |
| `TextEditingController` dengan `dispose()` | `_FormTambahState` (`initState` dan `dispose`) |
| State bersama + `tambah`, `tandaiSelesai`, `hapus` | `lib/tugas_model.dart` |
| Badge jumlah tugas aktif | `IkonTugas` di `main.dart` |
| go_router, 3 halaman | `_router` di `main.dart` |
| Minimal 3 unit test logika | `test/tugas_test.dart` |
