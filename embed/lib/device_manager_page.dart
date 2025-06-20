// --- FILE: device_manager_page.dart ---
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DeviceManagerPage extends StatefulWidget {
  final String userId;
  final List<String> connectedDevices;
  const DeviceManagerPage({
    super.key,
    required this.userId,
    required this.connectedDevices,
  });
  @override
  State<DeviceManagerPage> createState() =>
      _DeviceManagerPageState();
}

class _DeviceManagerPageState extends State<DeviceManagerPage> {
  final _deviceIdC = TextEditingController();
  late Map<String, dynamic> _userDevices;

  @override
  void initState() {
    super.initState();
    _userDevices = {
      for (var d in widget.connectedDevices) d: true
    };
  }

  Future<void> _addDevice() async {
    final id = _deviceIdC.text.trim();
    if (id.isEmpty || _userDevices.containsKey(id)) return;
    final snap = await FirebaseDatabase.instance
        .ref('devices/$id/info')
        .get();
    if (!snap.exists) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Device not found in system")),
        );
      }
      return;
    }
    setState(() {
      _userDevices[id] = {
        'paired_at': DateTime.now().toIso8601String(),
        'role': 'owner'
      };
      _deviceIdC.clear();
    });
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .update({'devices': _userDevices});
  }

  Future<void> _removeDevice(String id) async {
    setState(() => _userDevices.remove(id));
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .update({'devices': _userDevices});
  }

  @override
  void dispose() {
    _deviceIdC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pengaturan Perangkat")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _deviceIdC,
                    decoration:
                    const InputDecoration(labelText: "ID Perangkat"),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addDevice,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: _userDevices.keys.map((id) {
                  return ListTile(
                    title: Text(id),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _removeDevice(id),
                    ),
                  );
                }).toList(),
              ),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pop(context, _userDevices),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("Simpan"),
            ),
          ],
        ),
      ),
    );
  }
}
