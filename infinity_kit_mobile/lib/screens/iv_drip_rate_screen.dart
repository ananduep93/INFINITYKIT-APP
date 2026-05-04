import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/theme.dart';

class IvDripRateScreen extends StatefulWidget {
  const IvDripRateScreen({super.key});

  @override
  State<IvDripRateScreen> createState() => _IvDripRateScreenState();
}

class _IvDripRateScreenState extends State<IvDripRateScreen> {
  final _volumeController = TextEditingController();
  final _timeController = TextEditingController();
  final _dropFactorController = TextEditingController(text: '20');
  String _result = '';
  String _flowRate = '';

  void _calculate() {
    double? v = double.tryParse(_volumeController.text);
    double? t = double.tryParse(_timeController.text);
    double? df = double.tryParse(_dropFactorController.text);

    if (v != null && t != null && df != null && t != 0) {
      // Drip Rate (gtt/min) = (Volume in ml × Drop Factor in gtt/ml) / Time in min
      double rate = (v * df) / t;
      // Flow Rate (ml/hr) = (Volume in ml) / (Time in min / 60)
      double mlhr = v / (t / 60);
      
      setState(() {
        _result = rate.toStringAsFixed(1);
        _flowRate = mlhr.toStringAsFixed(1);
      });
      HapticFeedback.mediumImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('💧 IV Drip Rate')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              'Calculate intravenous fluid infusion rates and drop factors.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.subtitleColor),
            ),
            const SizedBox(height: 30),
            _buildInputCard('Infusion Details', [
              _buildTextField('Total Volume (ml)', _volumeController, Icons.water_drop),
              const SizedBox(height: 15),
              _buildTextField('Time Duration (min)', _timeController, Icons.timer),
              const SizedBox(height: 15),
              _buildTextField('Drop Factor (gtt/ml)', _dropFactorController, Icons.opacity),
            ]),
            const SizedBox(height: 20),
            Row(
              children: [
                _buildPresetChip('Macro (10)', '10'),
                _buildPresetChip('Standard (20)', '20'),
                _buildPresetChip('Micro (60)', '60'),
              ],
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _calculate,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text('Calculate Drip Rate', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            if (_result.isNotEmpty) ...[
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blue[100]!),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildResultItem('Drip Rate', _result, 'gtt/min'),
                        const VerticalDivider(),
                        _buildResultItem('Flow Rate', _flowRate, 'ml/hr'),
                      ],
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

  Widget _buildPresetChip(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ActionChip(
        label: Text(label),
        onPressed: () {
          _dropFactorController.text = value;
          _calculate();
        },
      ),
    );
  }

  Widget _buildInputCard(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 20),
          ...children,
        ],
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

  Widget _buildResultItem(String label, String value, String unit) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue)),
        Text(unit, style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
      ],
    );
  }
}
