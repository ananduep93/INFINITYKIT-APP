import 'package:flutter/material.dart';
import '../utils/theme.dart';

class UnitConverterScreen extends StatefulWidget {
  const UnitConverterScreen({super.key});

  @override
  State<UnitConverterScreen> createState() => _UnitConverterScreenState();
}

class _UnitConverterScreenState extends State<UnitConverterScreen> {
  String selectedCategory = 'Length';
  double inputValue = 1.0;
  String fromUnit = 'm';
  String toUnit = 'cm';
  double result = 100.0;

  final Map<String, Map<String, double>> conversionRates = {
    'Length': {
      'mm': 0.001,
      'cm': 0.01,
      'm': 1.0,
      'km': 1000.0,
    },
    'Weight': {
      'mg': 0.000001,
      'g': 0.001,
      'kg': 1.0,
    },
    'Temperature': {
      '°C': 1.0,
      '°F': 1.0,
      'K': 1.0,
    },
  };

  void _calculate() {
    setState(() {
      if (selectedCategory == 'Temperature') {
        double c = 0;
        // Convert to Celsius first
        if (fromUnit == '°C') {
          c = inputValue;
        } else if (fromUnit == '°F') {
          c = (inputValue - 32) * 5 / 9;
        } else if (fromUnit == 'K') {
          c = inputValue - 273.15;
        }

        // Convert from Celsius to target
        if (toUnit == '°C') {
          result = c;
        } else if (toUnit == '°F') {
          result = (c * 9 / 5) + 32;
        } else if (toUnit == 'K') {
          result = c + 273.15;
        }
      } else {
        double baseValue = inputValue * (conversionRates[selectedCategory]?[fromUnit] ?? 1.0);
        result = baseValue / (conversionRates[selectedCategory]?[toUnit] ?? 1.0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📏 Unit Converter'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _buildDropdown('Category', selectedCategory, conversionRates.keys.toList(), (val) {
              setState(() {
                selectedCategory = val!;
                fromUnit = conversionRates[selectedCategory]!.keys.first;
                toUnit = conversionRates[selectedCategory]!.keys.toList()[1];
                _calculate();
              });
            }),
            const SizedBox(height: 25),
            TextField(
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                labelText: 'Value to Convert',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.edit_note),
              ),
              onChanged: (val) {
                inputValue = double.tryParse(val) ?? 0.0;
                _calculate();
              },
            ),
            const SizedBox(height: 25),
            Row(
              children: [
                Expanded(
                  child: _buildDropdown('From', fromUnit, conversionRates[selectedCategory]!.keys.toList(), (val) {
                    setState(() {
                      fromUnit = val!;
                      _calculate();
                    });
                  }),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.0),
                  child: Icon(Icons.swap_horiz, color: AppTheme.primaryColor),
                ),
                Expanded(
                  child: _buildDropdown('To', toUnit, conversionRates[selectedCategory]!.keys.toList(), (val) {
                    setState(() {
                      toUnit = val!;
                      _calculate();
                    });
                  }),
                ),
              ],
            ),
            const SizedBox(height: 40),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
              ),
              child: Column(
                children: [
                  const Text('Converted Result', style: TextStyle(color: AppTheme.subtitleColor, fontSize: 16)),
                  const SizedBox(height: 12),
                  Text(
                    '${result.toStringAsFixed(result.abs() < 0.0001 ? 8 : 4)} $toUnit',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label, 
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
    );
  }
}
