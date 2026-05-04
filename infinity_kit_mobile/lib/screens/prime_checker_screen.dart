import 'package:flutter/material.dart';


class PrimeCheckerScreen extends StatefulWidget {
  const PrimeCheckerScreen({super.key});

  @override
  State<PrimeCheckerScreen> createState() => _PrimeCheckerScreenState();
}

class _PrimeCheckerScreenState extends State<PrimeCheckerScreen> {
  final _controller = TextEditingController();
  String _result = '';
  Color _color = Colors.grey;

  void _checkPrime() {
    int? n = int.tryParse(_controller.text);
    if (n == null) return;
    if (n < 2) {
      setState(() { _result = 'Not Prime'; _color = Colors.red; });
      return;
    }
    bool isPrime = true;
    for (int i = 2; i <= n ~/ 2; i++) {
      if (n % i == 0) {
        isPrime = false;
        break;
      }
    }
    setState(() {
      _result = isPrime ? 'It is a Prime Number!' : 'Not a Prime Number';
      _color = isPrime ? Colors.green : Colors.red;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prime Checker')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Enter Number', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _checkPrime, child: const Text('Check')),
            const SizedBox(height: 40),
            Text(_result, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _color)),
          ],
        ),
      ),
    );
  }
}
