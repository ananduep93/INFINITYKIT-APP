import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/theme.dart';

class TriangleCheckerScreen extends StatefulWidget {
  const TriangleCheckerScreen({super.key});

  @override
  State<TriangleCheckerScreen> createState() => _TriangleCheckerScreenState();
}

class _TriangleCheckerScreenState extends State<TriangleCheckerScreen> {
  final _aController = TextEditingController();
  final _bController = TextEditingController();
  final _cController = TextEditingController();
  String _type = '';
  String _description = '';
  Color _color = AppTheme.primaryColor;

  void _check() {
    double? a = double.tryParse(_aController.text);
    double? b = double.tryParse(_bController.text);
    double? c = double.tryParse(_cController.text);

    if (a == null || b == null || c == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter all three sides')));
      return;
    }

    setState(() {
      // Triangle inequality theorem
      if (a + b <= c || a + c <= b || b + c <= a) {
        _type = 'Invalid Triangle';
        _description = 'The sum of any two sides must be greater than the third side.';
        _color = Colors.red;
      } else {
        if (a == b && b == c) {
          _type = 'Equilateral';
          _description = 'All three sides are equal.';
          _color = Colors.green;
        } else if (a == b || b == c || a == c) {
          _type = 'Isosceles';
          _description = 'Two sides are equal.';
          _color = Colors.orange;
        } else {
          _type = 'Scalene';
          _description = 'All sides are different.';
          _color = Colors.blue;
        }
      }
    });
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📐 Triangle Checker')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              'Enter the lengths of the three sides to determine the triangle type.',
              style: TextStyle(color: AppTheme.subtitleColor),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                _buildSideInput('Side A', _aController),
                const SizedBox(width: 15),
                _buildSideInput('Side B', _bController),
                const SizedBox(width: 15),
                _buildSideInput('Side C', _cController),
              ],
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: _check,
              icon: const Icon(Icons.change_circle_outlined),
              label: const Text('Check Triangle Type', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
            if (_type.isNotEmpty) ...[
              const SizedBox(height: 40),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: _color.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: _color.withValues(alpha: 0.2)),
                ),
                child: Column(
                  children: [
                    const Text('Result', style: TextStyle(color: AppTheme.subtitleColor)),
                    const SizedBox(height: 10),
                    Text(
                      _type,
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: _color),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      _description,
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

  Widget _buildSideInput(String label, TextEditingController controller) {
    return Expanded(
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
