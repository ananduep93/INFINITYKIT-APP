import 'package:flutter/material.dart';
import '../utils/theme.dart';

class DiscountCalculatorScreen extends StatefulWidget {
  const DiscountCalculatorScreen({super.key});

  @override
  State<DiscountCalculatorScreen> createState() => _DiscountCalculatorScreenState();
}

class _DiscountCalculatorScreenState extends State<DiscountCalculatorScreen> {
  final _priceController = TextEditingController();
  final _discountController = TextEditingController();
  double _savings = 0;
  double _finalPrice = 0;

  void _calculate() {
    final double price = double.tryParse(_priceController.text) ?? 0;
    final double discount = double.tryParse(_discountController.text) ?? 0;

    if (price > 0 && discount >= 0) {
      setState(() {
        _savings = (price * discount) / 100;
        _finalPrice = price - _savings;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🏷️ Discount Calculator')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildInput('Original Price', _priceController, Icons.attach_money),
            const SizedBox(height: 16),
            _buildInput('Discount (%)', _discountController, Icons.percent),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _calculate,
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 55)),
              child: const Text('Calculate Savings'),
            ),
            const SizedBox(height: 40),
            if (_finalPrice > 0) ...[
              _buildResultCard('You Save', '\$ \${_savings.toStringAsFixed(2)}', Colors.green),
              const SizedBox(height: 16),
              _buildResultCard('Final Price', '\$ \${_finalPrice.toStringAsFixed(2)}', AppTheme.primaryColor),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController controller, IconData icon) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      ),
      onChanged: (_) => _calculate(),
    );
  }

  Widget _buildResultCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
