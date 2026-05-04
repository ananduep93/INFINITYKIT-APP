import 'package:flutter/material.dart';

class PasswordStrengthScreen extends StatefulWidget {
  const PasswordStrengthScreen({super.key});

  @override
  State<PasswordStrengthScreen> createState() => _PasswordStrengthScreenState();
}

class _PasswordStrengthScreenState extends State<PasswordStrengthScreen> {
  final _controller = TextEditingController();
  double _strength = 0;
  String _label = 'Enter Password';
  Color _color = Colors.grey;

  void _check(String value) {
    double strength = 0;
    if (value.length >= 8) strength += 0.25;
    if (RegExp(r'[A-Z]').hasMatch(value)) strength += 0.25;
    if (RegExp(r'[0-9]').hasMatch(value)) strength += 0.25;
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(value)) strength += 0.25;

    setState(() {
      _strength = strength;
      if (strength <= 0.25) { _label = 'Very Weak'; _color = Colors.red; }
      else if (strength <= 0.5) { _label = 'Weak'; _color = Colors.orange; }
      else if (strength <= 0.75) { _label = 'Good'; _color = Colors.blue; }
      else { _label = 'Strong'; _color = Colors.green; }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Password Strength')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              onChanged: _check,
              decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 30),
            LinearProgressIndicator(value: _strength, color: _color, minHeight: 10, backgroundColor: Colors.grey[200]),
            const SizedBox(height: 10),
            Text(_label, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _color)),
          ],
        ),
      ),
    );
  }
}
