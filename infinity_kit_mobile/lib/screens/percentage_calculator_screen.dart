import 'package:flutter/material.dart';
import '../utils/theme.dart';

class PercentageCalculatorScreen extends StatefulWidget {
  const PercentageCalculatorScreen({super.key});

  @override
  State<PercentageCalculatorScreen> createState() => _PercentageCalculatorScreenState();
}

class _PercentageCalculatorScreenState extends State<PercentageCalculatorScreen> {
  final _val1Controller = TextEditingController();
  final _val2Controller = TextEditingController();
  double _result = 0;

  void _calculate() {
    final double v1 = double.tryParse(_val1Controller.text) ?? 0;
    final double v2 = double.tryParse(_val2Controller.text) ?? 0;
    if (v2 != 0) {
      setState(() => _result = (v1 / v2) * 100);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Percentage Calculator')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _val1Controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Value 1', border: OutlineInputBorder()),
              onChanged: (_) => _calculate(),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _val2Controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Out of (Value 2)', border: OutlineInputBorder()),
              onChanged: (_) => _calculate(),
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(15)),
              child: Column(
                children: [
                  const Text('Result', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('${_result.toStringAsFixed(2)}%', style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
