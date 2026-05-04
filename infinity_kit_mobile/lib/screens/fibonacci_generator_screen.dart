import 'package:flutter/material.dart';

class FibonacciGeneratorScreen extends StatefulWidget {
  const FibonacciGeneratorScreen({super.key});

  @override
  State<FibonacciGeneratorScreen> createState() => _FibonacciGeneratorScreenState();
}

class _FibonacciGeneratorScreenState extends State<FibonacciGeneratorScreen> {
  final _controller = TextEditingController();
  List<int> _sequence = [];

  void _generate() {
    final val = int.tryParse(_controller.text);
    if (val == null || val <= 0) return;
    int n = val > 50 ? 50 : val;

    List<int> seq = [0, 1];
    for (int i = 2; i < n; i++) {
      seq.add(seq[i - 1] + seq[i - 2]);
    }
    setState(() => _sequence = seq.take(n).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fibonacci Generator')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'How many numbers?', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _generate, child: const Text('Generate')),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _sequence.length,
                itemBuilder: (context, index) => ListTile(
                  leading: CircleAvatar(child: Text('${index + 1}')),
                  title: Text(_sequence[index].toString()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
