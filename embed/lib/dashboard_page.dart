// --- FILE: dashboard_page.dart ---
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'feed_success_page.dart';
import 'activity_log_page.dart';
import 'schedule_page.dart';
import 'device_manager_page.dart';

class DashboardPage extends StatefulWidget {
  final String userId;
  const DashboardPage({super.key, required this.userId});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late DatabaseReference _deviceRef;
  late StreamSubscription<DatabaseEvent> _deviceSub;
  List<String> _devices = [];
  String? _selectedId;
  Map<String, dynamic>? _deviceData;
  Timer? _feedChecker;
  Map<String, dynamic> _schedules = {};
  final List<Map<String, dynamic>> _activityLog = [];

  @override
  void initState() {
    super.initState();
    _loadUserDevices();
  }

  Future<void> _loadUserDevices() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .get();
    if (!doc.exists) return;
    final data = doc.data()!;
    final devices = Map<String, dynamic>.from(data['devices'] ?? {});
    setState(() {
      _devices = devices.keys.toList();
      if (_devices.isNotEmpty) {
        _selectedId = _devices.first;
        _setupListener();
        _loadSchedules();
      }
    });
  }

  Future<void> _loadSchedules() async {
    if (_selectedId == null) return;
    final snap = await FirebaseDatabase.instance
        .ref('schedules/$_selectedId')
        .get();
    if (!snap.exists) return;
    setState(() => _schedules =
    Map<String, dynamic>.from(snap.value as Map));
    _startAutoFeedChecker();
  }

  void _setupListener() {
    if (_selectedId == null) return;
    _deviceRef =
        FirebaseDatabase.instance.ref('devices/$_selectedId');
    _deviceSub = _deviceRef.onValue.listen((evt) {
      final m = evt.snapshot.value as Map?;
      if (m != null) {
        setState(() => _deviceData =
        Map<String, dynamic>.from(m));
      }
    });
  }

  void _startAutoFeedChecker() {
    _feedChecker?.cancel();
    _feedChecker =
        Timer.periodic(const Duration(minutes: 1), (_) {
          if (_schedules['active'] == true &&
              _schedules['entries'] != null) {
            final now = TimeOfDay.now();
            for (var e in (_schedules['entries']
            as Map<String, dynamic>)
                .values) {
              final parts = (e['time'] as String).split(':');
              if (now.hour == int.parse(parts[0]) &&
                  now.minute == int.parse(parts[1])) {
                _sendFeed(auto: true);
                break;
              }
            }
          }
        });
  }

  Future<void> _sendFeed({bool auto = false}) async {
    if (_selectedId == null) return;
    final cmdRef = FirebaseDatabase.instance
        .ref('commands/$_selectedId/current_command');
    final ts = DateTime.now().toIso8601String();
    await cmdRef.set({
      'type': 'feed',
      'created_at': ts,
      'status': 'pending',
      'initiated_by': widget.userId,
    });
    setState(() {
      _activityLog.insert(0, {
        'type': 'Pemberian Makan',
        'timestamp': ts,
        'mode': auto ? 'Otomatis' : 'Manual',
      });
    });
    if (!auto && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FeedSuccessPage(
            time: TimeOfDay.now().format(context),
          ),
        ),
      );
    }
  }

  void _navigateToLog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ActivityLogPage(logs: _activityLog),
      ),
    );
  }

  void _navigateToSchedule() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            SchedulePage(initialSchedule: _schedules),
      ),
    );
    if (result != null && _selectedId != null && mounted) {
      setState(() => _schedules = result);
      await FirebaseDatabase.instance
          .ref('schedules/$_selectedId')
          .update(result);
      setState(() {
        _activityLog.insert(0, {
          'type': 'schedule_update',
          'timestamp': DateTime.now().toIso8601String(),
        });
      });
      _startAutoFeedChecker();
    }
  }

  void _navigateToDeviceManager() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => DeviceManagerPage(
            userId: widget.userId,
            connectedDevices: _devices),
      ),
    );
    if (result != null && mounted) {
      final newIds = result.keys.toList();
      setState(() {
        _devices = newIds;
        if (!_devices.contains(_selectedId)) {
          _selectedId =
          _devices.isNotEmpty ? _devices.first : null;
          if (_selectedId != null) _setupListener();
        }
      });
    }
  }

  void _logout() {
    FirebaseAuth.instance.signOut();
  }

  @override
  void dispose() {
    _deviceSub.cancel();
    _feedChecker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final info = _deviceData?['info'] as Map? ?? {};
    final status = _deviceData?['status'] as Map? ?? {};
    final sensors = _deviceData?['sensors'] as Map? ?? {};
    // Hitung feedStatus
    final rawDist = sensors['distance_cm'];
    final dist = rawDist is num ? rawDist.toDouble() : null;
    String feedStatus = dist == null
        ? "-"
        : dist > 5
        ? "Kosong"
        : dist > 3
        ? "Setengah"
        : "Full";
    // Turbidity
    final rawT = sensors['turbidity'];
    final turb = rawT is num ? rawT.toDouble() : null;
    String turbidityStatus = turb == null
        ? "-"
        : turb > 50
        ? "Keruh"
        : "Jernih";

    final dynPct = sensors['battery_percent'];
    final pct = dynPct is num
        ? dynPct.toInt()
        : (dynPct is String ? int.tryParse(dynPct) : null);

    return Scaffold(
      appBar: AppBar(
        title: const Text("FishFeed"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_devices.isNotEmpty)
              DropdownButton<String>(
                value: _selectedId,
                items: _devices.map((d) {
                  return DropdownMenuItem(
                    value: d,
                    child:
                    Text("Perangkat: ${info['name'] ?? d.substring(0, 6)}"),
                  );
                }).toList(),
                onChanged: (v) {
                  setState(() => _selectedId = v);
                  _setupListener();
                  _loadSchedules();
                },
              ),
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: const Text("Status Perangkat",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                    status['online'] == true ? "Online" : "Offline"),
              ),
            ),
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: const Text("Persediaan Pakan",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(feedStatus),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: const Text("Kekeruhan Air",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(turbidityStatus),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: const Text("Baterai",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle:
                      Text(pct != null ? "$pct %" : "-"),
                    ),
                  ),
                ),
              ],
            ),
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: const Text("Jadwal Pemberian Pakan",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  _schedules['entries'] != null
                      ? "Active: ${_schedules['aktif'] == true ? 'ya' : 'tidak'}\n${(_schedules['entries'] as Map)
                          .values
                          .map((e) => e['time'])
                          .join(', ')}"
                      : "Belum ada jadwal yang diatur",
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _selectedId != null
                  ? () => _sendFeed(auto: false)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text("Beri Makan Sekarang"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _navigateToLog,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text("Riwayat Aktivitas"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed:
              _selectedId != null ? _navigateToSchedule : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text("Atur Jadwal"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _navigateToDeviceManager,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple[800],
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text("Kelola Perangkat"),
            ),
          ],
        ),
      ),
    );
  }
}
