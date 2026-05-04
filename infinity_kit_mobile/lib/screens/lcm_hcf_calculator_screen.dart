import 'package:flutter/material.dart';
import '../utils/theme.dart';

class LcmHcfCalculatorScreen extends StatefulWidget {
  const LcmHcfCalculatorScreen({super.key});

  @override
  State<LcmHcfCalculatorScreen> createState() => _LcmHcfCalculatorScreenState();
}

class _LcmHcfCalculatorScreenState extends State<LcmHcfCalculatorScreen> {
  final _numbersController = TextEditingController();
  String _lcm = '';
  String _hcf = '';

  int _gcd(int a, int b) => b == 0 ? a : _gcd(b, a % b);
  int _lcmFunc(int a, int b) => a == 0 || b == 0 ? 0 : (a * b).abs() ~/ _gcd(a, b);

  void _calculate() {
    final input = _numbersController.text.trim();
    if (input.isEmpty) return;

    try {
      final nums = input.split(RegExp(r'[,\s]+'))
          .map((s) => int.tryParse(s.trim()))
          .where((n) => n != null)
          .cast<int>()
          .toList();

      if (nums.isEmpty) return;

      int currentHcf = nums[0];
      int currentLcm = nums[0];

      for (int i = 1; i < nums.length; i++) {
        currentHcf = _gcd(currentHcf, nums[i]);
        currentLcm = _lcmFunc(currentLcm, nums[i]);
      }

      setState(() {
        _hcf = currentHcf.toString();
        _lcm = currentLcm.toString();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error: Invalid input format')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('LCM & HCF Calculator')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _numbersController,
              decoration: const InputDecoration(
                labelText: 'Enter numbers (e.g. 12, 18, 30)',
                hintText: 'Separate by commas or spaces',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.numbers),
              ),
              keyboardType: TextInputType.text,
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
              child: const Text('Calculate LCM & HCF', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 40),
            if (_lcm.isNotEmpty) ...[
              _buildResultRow('Least Common Multiple (LCM)', _lcm),
              const SizedBox(height: 16),
              _buildResultRow('Highest Common Factor (HCF)', _hcf),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(25),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500, color: AppTheme.subtitleColor)),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
        ],
      ),
    );
  }
}
