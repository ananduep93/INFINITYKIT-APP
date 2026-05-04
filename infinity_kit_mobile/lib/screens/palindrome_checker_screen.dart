import 'package:flutter/material.dart';

class PalindromeCheckerScreen extends StatefulWidget {
  const PalindromeCheckerScreen({super.key});

  @override
  State<PalindromeCheckerScreen> createState() => _PalindromeCheckerScreenState();
}

class _PalindromeCheckerScreenState extends State<PalindromeCheckerScreen> {
  final _controller = TextEditingController();
  String _result = '';

  void _check() {
    String text = _controller.text.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    String reversed = text.split('').reversed.join('');
    setState(() {
      _result = (text == reversed && text.isNotEmpty) ? 'It is a Palindrome!' : 'Not a Palindrome';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Palindrome Checker')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(labelText: 'Enter Text', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _check, child: const Text('Check')),
            const SizedBox(height: 40),
            Text(_result, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
