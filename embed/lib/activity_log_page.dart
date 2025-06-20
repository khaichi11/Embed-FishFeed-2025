// --- FILE: activity_log_page.dart ---
import 'package:flutter/material.dart';

class ActivityLogPage extends StatelessWidget {
  final List<Map<String, dynamic>> logs;
  const ActivityLogPage({super.key, required this.logs});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Riwayat Aktivitas")),
      body: ListView.builder(
        itemCount: logs.length,
        itemBuilder: (_, i) {
          final log = logs[i];
          final icon = log['type'] == 'Pemberian Makan'
              ? Icons.food_bank
              : Icons.settings;
          final title = log['type'] == 'Pemberian Makan'
              ? "Telah Diberi Makan (${log['mode']})"
              : "Jadwal Diperbarui";
          return ListTile(
            leading: Icon(icon),
            title: Text(title),
            subtitle: Text(log['timestamp']),
          );
        },
      ),
    );
  }
}
