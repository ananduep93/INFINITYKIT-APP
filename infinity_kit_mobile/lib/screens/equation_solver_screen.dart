import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/theme.dart';

class EquationSolverScreen extends StatefulWidget {
  const EquationSolverScreen({super.key});

  @override
  State<EquationSolverScreen> createState() => _EquationSolverScreenState();
}

class _EquationSolverScreenState extends State<EquationSolverScreen> {
  final _aController = TextEditingController();
  final _bController = TextEditingController();
  String _result = '';
  String _explanation = '';

  void _solve() {
    double? a = double.tryParse(_aController.text);
    double? b = double.tryParse(_bController.text);

    if (a == null || b == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter valid coefficients')));
      return;
    }

    setState(() {
      if (a == 0) {
        if (b == 0) {
          _result = 'Infinite Solutions';
          _explanation = '0x + 0 = 0 is always true.';
        } else {
          _result = 'No Solution';
          _explanation = '0x + $b = 0 is impossible.';
        }
      } else {
        double x = -b / a;
        _result = 'x = ${x.toStringAsFixed(2)}';
        _explanation = 'Step 1: Subtract $b from both sides\nStep 2: Divide by $a';
      }
    });
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🧮 Linear Equation Solver')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              'Solve equations of the form: ax + b = 0',
              style: TextStyle(color: AppTheme.subtitleColor, fontSize: 16),
            ),
            const SizedBox(height: 40),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _aController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Coefficient (a)',
                      hintText: 'e.g. 5',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('x +', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  child: TextField(
                    controller: _bController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Constant (b)',
                      hintText: 'e.g. 10',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 12),
                  child: Text('= 0', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _solve,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text('Solve Equation', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            if (_result.isNotEmpty) ...[
              const SizedBox(height: 40),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
                ),
                child: Column(
                  children: [
                    const Text('Solution', style: TextStyle(color: AppTheme.subtitleColor)),
                    const SizedBox(height: 10),
                    Text(
                      _result,
                      style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 10),
                    Text(
                      _explanation,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontStyle: FontStyle.italic, color: AppTheme.subtitleColor),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
