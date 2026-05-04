import 'package:flutter/material.dart';
import '../utils/theme.dart';

class BMICalculatorScreen extends StatefulWidget {
  const BMICalculatorScreen({super.key});

  @override
  State<BMICalculatorScreen> createState() => _BMICalculatorScreenState();
}

class _BMICalculatorScreenState extends State<BMICalculatorScreen> {
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  String _heightUnit = 'cm';
  String _weightUnit = 'kg';
  double? _bmi;
  String _message = '';
  Color _resultColor = AppTheme.primaryColor;

  void _calculateBMI() {
    double height = double.tryParse(_heightController.text) ?? 0;
    double weight = double.tryParse(_weightController.text) ?? 0;

    if (height > 0 && weight > 0) {
      double heightInMeters = height;
      if (_heightUnit == 'ft') {
        heightInMeters = height * 0.3048;
      } else {
        heightInMeters = height / 100;
      }

      double weightInKg = weight;
      if (_weightUnit == 'lbs') {
        weightInKg = weight * 0.453592;
      }

      if (heightInMeters > 0) {
        setState(() {
          _bmi = weightInKg / (heightInMeters * heightInMeters);
          if (_bmi! < 18.5) {
            _message = 'Underweight';
            _resultColor = Colors.orange;
          } else if (_bmi! < 25) {
            _message = 'Normal';
            _resultColor = Colors.green;
          } else if (_bmi! < 30) {
            _message = 'Overweight';
            _resultColor = Colors.orange;
          } else {
            _message = 'Obese';
            _resultColor = Colors.red;
          }
        });
      }
    } else {
      setState(() {
        _bmi = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🩺 BMI Calculator'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _heightController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Height',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.height),
                    ),
                    onChanged: (_) => _calculateBMI(),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<String>(
                    initialValue: _heightUnit,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    ),
                    items: ['cm', 'ft'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _heightUnit = value!;
                      });
                      _calculateBMI();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _weightController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Weight',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.monitor_weight_outlined),
                    ),
                    onChanged: (_) => _calculateBMI(),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<String>(
                    initialValue: _weightUnit,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    ),
                    items: ['kg', 'lbs'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _weightUnit = value!;
                      });
                      _calculateBMI();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            if (_bmi != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: _resultColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _resultColor.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    Text(
                      _bmi!.toStringAsFixed(1),
                      style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: _resultColor),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _message,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: _resultColor),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Body Mass Index (BMI) is a measure of body fat based on height and weight.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.subtitleColor),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

