import 'package:flutter_test/flutter_test.dart';
import 'package:planner_tugas/tugas_model.dart';

void main() {
  final tgl = DateTime(2026, 11, 20);

  group('TugasModel', () {
    test('tambah memasukkan tugas, mengurutkan per tenggat, dan memberi tahu pendengar', () {
      final model = TugasModel();
      var dipanggil = 0;
      model.addListener(() => dipanggil++);

      model.tambah(judul: 'Kedua', mk: 'PM', tenggat: DateTime(2026, 11, 25));
      model.tambah(judul: 'Pertama', mk: 'PM', tenggat: tgl);

      expect(model.total, 2);
      expect(model.daftar.first.judul, 'Pertama');
      expect(dipanggil, 2);
    });

    test('tandaiSelesai mengubah jumlah dan persen', () {
      final model = TugasModel();
      model.tambah(judul: 'A', mk: 'PM', tenggat: tgl);
      model.tambah(judul: 'B', mk: 'PM', tenggat: tgl);

      model.tandaiSelesai(model.daftar.first.id);

      expect(model.jumlahSelesai, 1);
      expect(model.jumlahAktif, 1);
      expect(model.persenSelesai, 50);
    });

    test('hapus membuang tugas dan mengabaikan id yang tidak ada', () {
      final model = TugasModel();
      model.tambah(judul: 'A', mk: 'PM', tenggat: tgl);
      final id = model.daftar.single.id;

      model.hapus(999);
      expect(model.total, 1);

      model.hapus(id);
      expect(model.total, 0);
    });

    test('judul kosong ditolak', () {
      final model = TugasModel();
      expect(
        () => model.tambah(judul: '   ', mk: 'PM', tenggat: tgl),
        throwsArgumentError,
      );
      expect(model.total, 0);
    });
  });


  test('saring memisahkan tugas aktif dan selesai, serta mencari judul', () {
    final daftar = [
      TugasKuliah(id: 1, judul: 'Laporan Basis Data', mk: 'BD', tenggat: tgl),
      TugasKuliah(id: 2, judul: 'Kuis Mobile', mk: 'PM', tenggat: tgl, selesai: true),
    ];

    expect(saring(daftar, FilterTugas.semua).length, 2);
    expect(saring(daftar, FilterTugas.aktif).single.id, 1);
    expect(saring(daftar, FilterTugas.selesai).single.id, 2);
    expect(saring(daftar, FilterTugas.semua, kata: 'mobile').single.id, 2);
  });

  test('terlambat hanya untuk tugas aktif yang tenggatnya sudah lewat', () {
    final sekarang = DateTime(2026, 11, 20, 15);
    final lewat = TugasKuliah(id: 1, judul: 'A', mk: 'X', tenggat: DateTime(2026, 11, 19));
    final hariIni = TugasKuliah(id: 2, judul: 'B', mk: 'X', tenggat: DateTime(2026, 11, 20));
    final selesai = lewat.copyWith(selesai: true);

    expect(lewat.terlambat(sekarang), isTrue);
    expect(hariIni.terlambat(sekarang), isFalse);
    expect(selesai.terlambat(sekarang), isFalse);
  });

  test('formatTanggal memakai dd/MM/yyyy', () {
    expect(formatTanggal(DateTime(2026, 3, 5)), '05/03/2026');
  });
}
