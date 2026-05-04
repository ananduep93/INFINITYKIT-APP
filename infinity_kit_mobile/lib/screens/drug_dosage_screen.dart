import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/theme.dart';

class DrugDosageScreen extends StatefulWidget {
  const DrugDosageScreen({super.key});

  @override
  State<DrugDosageScreen> createState() => _DrugDosageScreenState();
}

class _DrugDosageScreenState extends State<DrugDosageScreen> {
  final _weightController = TextEditingController();
  final _dosageController = TextEditingController();
  final _concentrationController = TextEditingController();
  String _weightUnit = 'kg';
  String _result = '';
  String _totalMg = '';

  void _calculate() {
    double? w = double.tryParse(_weightController.text);
    double? d = double.tryParse(_dosageController.text);
    double? c = double.tryParse(_concentrationController.text);

    if (w != null && d != null && c != null && c != 0) {
      double weightInKg = _weightUnit == 'kg' ? w : w * 0.453592;
      double totalMg = weightInKg * d;
      double volume = totalMg / c;
      
      setState(() {
        _result = volume.toStringAsFixed(2);
        _totalMg = totalMg.toStringAsFixed(1);
      });
      HapticFeedback.mediumImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('💊 Drug Dosage')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              'Calculate precise drug dosage based on body weight and concentration.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.subtitleColor),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildTextField('Weight', _weightController, Icons.monitor_weight),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _weightUnit,
                          decoration: const InputDecoration(border: OutlineInputBorder()),
                          items: ['kg', 'lbs'].map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                          onChanged: (val) => setState(() { _weightUnit = val!; _calculate(); }),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  _buildTextField('Dosage (mg/kg)', _dosageController, Icons.medical_services),
                  const SizedBox(height: 15),
                  _buildTextField('Concentration (mg/ml)', _concentrationController, Icons.biotech),
                ],
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _calculate,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text('Calculate Dosage', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            if (_result.isNotEmpty) ...[
              const SizedBox(height: 30),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.red[100]!),
                ),
                child: Column(
                  children: [
                    const Text('Required Dose', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text('$_result ml', style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: Colors.red)),
                    const SizedBox(height: 10),
                    Text('Total Amount: $_totalMg mg', style: const TextStyle(color: Colors.redAccent)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: (_) => _calculate(),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.primaryColor),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
