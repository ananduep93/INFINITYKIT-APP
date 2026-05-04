import 'package:flutter/material.dart';

class FactorialCalculatorScreen extends StatefulWidget {
  const FactorialCalculatorScreen({super.key});

  @override
  State<FactorialCalculatorScreen> createState() => _FactorialCalculatorScreenState();
}

class _FactorialCalculatorScreenState extends State<FactorialCalculatorScreen> {
  final _controller = TextEditingController();
  String _result = '';

  void _calculate() {
    int? n = int.tryParse(_controller.text);
    if (n == null || n < 0) return;
    if (n > 20) {
      setState(() => _result = 'Number too large!');
      return;
    }
    double fact = 1;
    for (int i = 1; i <= n; i++) {
      fact *= i;
    }
    setState(() => _result = 'Factorial: ${fact.toInt()}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Factorial Calculator')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Enter Number (0-20)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _calculate, child: const Text('Calculate')),
            const SizedBox(height: 40),
            Text(_result, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
