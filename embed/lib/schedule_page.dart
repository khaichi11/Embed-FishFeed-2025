// --- FILE: schedule_page.dart ---
import 'package:flutter/material.dart';

class SchedulePage extends StatefulWidget {
  final Map<String, dynamic> initialSchedule;
  const SchedulePage({super.key, required this.initialSchedule});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  late bool _active;
  late Map<String, Map<String, dynamic>> _entries;

  @override
  void initState() {
    super.initState();
    _active = widget.initialSchedule['active'] == true;
    final raw = widget.initialSchedule['entries']
    as Map<String, dynamic>? ??
        {};
    _entries = raw.map((k, v) {
      final m = Map<String, dynamic>.from(v as Map);
      return MapEntry(k, {
        'time': m['time'],
        'enabled': m['enabled'] == true,
        'last_run': m['last_run'] ?? ''
      });
    });
  }

  Future<void> _pickTime() async {
    int h = DateTime.now().hour;
    int m = DateTime.now().minute;
    await showModalBottomSheet(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setMb) => Container(
          height: 300,
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              const Text("Masukkan Waktu Pemberian Pakan",
                  style: TextStyle(fontSize: 18)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.keyboard_arrow_up),
                        onPressed: () =>
                            setMb(() => h = (h + 1) % 24),
                      ),
                      Text(h.toString().padLeft(2, '0'),
                          style: const TextStyle(
                              fontSize: 32,
                              fontFamily: 'RobotoMono')),
                      IconButton(
                        icon: const Icon(Icons.keyboard_arrow_down),
                        onPressed: () =>
                            setMb(() => h = (h + 23) % 24),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  const Text(":", style: TextStyle(fontSize: 32)),
                  const SizedBox(width: 16),
                  Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.keyboard_arrow_up),
                        onPressed: () =>
                            setMb(() => m = (m + 1) % 60),
                      ),
                      Text(m.toString().padLeft(2, '0'),
                          style: const TextStyle(
                              fontSize: 32,
                              fontFamily: 'RobotoMono')),
                      IconButton(
                        icon: const Icon(Icons.keyboard_arrow_down),
                        onPressed: () =>
                            setMb(() => m = (m + 59) % 60),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () =>
                        Navigator.of(context).pop(),
                    child: const Text("Batalkan"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final timeStr =
                          '${h.toString().padLeft(2,'0')}:${m.toString().padLeft(2,'0')}';
                      final now = DateTime.now();
                      final today =
                          '${now.year.toString().padLeft(4,'0')}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')}';
                      final id =
                      DateTime.now().millisecondsSinceEpoch.toString();
                      setState(() {
                        _entries[id] = {
                          'time': timeStr,
                          'enabled': true,
                          'last_run': today,
                        };
                      });
                      Navigator.of(context).pop();
                    },
                    child: const Text("OK"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _remove(String id) => setState(() => _entries.remove(id));
  void _toggle(String id, bool? v) {
    if (v == null) return;
    setState(() => _entries[id]!['enabled'] = v);
  }

  void _save() {
    Navigator.pop(context, {
      'active': _active,
      'entries': _entries,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Atur Jadwal Pemberian Pakan")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SwitchListTile(
              title: const Text('Aktifkan Penjadwalan'),
              value: _active,
              onChanged: (v) => setState(() => _active = v),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _pickTime,
              icon: const Icon(Icons.access_time),
              label: const Text("Tambahkan Jadwal dengan format 24 jam"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _entries.isEmpty
                  ? const Center(
                  child: Text('Belum ada jadwal yang ditambahkan'))
                  : ListView(
                children: _entries.entries.map((e) {
                  final id = e.key;
                  final d = e.value;
                  return Card(
                    margin:
                    const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: Checkbox(
                        value: d['enabled'] as bool,
                        onChanged: (v) => _toggle(id, v),
                      ),
                      title: Text(d['time'],
                          style: const TextStyle(
                              fontFamily: 'RobotoMono',
                              fontSize: 18)),
                      subtitle: d['Terakhir dijalankan'] != ''
                          ? Text('Terakhir dijalankan: ${d['Terakhir dijalankan']}')
                          : null,
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _remove(id),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            ElevatedButton(
              onPressed: _save,
              child: const Text("Menyimpan Jadwal"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
