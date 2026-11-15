// Logika state bersama (Provider). Tanpa UI: hanya flutter/foundation.
import 'package:flutter/foundation.dart';

/// Satu tugas kuliah. Immutable: perubahan dibuat lewat copyWith.
class TugasKuliah {
  const TugasKuliah({
    required this.id,
    required this.judul,
    required this.mk,
    required this.tenggat,
    this.selesai = false,
  });

  final int id;
  final String judul;
  final String mk; // mata kuliah
  final DateTime tenggat;
  final bool selesai;

  TugasKuliah copyWith({bool? selesai}) => TugasKuliah(
        id: id,
        judul: judul,
        mk: mk,
        tenggat: tenggat,
        selesai: selesai ?? this.selesai,
      );

  /// Terlambat bila belum selesai dan tenggatnya sebelum hari ini.
  bool terlambat(DateTime sekarang) =>
      !selesai &&
      tenggat.isBefore(DateTime(sekarang.year, sekarang.month, sekarang.day));
}

enum FilterTugas {
  semua('Semua'),
  aktif('Aktif'),
  selesai('Selesai');

  const FilterTugas(this.label);
  final String label;
}

/// Logika penyaringan dipisah dari UI supaya mudah diuji.
List<TugasKuliah> saring(
  List<TugasKuliah> daftar,
  FilterTugas filter, {
  String kata = '',
}) {
  final hasil = switch (filter) {
    FilterTugas.semua => daftar,
    FilterTugas.aktif => daftar.where((t) => !t.selesai).toList(),
    FilterTugas.selesai => daftar.where((t) => t.selesai).toList(),
  };
  final cari = kata.trim().toLowerCase();
  if (cari.isEmpty) return hasil;
  return hasil.where((t) => t.judul.toLowerCase().contains(cari)).toList();
}

String formatTanggal(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

int _bandingTenggat(TugasKuliah a, TugasKuliah b) =>
    a.tenggat.compareTo(b.tenggat);

List<TugasKuliah> _urut(Iterable<TugasKuliah> d) => [...d]..sort(_bandingTenggat);

int _idSetelah(Iterable<TugasKuliah> d) =>
    d.fold<int>(0, (m, t) => t.id > m ? t.id : m) + 1;

class TugasModel extends ChangeNotifier {
  TugasModel({List<TugasKuliah> awal = const []})
      : _daftar = _urut(awal),
        _idBerikut = _idSetelah(awal);

  final List<TugasKuliah> _daftar;
  int _idBerikut;

  List<TugasKuliah> get daftar => List.unmodifiable(_daftar);
  int get total => _daftar.length;
  int get jumlahSelesai => _daftar.where((t) => t.selesai).length;
  int get jumlahAktif => total - jumlahSelesai;
  double get persenSelesai => total == 0 ? 0 : jumlahSelesai / total * 100;

  void tambah({
    required String judul,
    required String mk,
    required DateTime tenggat,
  }) {
    final j = judul.trim();
    if (j.isEmpty) throw ArgumentError('Judul tidak boleh kosong');
    _daftar.add(TugasKuliah(
      id: _idBerikut++,
      judul: j,
      mk: mk.trim(),
      tenggat: tenggat,
    ));
    _daftar.sort(_bandingTenggat);
    notifyListeners();
  }

  void tandaiSelesai(int id, {bool selesai = true}) {
    final i = _daftar.indexWhere((t) => t.id == id);
    if (i < 0) return;
    _daftar[i] = _daftar[i].copyWith(selesai: selesai);
    notifyListeners();
  }

  void hapus(int id) {
    final sebelum = _daftar.length;
    _daftar.removeWhere((t) => t.id == id);
    if (_daftar.length != sebelum) notifyListeners();
  }
}
