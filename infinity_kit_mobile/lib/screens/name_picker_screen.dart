import 'dart:math';
import 'package:flutter/material.dart';

class NamePickerScreen extends StatefulWidget {
  const NamePickerScreen({super.key});

  @override
  State<NamePickerScreen> createState() => _NamePickerScreenState();
}

class _NamePickerScreenState extends State<NamePickerScreen> {
  final _controller = TextEditingController();
  String _winner = '';

  void _pick() {
    List<String> names = _controller.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    if (names.isNotEmpty) {
      setState(() => _winner = names[Random().nextInt(names.length)]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Random Name Picker')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              maxLines: 5,
              decoration: const InputDecoration(labelText: 'Enter names separated by comma', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _pick, child: const Text('Pick a Random Name')),
            const SizedBox(height: 40),
            if (_winner.isNotEmpty)
              Text('Winner: \$_winner', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue)),
          ],
        ),
      ),
    );
  }
}
