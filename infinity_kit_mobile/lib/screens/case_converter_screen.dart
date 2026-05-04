import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/theme.dart';

class CaseConverterScreen extends StatefulWidget {
  const CaseConverterScreen({super.key});

  @override
  State<CaseConverterScreen> createState() => _CaseConverterScreenState();
}

class _CaseConverterScreenState extends State<CaseConverterScreen> {
  final TextEditingController _controller = TextEditingController();

  void _convert(String type) {
    String text = _controller.text;
    if (text.isEmpty) return;

    setState(() {
      switch (type) {
        case 'upper':
          _controller.text = text.toUpperCase();
          break;
        case 'lower':
          _controller.text = text.toLowerCase();
          break;
        case 'sentence':
          if (text.isNotEmpty) {
            _controller.text = text[0].toUpperCase() + text.substring(1).toLowerCase();
          }
          break;
        case 'title':
          _controller.text = text.split(' ').map((word) {
            if (word.isEmpty) return word;
            return word[0].toUpperCase() + word.substring(1).toLowerCase();
          }).join(' ');
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Aa Case Converter')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  hintText: 'Enter your text here...',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: _controller.text));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Copied!')),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                _buildButton('UPPERCASE', 'upper'),
                _buildButton('lowercase', 'lower'),
                _buildButton('Sentence case', 'sentence'),
                _buildButton('Title Case', 'title'),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _controller.clear(),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.red[50],
                foregroundColor: Colors.red,
                elevation: 0,
              ),
              child: const Text('Clear Text'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String label, String type) {
    return ElevatedButton(
      onPressed: () => _convert(type),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
        foregroundColor: AppTheme.primaryColor,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(label),
    );
  }
}
