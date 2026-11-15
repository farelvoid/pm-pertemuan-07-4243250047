// Tugas Rutin 7: Planner Tugas Kuliah (versi 1: Provider)
// Nama: ................  NIM: ................
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import 'tugas_model.dart';

void main() {
  runApp(
    // State bersama diletakkan di atas MaterialApp agar terlihat semua halaman.
    ChangeNotifierProvider(
      create: (_) => TugasModel(awal: dataContoh()),
      child: const PlannerApp(),
    ),
  );
}

// ---------------------------------------------------------------- Data contoh
List<TugasKuliah> dataContoh() {
  final h = DateTime.now();
  final hariIni = DateTime(h.year, h.month, h.day);
  return [
    TugasKuliah(
      id: 1,
      judul: 'Latihan Kalkulator IP',
      mk: 'Pemrograman Mobile',
      tenggat: hariIni.add(const Duration(days: 2)),
    ),
    TugasKuliah(
      id: 2,
      judul: 'Laporan Praktikum Basis Data',
      mk: 'Basis Data',
      tenggat: hariIni.add(const Duration(days: 5)),
    ),
    TugasKuliah(
      id: 3,
      judul: 'Rangkuman Jurnal Etika',
      mk: 'Etika Profesi',
      tenggat: hariIni.subtract(const Duration(days: 1)),
    ),
  ];
}

// ---------------------------------------------------------------- Router
final _rootKey = GlobalKey<NavigatorState>();

final _router = GoRouter(
  navigatorKey: _rootKey,
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => KerangkaPlanner(shell: shell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const DaftarTugas(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/statistik',
              builder: (context, state) => const Statistik(),
            ),
          ],
        ),
      ],
    ),
    // Form tampil di atas shell (tanpa bilah navigasi).
    GoRoute(
      path: '/tambah',
      parentNavigatorKey: _rootKey,
      builder: (context, state) => const FormTambah(),
    ),
  ],
);

class PlannerApp extends StatelessWidget {
  const PlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Planner Tugas Kuliah',
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
      ),
    );
  }
}

class KerangkaPlanner extends StatelessWidget {
  const KerangkaPlanner({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (i) =>
            shell.goBranch(i, initialLocation: i == shell.currentIndex),
        destinations: const [
          NavigationDestination(icon: IkonTugas(), label: 'Tugas'),
          NavigationDestination(icon: Icon(Icons.insights), label: 'Statistik'),
        ],
      ),
    );
  }
}

FormFieldValidator<String> wajibIsi(String nama) =>
    (v) => (v == null || v.trim().isEmpty) ? '$nama wajib diisi' : null;

class KartuAngka extends StatelessWidget {
  const KartuAngka({super.key, required this.label, required this.nilai});

  final String label;
  final String nilai;

  @override
  Widget build(BuildContext context) {
    final teks = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: teks.labelLarge),
            const SizedBox(height: 4),
            Text(nilai, style: teks.headlineMedium),
          ],
        ),
      ),
    );
  }
}

Widget tombolTanggal({
  required DateTime? tenggat,
  required VoidCallback onTap,
}) =>
    OutlinedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.event),
      label: Text(
        tenggat == null ? 'Pilih tenggat' : formatTanggal(tenggat),
      ),
    );

/// select: hanya dibangun ulang saat jumlahAktif berubah.
class IkonTugas extends StatelessWidget {
  const IkonTugas({super.key});

  @override
  Widget build(BuildContext context) {
    final aktif = context.select<TugasModel, int>((m) => m.jumlahAktif);
    return Badge.count(
      count: aktif,
      isLabelVisible: aktif > 0,
      child: const Icon(Icons.checklist),
    );
  }
}

// ---------------------------------------------------------------- Daftar
class DaftarTugas extends StatefulWidget {
  const DaftarTugas({super.key});

  @override
  State<DaftarTugas> createState() => _DaftarTugasState();
}

class _DaftarTugasState extends State<DaftarTugas> {
  FilterTugas _filter = FilterTugas.semua; // state lokal (setState)

  @override
  Widget build(BuildContext context) {
    final model = context.watch<TugasModel>(); // state bersama
    final tampil = saring(model.daftar, _filter);

    return Scaffold(
      appBar: AppBar(title: const Text('Planner Tugas Kuliah')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/tambah'),
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8,
                children: [
                  for (final f in FilterTugas.values)
                    FilterChip(
                      label: Text(f.label),
                      selected: _filter == f,
                      onSelected: (_) => setState(() => _filter = f),
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            child: tampil.isEmpty
                ? const Center(child: Text('Tidak ada tugas.'))
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 96),
                    itemCount: tampil.length,
                    itemBuilder: (context, i) => KartuTugas(tugas: tampil[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

class KartuTugas extends StatelessWidget {
  const KartuTugas({super.key, required this.tugas});

  final TugasKuliah tugas;

  @override
  Widget build(BuildContext context) {
    final skema = Theme.of(context).colorScheme;
    final terlambat = tugas.terlambat(DateTime.now());

    return Dismissible(
      key: ValueKey(tugas.id),
      direction: DismissDirection.endToStart,
      background: ColoredBox(
        color: skema.errorContainer,
        child: Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 24),
            child: Icon(Icons.delete, color: skema.onErrorContainer),
          ),
        ),
      ),
      // read: dipakai di callback, tidak mendengarkan perubahan.
      onDismissed: (_) => context.read<TugasModel>().hapus(tugas.id),
      child: ListTile(
        leading: Checkbox(
          value: tugas.selesai,
          onChanged: (v) => context
              .read<TugasModel>()
              .tandaiSelesai(tugas.id, selesai: v ?? false),
        ),
        title: Text(
          tugas.judul,
          style: tugas.selesai
              ? const TextStyle(decoration: TextDecoration.lineThrough)
              : null,
        ),
        subtitle: Text('${tugas.mk} · ${formatTanggal(tugas.tenggat)}'),
        trailing: terlambat
            ? Chip(
                label: const Text('Terlambat'),
                backgroundColor: skema.errorContainer,
              )
            : null,
      ),
    );
  }
}

// ---------------------------------------------------------------- Form
class FormTambah extends StatefulWidget {
  const FormTambah({super.key});

  @override
  State<FormTambah> createState() => _FormTambahState();
}

class _FormTambahState extends State<FormTambah> {
  final _kunci = GlobalKey<FormState>();
  late final TextEditingController _judul;
  late final TextEditingController _mk;
  DateTime? _tenggat;

  @override
  void initState() {
    super.initState();
    _judul = TextEditingController();
    _mk = TextEditingController();
  }

  @override
  void dispose() {
    _judul.dispose(); // wajib: bersihkan controller
    _mk.dispose();
    super.dispose();
  }

  Future<void> _pilihTanggal() async {
    final sekarang = DateTime.now();
    final hasil = await showDatePicker(
      context: context,
      initialDate: _tenggat ?? sekarang,
      firstDate: DateTime(sekarang.year - 1),
      lastDate: DateTime(sekarang.year + 2),
    );
    if (!mounted) return; // cek mounted setelah await
    if (hasil != null) setState(() => _tenggat = hasil);
  }

  void _simpan() {
    final valid = _kunci.currentState?.validate() ?? false;
    final tenggat = _tenggat;
    if (!valid) return;
    if (tenggat == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih tenggat terlebih dahulu')),
      );
      return;
    }
    context.read<TugasModel>().tambah(
          judul: _judul.text,
          mk: _mk.text,
          tenggat: tenggat,
        );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Tugas')),
      body: Form(
        key: _kunci,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _judul,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Judul tugas',
                border: OutlineInputBorder(),
              ),
              validator: wajibIsi('Judul'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _mk,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Mata kuliah',
                border: OutlineInputBorder(),
              ),
              validator: wajibIsi('Mata kuliah'),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: tombolTanggal(tenggat: _tenggat, onTap: _pilihTanggal),
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: _simpan, child: const Text('Simpan')),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- Statistik
class Statistik extends StatelessWidget {
  const Statistik({super.key});

  @override
  Widget build(BuildContext context) {
    final m = context.watch<TugasModel>();
    final teks = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Statistik')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(child: KartuAngka(label: 'Total', nilai: '${m.total}')),
              const SizedBox(width: 12),
              Expanded(
                child: KartuAngka(label: 'Selesai', nilai: '${m.jumlahSelesai}'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Kemajuan', style: teks.titleMedium),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: m.total == 0 ? 0 : m.jumlahSelesai / m.total,
                  ),
                  const SizedBox(height: 8),
                  Text('${m.persenSelesai.toStringAsFixed(0)}% selesai'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
