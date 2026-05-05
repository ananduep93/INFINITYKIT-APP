import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/theme.dart';

class TextReverserScreen extends StatefulWidget {
  const TextReverserScreen({super.key});

  @override
  State<TextReverserScreen> createState() => _TextReverserScreenState();
}

class _TextReverserScreenState extends State<TextReverserScreen> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();

  void _reverseText() {
    setState(() {
      _outputController.text = _inputController.text.split('').reversed.join('');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🔄 Text Reverser')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              TextField(
                controller: _inputController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Input Text',
                  hintText: 'Enter text to reverse',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => _reverseText(),
              ),
              const SizedBox(height: 20),
              const Icon(Icons.swap_vert, color: AppTheme.primaryColor, size: 32),
              const SizedBox(height: 20),
              TextField(
                controller: _outputController,
                maxLines: 5,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Reversed Text',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: _outputController.text));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Copied to clipboard!')),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _inputController.clear();
                  _outputController.clear();
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.grey[100],
                  foregroundColor: Colors.black87,
                  elevation: 0,
                ),
                child: const Text('Clear'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
