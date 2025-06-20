// --- FILE: feed_success_page.dart ---
import 'package:flutter/material.dart';

class FeedSuccessPage extends StatelessWidget {
  final String time;
  const FeedSuccessPage({super.key, required this.time});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Memberi Makan Sukses")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle,
                color: Colors.green, size: 100),
            const SizedBox(height: 20),
            Text(
              "Pemberian Makan Sukses Pada $time",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Kembali Ke Dashboard"),
            ),
          ],
        ),
      ),
    );
  }
}
