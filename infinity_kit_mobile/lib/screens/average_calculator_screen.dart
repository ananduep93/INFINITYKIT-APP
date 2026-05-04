import 'package:flutter/material.dart';
import '../utils/theme.dart';

class AverageCalculatorScreen extends StatefulWidget {
  const AverageCalculatorScreen({super.key});

  @override
  State<AverageCalculatorScreen> createState() => _AverageCalculatorScreenState();
}

class _AverageCalculatorScreenState extends State<AverageCalculatorScreen> {
  final _controller = TextEditingController();
  String _avg = '-';
  String _sum = '-';

  void _calculate() {
    final input = _controller.text.trim();
    if (input.isEmpty) return;

    List<double> numbers = input.split(RegExp(r'[,\s]+'))
        .map((e) => double.tryParse(e.trim()))
        .where((n) => n != null)
        .cast<double>()
        .toList();

    if (numbers.isNotEmpty) {
      double total = numbers.reduce((a, b) => a + b);
      double avg = total / numbers.length;
      setState(() {
        _avg = avg.toStringAsFixed(2);
        _sum = total.toStringAsFixed(2);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Average Calculator')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
              ),
              child: TextField(
                controller: _controller,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Enter numbers (comma-separated)',
                  hintText: 'e.g., 10, 20, 30, 40, 50',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                  filled: true,
                  fillColor: Colors.transparent,
                ),
                keyboardType: TextInputType.text,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _calculate,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text('Calculate Average & Sum', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 40),
            Row(
              children: [
                Expanded(child: _buildResultBox('Average', _avg, AppTheme.primaryColor)),
                const SizedBox(width: 15),
                Expanded(child: _buildResultBox('Sum', _sum, Colors.purple)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultBox(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(color: color.withValues(alpha: 0.7), fontWeight: FontWeight.w500)),
          const SizedBox(height: 10),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
