import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/theme.dart';

class DistanceCalculatorScreen extends StatefulWidget {
  const DistanceCalculatorScreen({super.key});

  @override
  State<DistanceCalculatorScreen> createState() => _DistanceCalculatorScreenState();
}

class _DistanceCalculatorScreenState extends State<DistanceCalculatorScreen> {
  final _x1Controller = TextEditingController();
  final _y1Controller = TextEditingController();
  final _x2Controller = TextEditingController();
  final _y2Controller = TextEditingController();
  String _result = '';

  void _calculate() {
    double? x1 = double.tryParse(_x1Controller.text);
    double? y1 = double.tryParse(_y1Controller.text);
    double? x2 = double.tryParse(_x2Controller.text);
    double? y2 = double.tryParse(_y2Controller.text);

    if (x1 == null || y1 == null || x2 == null || y2 == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter valid coordinates')));
      return;
    }

    double distance = sqrt(pow(x2 - x1, 2) + pow(y2 - y1, 2));
    
    setState(() {
      _result = distance.toStringAsFixed(4);
    });
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📏 Distance Calculator')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              'Calculate the distance between two points in a 2D plane.',
              style: TextStyle(color: AppTheme.subtitleColor),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(child: _buildPointInput('Point 1', 'x1', _x1Controller, 'y1', _y1Controller)),
                const SizedBox(width: 20),
                Expanded(child: _buildPointInput('Point 2', 'x2', _x2Controller, 'y2', _y2Controller)),
              ],
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: _calculate,
              icon: const Icon(Icons.calculate),
              label: const Text('Calculate Distance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
            if (_result.isNotEmpty) ...[
              const SizedBox(height: 40),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
                ),
                child: Column(
                  children: [
                    const Text('Straight Line Distance', style: TextStyle(color: AppTheme.subtitleColor)),
                    const SizedBox(height: 10),
                    Text(
                      _result,
                      style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                    ),
                    const SizedBox(height: 10),
                    const Text('Units', style: TextStyle(color: AppTheme.subtitleColor, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPointInput(String title, String labelX, TextEditingController controllerX, String labelY, TextEditingController controllerY) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 15),
        TextField(
          controller: controllerX,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: labelX,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controllerY,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: labelY,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}
