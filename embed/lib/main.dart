// --- FILE: main.dart ---
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyFishApp());
}

class MyFishApp extends StatelessWidget {
  const MyFishApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fish Feeder',
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
    );
  }
}





































// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'auth_wrapper.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   runApp(const MyFishApp());
// }
//
// class MyFishApp extends StatelessWidget {
//   const MyFishApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Fish Feeder',
//       home: const AuthWrapper(),
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primarySwatch: Colors.deepPurple,
//         pageTransitionsTheme: const PageTransitionsTheme(
//           builders: {
//             TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
//             TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
//           },
//         ),
//       ),
//     );
//   }
// }
//
// class AuthWrapper extends StatelessWidget {
//   const AuthWrapper({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<User?>(
//       stream: FirebaseAuth.instance.authStateChanges(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.active) {
//           final user = snapshot.data;
//           if (user == null) {
//             return const LoginPage();
//           }
//           return DashboardPage(userId: user.uid);
//         }
//         return const Scaffold(
//           body: Center(
//             child: CircularProgressIndicator(),
//           ),
//         );
//       },
//     );
//   }
// }
//
// class LoginPage extends StatefulWidget {
//   const LoginPage({super.key});
//
//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }
//
// class _LoginPageState extends State<LoginPage> {
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   bool _isLoading = false;
//   String? _errorMessage;
//
//   Future<void> _login() async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });
//
//     try {
//       await FirebaseAuth.instance.signInWithEmailAndPassword(
//         email: _emailController.text.trim(),
//         password: _passwordController.text.trim(),
//       );
//     } on FirebaseAuthException catch (e) {
//       setState(() => _errorMessage = e.message ?? "Login failed");
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }
//
//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Padding(
//         padding: const EdgeInsets.all(24.0),
//         child: Center(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Text(
//                 "Smart Fish Feeder",
//                 style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 40),
//               if (_errorMessage != null)
//                 Padding(
//                   padding: const EdgeInsets.only(bottom: 16.0),
//                   child: Text(
//                     _errorMessage!,
//                     style: const TextStyle(color: Colors.red),
//                   ),
//                 ),
//               TextField(
//                 controller: _emailController,
//                 decoration: const InputDecoration(labelText: "Email"),
//                 keyboardType: TextInputType.emailAddress,
//               ),
//               const SizedBox(height: 16),
//               TextField(
//                 controller: _passwordController,
//                 decoration: const InputDecoration(labelText: "Password"),
//                 obscureText: true,
//               ),
//               const SizedBox(height: 24),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: _isLoading ? null : _login,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.deepPurple,
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                   ),
//                   child: _isLoading
//                       ? const CircularProgressIndicator(color: Colors.white)
//                       : const Text("Login"),
//                 ),
//               ),
//               TextButton(
//                 onPressed: () => Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => const SignUpPage()),
//                 ),
//                 child: const Text("Don't have an account? Sign up here"),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class SignUpPage extends StatefulWidget {
//   const SignUpPage({super.key});
//
//   @override
//   State<SignUpPage> createState() => _SignUpPageState();
// }
//
// class _SignUpPageState extends State<SignUpPage> {
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();
//   bool _isLoading = false;
//   String? _errorMessage;
//
//   Future<void> _signUp() async {
//     if (_passwordController.text != _confirmPasswordController.text) {
//       setState(() => _errorMessage = "Passwords don't match");
//       return;
//     }
//
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });
//
//     try {
//       final credential = await FirebaseAuth.instance
//           .createUserWithEmailAndPassword(
//         email: _emailController.text.trim(),
//         password: _passwordController.text.trim(),
//       );
//
//       await FirebaseFirestore.instance
//           .collection('users')
//           .doc(credential.user?.uid)
//           .set({
//         'email': _emailController.text.trim(),
//         'createdAt': FieldValue.serverTimestamp(),
//         'devices': {},
//       });
//
//       if (!mounted) return;
//       Navigator.pop(context);
//     } on FirebaseAuthException catch (e) {
//       setState(() => _errorMessage = e.message ?? "Sign up failed");
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }
//
//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     _confirmPasswordController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Sign Up")),
//       body: Padding(
//         padding: const EdgeInsets.all(24.0),
//         child: Column(
//           children: [
//             if (_errorMessage != null)
//               Padding(
//                 padding: const EdgeInsets.only(bottom: 16.0),
//                 child: Text(
//                   _errorMessage!,
//                   style: const TextStyle(color: Colors.red),
//                 ),
//               ),
//             TextField(
//               controller: _emailController,
//               decoration: const InputDecoration(labelText: "Email"),
//               keyboardType: TextInputType.emailAddress,
//             ),
//             const SizedBox(height: 16),
//             TextField(
//               controller: _passwordController,
//               decoration: const InputDecoration(labelText: "Password"),
//               obscureText: true,
//             ),
//             const SizedBox(height: 16),
//             TextField(
//               controller: _confirmPasswordController,
//               decoration: const InputDecoration(labelText: "Confirm Password"),
//               obscureText: true,
//             ),
//             const SizedBox(height: 24),
//             ElevatedButton(
//               onPressed: _isLoading ? null : _signUp,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.deepPurple,
//                 minimumSize: const Size(double.infinity, 50),
//               ),
//               child: _isLoading
//                   ? const CircularProgressIndicator(color: Colors.white)
//                   : const Text("Sign Up"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class DashboardPage extends StatefulWidget {
//   final String userId;
//
//   const DashboardPage({super.key, required this.userId});
//
//   @override
//   State<DashboardPage> createState() => _DashboardPageState();
// }
//
// class _DashboardPageState extends State<DashboardPage> {
//   late DatabaseReference _deviceRef;
//   late StreamSubscription<DatabaseEvent> _deviceSubscription;
//   List<String> _connectedDevices = [];
//   String? _selectedDeviceId;
//   Map<String, dynamic>? _deviceData;
//   Timer? _feedTimer;
//   Map<String, dynamic> _schedules = {};
//   final List<Map<String, dynamic>> _activityLog = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _loadUserDevices();
//   }
//
//   Future<void> _loadUserDevices() async {
//     final userDoc = await FirebaseFirestore.instance
//         .collection('users')
//         .doc(widget.userId)
//         .get();
//
//     if (userDoc.exists) {
//       final userData = userDoc.data() as Map<String, dynamic>;
//       final devices = userData['devices'] as Map<String, dynamic>? ?? {};
//
//       setState(() {
//         _connectedDevices = devices.keys.toList();
//         if (_connectedDevices.isNotEmpty) {
//           _selectedDeviceId = _connectedDevices.first;
//           _setupDeviceListener();
//           _loadSchedules();
//         }
//       });
//     }
//   }
//
//   Future<void> _loadSchedules() async {
//     if (_selectedDeviceId == null) return;
//
//     final scheduleRef = FirebaseDatabase.instance.ref('schedules/$_selectedDeviceId');
//     final snapshot = await scheduleRef.get();
//
//     if (snapshot.exists) {
//       setState(() {
//         _schedules = Map<String, dynamic>.from(snapshot.value as Map);
//       });
//       _startAutoFeedChecker();
//     }
//   }
//
//   void _setupDeviceListener() {
//     if (_selectedDeviceId == null) return;
//
//     _deviceRef = FirebaseDatabase.instance.ref('devices/$_selectedDeviceId');
//     _deviceSubscription = _deviceRef.onValue.listen((event) {
//       final data = event.snapshot.value as Map<dynamic, dynamic>?;
//       if (data != null) {
//         setState(() {
//           _deviceData = Map<String, dynamic>.from(data);
//         });
//       }
//     }, onError: (error) {
//       debugPrint('Device listener error: $error');
//     });
//   }
//
//   void _startAutoFeedChecker() {
//     _feedTimer?.cancel();
//     _feedTimer = Timer.periodic(const Duration(minutes: 1), (_) {
//       if (_schedules['active'] == true && _schedules['entries'] != null) {
//         final now = TimeOfDay.now();
//         final entries = Map<String, dynamic>.from(_schedules['entries']);
//
//         for (final entry in entries.values) {
//           final timeParts = (entry['time'] as String).split(':');
//           final scheduledTime = TimeOfDay(
//             hour: int.parse(timeParts[0]),
//             minute: int.parse(timeParts[1]),
//           );
//
//           if (now.hour == scheduledTime.hour &&
//               now.minute == scheduledTime.minute) {
//             _sendFeedCommand(auto: true);
//             break;
//           }
//         }
//       }
//     });
//   }
//
//   Future<void> _sendFeedCommand({bool auto = false}) async {
//     if (_selectedDeviceId == null) return;
//
//     final commandRef = FirebaseDatabase.instance.ref('commands/$_selectedDeviceId/current_command');
//     final timestamp = DateTime.now().toIso8601String();
//
//     await commandRef.set({
//       'type': 'feed',
//       'created_at': timestamp,
//       'status': 'pending',
//       'initiated_by': widget.userId,
//     });
//
//     // Add to activity log
//     setState(() {
//       _activityLog.insert(0, {
//         'type': 'feed',
//         'timestamp': timestamp,
//         'mode': auto ? 'auto' : 'manual'
//       });
//     });
//
//     if (!auto && mounted) {
//       Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => FeedSuccessPage(time: TimeOfDay.now().format(context)),
//           ));
//     }
//   }
//
//   void _navigateToLogPage() {
//     Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => ActivityLogPage(logs: _activityLog),
//         ));
//   }
//
//   void _navigateToSchedulePage() async {
//     final result = await Navigator.push<Map<String, dynamic>>(
//       context,
//       MaterialPageRoute(
//         builder: (context) => SchedulePage(initialSchedule: _schedules),
//       ),
//     );
//
//     if (result != null && _selectedDeviceId != null && mounted) {
//       setState(() => _schedules = result);
//
//       await FirebaseDatabase.instance
//           .ref('schedules/$_selectedDeviceId')
//           .update(result);
//
//       setState(() {
//         _activityLog.insert(0, {
//           'type': 'schedule_update',
//           'timestamp': DateTime.now().toIso8601String(),
//         });
//       });
//
//       _startAutoFeedChecker();
//     }
//   }
//
//   void _navigateToDeviceManager() async {
//     final result = await Navigator.push<Map<String, dynamic>>(
//       context,
//       MaterialPageRoute(
//         builder: (context) => DeviceManagerPage(
//           userId: widget.userId,
//           connectedDevices: _connectedDevices,
//         ),
//       ),
//     );
//
//     if (result != null && mounted) {
//       setState(() {
//         _connectedDevices = result.keys.toList();
//         if (!_connectedDevices.contains(_selectedDeviceId)) {
//           _selectedDeviceId = _connectedDevices.isNotEmpty ? _connectedDevices.first : null;
//           if (_selectedDeviceId != null) {
//             _setupDeviceListener();
//           }
//         }
//       });
//     }
//   }
//
//   void _logout() {
//     FirebaseAuth.instance.signOut();
//   }
//
//   @override
//   void dispose() {
//     _deviceSubscription.cancel();
//     _feedTimer?.cancel();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final deviceInfo = _deviceData?['info'] as Map? ?? {};
//     final deviceStatus = _deviceData?['status'] as Map? ?? {};
//     final deviceSensors = _deviceData?['sensors'] as Map? ?? {};
//     final _ = _deviceData?['settings'] as Map? ?? {};
//
//     // ─── REVISI FEED STATUS ───
//     // final double? dist = deviceSensors['distance_cm'] as double?;
//     final dynamic rawDist = deviceSensors['distance_cm'];
//     final double? dist = rawDist is num
//         ? rawDist.toDouble()
//         : null;
//     String feedStatus;
//     if (dist == null) {
//       feedStatus = "Unknown";
//     } else if (dist > 5.0) {
//       feedStatus = "Kosong";
//     } else if (dist > 3.0) {
//       feedStatus = "Setengah";
//     } else {
//       feedStatus = "Full";
//     }
// // ──────────────────────────
//     // ─── REVISI STATUS TURBIDITY ───────────────────────────
//     final dynamic rawTurb = deviceSensors['turbidity'];
//     final double? turbidity = rawTurb is num ? rawTurb.toDouble() : null;
//     String turbidityStatus;
//     if (turbidity == null) {
//       turbidityStatus = "Unknown";
//     } else if (turbidity > 170.0) {
//       turbidityStatus = "Keruh";
//     } else {
//       turbidityStatus = "Jernih";
//     }
// // ───────────────────────────────────────────────────────
//
//
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Smart Fish Feeder"),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.logout),
//             onPressed: _logout,
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             if (_connectedDevices.isNotEmpty)
//               DropdownButton<String>(
//                 value: _selectedDeviceId,
//                 items: _connectedDevices.map((deviceId) {
//                   return DropdownMenuItem(
//                     value: deviceId,
//                     child: Text("Device: ${deviceInfo['name'] ?? deviceId.substring(0, 6)}"),
//                   );
//                 }).toList(),
//                 onChanged: (value) {
//                   setState(() => _selectedDeviceId = value);
//                   _setupDeviceListener();
//                   _loadSchedules();
//                 },
//               ),
//             Card(
//               margin: const EdgeInsets.symmetric(vertical: 8),
//               child: ListTile(
//                 title: const Text("Status Perangkat", style: TextStyle(fontWeight: FontWeight.bold)),
//                 subtitle: Text(deviceStatus['online'] == true ? "Online" : "Offline"),
//               ),
//             ),
//             Card(
//               margin: const EdgeInsets.symmetric(vertical: 8),
//               child: ListTile(
//                 title: const Text("Persediaan Pakan", style: TextStyle(fontWeight: FontWeight.bold)),
//                 subtitle: Text(feedStatus),
//               ),
//             ),
//             Row(
//               children: [
//                 Expanded(
//                   child: Card(
//                     margin: const EdgeInsets.symmetric(vertical: 8),
//                     child: ListTile(
//                       title: const Text(
//                         "Kekeruhan Air",
//                         style: TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                       subtitle: Text(turbidityStatus),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: Card(
//                     margin: const EdgeInsets.symmetric(vertical: 8),
//                     child: ListTile(
//                       title: const Text(
//                         "Baterai",
//                         style: TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                       // → Ambil hanya battery_percent dan tampilkan dengan “%”
//                       subtitle: Builder(
//                         builder: (_) {
//                           final dyn = deviceSensors['battery_percent'];
//                           final int? pct = dyn is num
//                               ? dyn.toInt()
//                               : (dyn is String ? int.tryParse(dyn) : null);
//                           return Text(pct != null ? "$pct %" : "Unknown");
//                         },
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//
//             Card(
//               margin: const EdgeInsets.symmetric(vertical: 8),
//               child: ListTile(
//                 title: const Text("Jadwal Pemberian Pakan", style: TextStyle(fontWeight: FontWeight.bold)),
//                 subtitle: Text(
//                   _schedules['entries'] != null
//                       ? "Active: ${_schedules['active'] == true ? 'Yes' : 'No'}\n"
//                       "${(_schedules['entries'] as Map).values.map((e) => e['time']).join(', ')}"
//                       : "No schedule set",
//                 ),
//               ),
//             ),
//             ElevatedButton(
//               onPressed: _selectedDeviceId != null ? () => _sendFeedCommand(auto: false) : null,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.green,
//                 minimumSize: const Size(double.infinity, 50),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//               ),
//               child: const Text("Beri Makan Sekarang"),
//             ),
//             const SizedBox(height: 10),
//             ElevatedButton(
//               onPressed: _navigateToLogPage,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.deepPurpleAccent,
//                 minimumSize: const Size(double.infinity, 50),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//               ),
//               child: const Text("Riwayat Aktivitas"),
//             ),
//             ElevatedButton(
//               onPressed: _selectedDeviceId != null ? _navigateToSchedulePage : null,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.deepPurple,
//                 minimumSize: const Size(double.infinity, 50),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//               ),
//               child: const Text("Atur Jadwal"),
//             ),
//             ElevatedButton(
//               onPressed: _navigateToDeviceManager,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.deepPurple[800],
//                 minimumSize: const Size(double.infinity, 50),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//               ),
//               child: const Text("Kelola Perangkat"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class DeviceManagerPage extends StatefulWidget {
//   final String userId;
//   final List<String> connectedDevices;
//
//   const DeviceManagerPage({
//     super.key,
//     required this.userId,
//     required this.connectedDevices,
//   });
//
//   @override
//   State<DeviceManagerPage> createState() => _DeviceManagerPageState();
// }
//
// class _DeviceManagerPageState extends State<DeviceManagerPage> {
//   final _deviceIdController = TextEditingController();
//   late Map<String, dynamic> _userDevices;
//
//   @override
//   void initState() {
//     super.initState();
//     _userDevices = {for (var device in widget.connectedDevices) device: true};
//   }
//
//   Future<void> _addDevice() async {
//     final deviceId = _deviceIdController.text.trim();
//     if (deviceId.isEmpty || _userDevices.containsKey(deviceId)) return;
//
//     final deviceRef = FirebaseDatabase.instance.ref('devices/$deviceId/info');
//     final snapshot = await deviceRef.get();
//
//     if (snapshot.exists) {
//       setState(() {
//         _userDevices[deviceId] = {
//           'paired_at': DateTime.now().toIso8601String(),
//           'role': 'owner'
//         };
//       });
//       _deviceIdController.clear();
//
//       await FirebaseFirestore.instance
//           .collection('users')
//           .doc(widget.userId)
//           .update({
//         'devices': _userDevices,
//       });
//     } else {
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Device not found in system")),
//       );
//     }
//   }
//
//   Future<void> _removeDevice(String deviceId) async {
//     setState(() {
//       _userDevices.remove(deviceId);
//     });
//
//     await FirebaseFirestore.instance
//         .collection('users')
//         .doc(widget.userId)
//         .update({
//       'devices': _userDevices,
//     });
//   }
//
//   @override
//   void dispose() {
//     _deviceIdController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Manage Devices")),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _deviceIdController,
//                     decoration: const InputDecoration(labelText: "Device ID"),
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.add),
//                   onPressed: _addDevice,
//                 ),
//               ],
//             ),
//             Expanded(
//               child: ListView.builder(
//                 itemCount: _userDevices.length,
//                 itemBuilder: (context, index) {
//                   final deviceId = _userDevices.keys.elementAt(index);
//                   return ListTile(
//                     title: Text(deviceId),
//                     trailing: IconButton(
//                       icon: const Icon(Icons.delete),
//                       onPressed: () => _removeDevice(deviceId),
//                     ),
//                   );
//                 },
//               ),
//             ),
//             ElevatedButton(
//               onPressed: () => Navigator.pop(context, _userDevices),
//               style: ElevatedButton.styleFrom(
//                 minimumSize: const Size(double.infinity, 50),
//               ),
//               child: const Text("Save"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class FeedSuccessPage extends StatelessWidget {
//   final String time;
//
//   const FeedSuccessPage({super.key, required this.time});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Feeding Successful")),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.check_circle, color: Colors.green, size: 100),
//             const SizedBox(height: 20),
//             Text(
//               "Fish fed successfully at $time",
//               style: const TextStyle(fontSize: 18),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text("Back to Dashboard"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class ActivityLogPage extends StatelessWidget {
//   final List<Map<String, dynamic>> logs;
//
//   const ActivityLogPage({super.key, required this.logs});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Activity Log")),
//       body: ListView.builder(
//         itemCount: logs.length,
//         itemBuilder: (context, index) {
//           final log = logs[index];
//           return ListTile(
//             leading: log['type'] == 'feed'
//                 ? const Icon(Icons.food_bank)
//                 : const Icon(Icons.settings),
//             title: Text(
//               log['type'] == 'feed'
//                   ? "Feeding (${log['mode']})"
//                   : "Schedule Updated",
//             ),
//             subtitle: Text(log['timestamp']),
//           );
//         },
//       ),
//     );
//   }
// }
//
// // class SchedulePage extends StatefulWidget {
// //   final Map<String, dynamic> initialSchedule;
// //
// //   const SchedulePage({super.key, required this.initialSchedule});
// //
// //   @override
// //   State<SchedulePage> createState() => _SchedulePageState();
// // }
// // import 'package:flutter/material.dart';
//
// class SchedulePage extends StatefulWidget {
//   final Map<String, dynamic> initialSchedule;
//
//   const SchedulePage({super.key, required this.initialSchedule});
//
//   @override
//   State<SchedulePage> createState() => _SchedulePageState();
// }
//
// class _SchedulePageState extends State<SchedulePage> {
//   late bool _active;
//   late Map<String, Map<String, dynamic>> _entries;
//
//   @override
//   void initState() {
//     super.initState();
//     _active = widget.initialSchedule['active'] == true;
//     final rawEntries = widget.initialSchedule['entries'] as Map<String, dynamic>?;
//     _entries = rawEntries?.map((key, value) {
//       final mapValue = Map<String, dynamic>.from(value as Map);
//       return MapEntry(key, {
//         'time': mapValue['time'],
//         'enabled': mapValue['enabled'] == true,
//         'last_run': mapValue['last_run'] ?? ''
//       });
//     }) ?? {};
//   }
//
//   Future<void> _pickTime() async {
//     int selectedHour = DateTime.now().hour;
//     int selectedMinute = DateTime.now().minute;
//
//     await showModalBottomSheet(
//       context: context,
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (ctx, setModalState) {
//             return Container(
//               height: 300,
//               padding: const EdgeInsets.symmetric(vertical: 16),
//               child: Column(
//                 children: [
//                   const Text(
//                     "Enter feeding time",
//                     style: TextStyle(fontSize: 18),
//                   ),
//                   const SizedBox(height: 12),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       // Hour picker
//                       Column(
//                         children: [
//                           IconButton(
//                             icon: const Icon(Icons.keyboard_arrow_up),
//                             onPressed: () => setModalState(() {
//                               selectedHour = (selectedHour + 1) % 24;
//                             }),
//                           ),
//                           Text(
//                             selectedHour.toString().padLeft(2, '0'),
//                             style: const TextStyle(
//                               fontSize: 32,
//                               fontFamily: 'RobotoMono',
//                             ),
//                           ),
//                           IconButton(
//                             icon: const Icon(Icons.keyboard_arrow_down),
//                             onPressed: () => setModalState(() {
//                               selectedHour = (selectedHour + 23) % 24;
//                             }),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(width: 16),
//                       const Text(":", style: TextStyle(fontSize: 32)),
//                       const SizedBox(width: 16),
//                       // Minute picker
//                       Column(
//                         children: [
//                           IconButton(
//                             icon: const Icon(Icons.keyboard_arrow_up),
//                             onPressed: () => setModalState(() {
//                               selectedMinute = (selectedMinute + 1) % 60;
//                             }),
//                           ),
//                           Text(
//                             selectedMinute.toString().padLeft(2, '0'),
//                             style: const TextStyle(
//                               fontSize: 32,
//                               fontFamily: 'RobotoMono',
//                             ),
//                           ),
//                           IconButton(
//                             icon: const Icon(Icons.keyboard_arrow_down),
//                             onPressed: () => setModalState(() {
//                               selectedMinute = (selectedMinute + 59) % 60;
//                             }),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                   const Spacer(),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: [
//                       TextButton(
//                         onPressed: () => Navigator.of(context).pop(),
//                         child: const Text("Cancel"),
//                       ),
//                       ElevatedButton(
//                         onPressed: () {
//                           final timeStr = '${selectedHour.toString().padLeft(2,'0')}:${selectedMinute.toString().padLeft(2,'0')}';
//                           final now = DateTime.now();
//                           final today = '${now.year.toString().padLeft(4,'0')}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')}';
//                           final entryId = DateTime.now().millisecondsSinceEpoch.toString();
//                           setState(() {
//                             _entries[entryId] = {
//                               'time': timeStr,
//                               'enabled': true,
//                               'last_run': today,
//                             };
//                           });
//                           Navigator.of(context).pop();
//                         },
//                         child: const Text("OK"),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
//
//   void _removeTime(String entryId) {
//     setState(() {
//       _entries.remove(entryId);
//     });
//   }
//
//   void _toggleEnabled(String entryId, bool? value) {
//     if (value == null) return;
//     setState(() {
//       _entries[entryId]!['enabled'] = value;
//     });
//   }
//
//   void _saveSchedule() {
//     final result = {
//       'active': _active,
//       'entries': _entries,
//     };
//     Navigator.pop(context, result);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Set Feeding Schedule")),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             SwitchListTile(
//               title: const Text('Enable Scheduling'),
//               value: _active,
//               onChanged: (v) => setState(() => _active = v),
//             ),
//             const SizedBox(height: 8),
//             ElevatedButton.icon(
//               onPressed: _pickTime,
//               icon: const Icon(Icons.access_time),
//               label: const Text("Add Schedule Time 24h"),
//               style: ElevatedButton.styleFrom(
//                 minimumSize: const Size.fromHeight(48),
//               ),
//             ),
//             const SizedBox(height: 16),
//             Expanded(
//               child: _entries.isEmpty
//                   ? const Center(child: Text('No schedule times added.'))
//                   : ListView(
//                 children: _entries.entries.map((e) {
//                   final id = e.key;
//                   final d = e.value;
//                   return Card(
//                     margin: const EdgeInsets.symmetric(vertical: 4),
//                     child: ListTile(
//                       leading: Checkbox(
//                         value: d['enabled'] as bool,
//                         onChanged: (v) => _toggleEnabled(id, v),
//                       ),
//                       title: Text(
//                         d['time'],
//                         style: const TextStyle(
//                           fontFamily: 'RobotoMono',
//                           fontSize: 18,
//                         ),
//                       ),
//                       subtitle: d['last_run'] != ''
//                           ? Text('Last run: ${d['last_run']}')
//                           : null,
//                       trailing: IconButton(
//                         icon: const Icon(Icons.delete),
//                         onPressed: () => _removeTime(id),
//                       ),
//                     ),
//                   );
//                 }).toList(),
//               ),
//             ),
//             ElevatedButton(
//               onPressed: _saveSchedule,
//               child: const Text("Save Schedule"),
//               style: ElevatedButton.styleFrom(
//                 minimumSize: const Size.fromHeight(48),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // class _SchedulePageState extends State<SchedulePage> {
// //   late bool _active;
// //   late Map<String, Map<String, dynamic>> _entries;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     // Initialize active flag and entries safely
// //     _active = widget.initialSchedule['active'] == true;
// //     final rawEntries = widget.initialSchedule['entries'] as Map<String, dynamic>?;
// //     _entries = rawEntries?.map((key, value) {
// //       final mapValue = Map<String, dynamic>.from(value as Map);
// //       return MapEntry(key, {
// //         'time': mapValue['time'],
// //         'enabled': mapValue['enabled'] == true,
// //         // retain any existing last_run
// //         'last_run': mapValue['last_run'] ?? ''
// //       });
// //     }) ?? {};
// //   }
// //
// //   // Future<void> _pickTime() async {
// //   //   final picked = await showTimePicker(
// //   //     context: context,
// //   //     initialTime: TimeOfDay.now(),
// //   //     initialEntryMode: TimePickerEntryMode.input,  // digital input mode
// //   //     helpText: 'Enter feeding time',                // optional prompt
// //   //   );
// //   //
// //   //   if (picked != null) {
// //   //     // Format waktu untuk display dan storage
// //   //     final timeStr = picked.format(context);
// //   //
// //   //     // Tanggal hari ini untuk last_run
// //   //     final nowDt = DateTime.now();
// //   //     final today = '${nowDt.year.toString().padLeft(4,'0')}-${nowDt.month.toString().padLeft(2,'0')}-${nowDt.day.toString().padLeft(2,'0')}';
// //   //
// //   //     final entryId = DateTime.now().millisecondsSinceEpoch.toString();
// //   //
// //   //     setState(() {
// //   //       _entries[entryId] = {
// //   //         'time': timeStr,
// //   //         'enabled': true,
// //   //         'last_run': today,  // set initial last_run agar tidak langsung trigger
// //   //       };
// //   //     });
// //   //   }
// //   // }
// //   // Future<void> _pickTime() async {
// //   //   // We'll keep the current selection in local variables:
// //   //   int selectedHour = TimeOfDay.now().hour;
// //   //   int selectedMinute = TimeOfDay.now().minute;
// //   //
// //   //   // Show our custom bottom‐sheet
// //   //   await showModalBottomSheet(
// //   //     context: context,
// //   //     builder: (context) {
// //   //       return Container(
// //   //         height: 300,
// //   //         padding: const EdgeInsets.symmetric(vertical: 16),
// //   //         child: Column(
// //   //           children: [
// //   //             Text("Enter feeding time", style: Theme.of(context).textTheme.titleMedium),
// //   //             const SizedBox(height: 8),
// //   //             Row(
// //   //               mainAxisAlignment: MainAxisAlignment.center,
// //   //               children: [
// //   //                 // Hour picker with arrows
// //   //                 Column(
// //   //                   children: [
// //   //                     IconButton(
// //   //                       icon: const Icon(Icons.keyboard_arrow_up),
// //   //                       onPressed: () => setState(() {
// //   //                         selectedHour = (selectedHour + 1) % 24;
// //   //                       }),
// //   //                     ),
// //   //                     Text(
// //   //                       selectedHour.toString().padLeft(2, '0'),
// //   //                       style: const TextStyle(fontSize: 32, fontFeatures: [FontFeature.tabularFigures()]),
// //   //                     ),
// //   //                     IconButton(
// //   //                       icon: const Icon(Icons.keyboard_arrow_down),
// //   //                       onPressed: () => setState(() {
// //   //                         selectedHour = (selectedHour + 23) % 24;
// //   //                       }),
// //   //                     ),
// //   //                   ],
// //   //                 ),
// //   //                 const SizedBox(width: 16),
// //   //                 Text(":", style: TextStyle(fontSize: 32)),
// //   //                 const SizedBox(width: 16),
// //   //                 // Minute picker with arrows
// //   //                 Column(
// //   //                   children: [
// //   //                     IconButton(
// //   //                       icon: const Icon(Icons.keyboard_arrow_up),
// //   //                       onPressed: () => setState(() {
// //   //                         selectedMinute = (selectedMinute + 1) % 60;
// //   //                       }),
// //   //                     ),
// //   //                     Text(
// //   //                       selectedMinute.toString().padLeft(2, '0'),
// //   //                       style: const TextStyle(fontSize: 32, fontFeatures: [FontFeature.tabularFigures()]),
// //   //                     ),
// //   //                     IconButton(
// //   //                       icon: const Icon(Icons.keyboard_arrow_down),
// //   //                       onPressed: () => setState(() {
// //   //                         selectedMinute = (selectedMinute + 59) % 60;
// //   //                       }),
// //   //                     ),
// //   //                   ],
// //   //                 ),
// //   //               ],
// //   //             ),
// //   //             const Spacer(),
// //   //             Row(
// //   //               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// //   //               children: [
// //   //                 TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
// //   //                 ElevatedButton(
// //   //                   onPressed: () {
// //   //                     // build 24-hour HH:mm string
// //   //                     final timeStr = '${selectedHour.toString().padLeft(2,'0')}:${selectedMinute.toString().padLeft(2,'0')}';
// //   //                     // today's date
// //   //                     final nowDt = DateTime.now();
// //   //                     final today = '${nowDt.year.toString().padLeft(4,'0')}-'
// //   //                         '${nowDt.month.toString().padLeft(2,'0')}-'
// //   //                         '${nowDt.day.toString().padLeft(2,'0')}';
// //   //                     final entryId = DateTime.now().millisecondsSinceEpoch.toString();
// //   //                     setState(() {
// //   //                       _entries[entryId] = {
// //   //                         'time': timeStr,
// //   //                         'enabled': true,
// //   //                         'last_run': today,
// //   //                       };
// //   //                     });
// //   //                     Navigator.pop(context);
// //   //                   },
// //   //                   child: const Text("OK"),
// //   //                 )
// //   //               ],
// //   //             )
// //   //           ],
// //   //         ),
// //   //       );
// //   //     },
// //   //   );
// //   // }
// //
// //
// //   void _removeTime(String entryId) {
// //     setState(() {
// //       _entries.remove(entryId);
// //     });
// //   }
// //
// //   void _toggleEnabled(String entryId, bool? value) {
// //     if (value == null) return;
// //     setState(() {
// //       _entries[entryId]!['enabled'] = value;
// //       // do not modify last_run here
// //     });
// //   }
// //
// //   void _saveSchedule() {
// //     // Build result map including last_run
// //     final result = {
// //       'active': _active,
// //       'entries': _entries,
// //     };
// //     Navigator.pop(context, result);
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: const Text("Set Feeding Schedule")),
// //       body: Padding(
// //         padding: const EdgeInsets.all(16),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.stretch,
// //           children: [
// //             SwitchListTile(
// //               title: const Text('Enable Scheduling'),
// //               value: _active,
// //               onChanged: (value) => setState(() => _active = value),
// //             ),
// //             const SizedBox(height: 8),
// //             ElevatedButton.icon(
// //               onPressed: _pickTime,
// //               icon: const Icon(Icons.access_time),
// //               label: const Text("Add Schedule Time"),
// //             ),
// //             const SizedBox(height: 16),
// //             Expanded(
// //               child: _entries.isEmpty
// //                   ? const Center(child: Text('No schedule times added.'))
// //                   : ListView(
// //                 children: _entries.entries.map((entry) {
// //                   final id = entry.key;
// //                   final data = entry.value;
// //                   return Card(
// //                     margin: const EdgeInsets.symmetric(vertical: 4),
// //                     child: ListTile(
// //                       leading: Checkbox(
// //                         value: data['enabled'] as bool,
// //                         onChanged: (val) => _toggleEnabled(id, val),
// //                       ),
// //                       title: Text(data['time'], style: const TextStyle(fontFeatures: [FontFeature.tabularFigures()])),
// //                       subtitle: data['last_run'] != null && (data['last_run'] as String).isNotEmpty
// //                           ? Text('Last run: ${data['last_run']}')
// //                           : null,
// //                       trailing: IconButton(
// //                         icon: const Icon(Icons.delete),
// //                         onPressed: () => _removeTime(id),
// //                       ),
// //                     ),
// //                   );
// //                 }).toList(),
// //               ),
// //             ),
// //             ElevatedButton(
// //               onPressed: _saveSchedule,
// //               child: const Text("Save Schedule"),
// //               style: ElevatedButton.styleFrom(
// //                 minimumSize: const Size(double.infinity, 48),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
//
// //
// // class SchedulePage extends StatefulWidget {
// //   final Map<String, dynamic> initialSchedule;
// //
// //   const SchedulePage({super.key, required this.initialSchedule});
// //
// //   @override
// //   State<SchedulePage> createState() => _SchedulePageState();
// // }
// //
// // class _SchedulePageState extends State<SchedulePage> {
// //   late Map<String, dynamic> _scheduleData;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     // Clone data awal dan pastikan 'entries' & 'active' terdefinisi
// //     _scheduleData = Map.from(widget.initialSchedule);
// //     _scheduleData['entries'] = _scheduleData['entries'] ?? {};
// //     _scheduleData['active'] = _scheduleData['active'] ?? false;
// //   }
// //
// //   Future<void> _pickTime() async {
// //     final picked = await showTimePicker(
// //       context: context,
// //       initialTime: TimeOfDay.now(),
// //     );
// //
// //     if (picked != null) {
// //       // Simpan dalam format 24-jam "HH:mm"
// //       final timeStr = '${picked.hour.toString().padLeft(2, '0')}:'
// //           '${picked.minute.toString().padLeft(2, '0')}';
// //       final entryId = DateTime.now().millisecondsSinceEpoch.toString();
// //
// //       setState(() {
// //         _scheduleData['entries'][entryId] = {
// //           'time': timeStr,
// //           'enabled': true,
// //         };
// //       });
// //     }
// //   }
// //
// //   void _removeTime(String entryId) {
// //     setState(() {
// //       _scheduleData['entries'].remove(entryId);
// //     });
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final entries = _scheduleData['entries'] as Map<String, dynamic>;
// //
// //     return Scaffold(
// //       appBar: AppBar(title: const Text("Set Feeding Schedule")),
// //       body: Column(
// //         children: [
// //           SwitchListTile(
// //             title: const Text('Enable Scheduling'),
// //             value: _scheduleData['active'] as bool,
// //             onChanged: (value) {
// //               setState(() {
// //                 _scheduleData['active'] = value;
// //               });
// //             },
// //           ),
// //           ElevatedButton(
// //             onPressed: _pickTime,
// //             child: const Text("Add Schedule Time"),
// //           ),
// //           Expanded(
// //             child: ListView.builder(
// //               itemCount: entries.length,
// //               itemBuilder: (context, index) {
// //                 final entryId = entries.keys.elementAt(index);
// //                 final entry = entries[entryId] as Map<String, dynamic>;
// //                 return ListTile(
// //                   title: Text(entry['time']),
// //                   trailing: IconButton(
// //                     icon: const Icon(Icons.delete),
// //                     onPressed: () => _removeTime(entryId),
// //                   ),
// //                 );
// //               },
// //             ),
// //           ),
// //           ElevatedButton(
// //             onPressed: () {
// //               Navigator.pop(context, _scheduleData);
// //             },
// //             child: const Text("Save Schedule"),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
//
// // class SchedulePage extends StatefulWidget {
// //   final Map<String, dynamic> initialSchedule;
// //
// //   const SchedulePage({super.key, required this.initialSchedule});
// //
// //   @override
// //   State<SchedulePage> createState() => _SchedulePageState();
// // }
// //
// // class _SchedulePageState extends State<SchedulePage> {
// //   late Map<String, dynamic> _scheduleData;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _scheduleData = Map.from(widget.initialSchedule);
// //     _scheduleData['entries'] ??= {};
// //   }
// //
// //   Future<void> _pickTime() async {
// //     final picked = await showTimePicker(
// //       context: context,
// //       initialTime: TimeOfDay.now(),
// //     );
// //
// //     if (picked != null) {
// //       final timeStr = picked.format(context);
// //       final entryId = DateTime.now().millisecondsSinceEpoch.toString();
// //
// //       setState(() {
// //         _scheduleData['entries'][entryId] = {
// //           'time': timeStr,
// //           'enabled': true
// //         };
// //       });
// //     }
// //   }
// //
// //   void _removeTime(String entryId) {
// //     setState(() {
// //       _scheduleData['entries'].remove(entryId);
// //     });
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final entries = _scheduleData['entries'] as Map<String, dynamic>;
// //
// //     return Scaffold(
// //       appBar: AppBar(title: const Text("Set Feeding Schedule")),
// //       body: Column(
// //         children: [
// //           SwitchListTile(
// //             title: const Text('Enable Scheduling'),
// //             value: _scheduleData['active'] ?? false,
// //             onChanged: (value) {
// //               setState(() {
// //                 _scheduleData['active'] = value;
// //               });
// //             },
// //           ),
// //           ElevatedButton(
// //             onPressed: _pickTime,
// //             child: const Text("Add Schedule Time"),
// //           ),
// //           Expanded(
// //             child: ListView.builder(
// //               itemCount: entries.length,
// //               itemBuilder: (context, index) {
// //                 final entryId = entries.keys.elementAt(index);
// //                 final entry = entries[entryId] as Map<String, dynamic>;
// //                 return ListTile(
// //                   title: Text(entry['time']),
// //                   trailing: IconButton(
// //                     icon: const Icon(Icons.delete),
// //                     onPressed: () => _removeTime(entryId),
// //                   ),
// //                 );
// //               },
// //             ),
// //           ),
// //           ElevatedButton(
// //             onPressed: () {
// //               Navigator.pop(context, _scheduleData);
// //             },
// //             child: const Text("Save Schedule"),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
