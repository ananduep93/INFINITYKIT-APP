import 'package:flutter/material.dart';

class UrlEncoderDecoderScreen extends StatefulWidget {
  const UrlEncoderDecoderScreen({super.key});

  @override
  State<UrlEncoderDecoderScreen> createState() => _UrlEncoderDecoderScreenState();
}

class _UrlEncoderDecoderScreenState extends State<UrlEncoderDecoderScreen> {
  final _inputController = TextEditingController();
  String _output = '';

  void _encode() {
    setState(() => _output = Uri.encodeComponent(_inputController.text));
  }

  void _decode() {
    setState(() => _output = Uri.decodeComponent(_inputController.text));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('URL Encoder / Decoder')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _inputController,
              maxLines: 5,
              decoration: const InputDecoration(labelText: 'Enter URL or Text', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: ElevatedButton(onPressed: _encode, child: const Text('Encode'))),
                const SizedBox(width: 10),
                Expanded(child: ElevatedButton(onPressed: _decode, child: const Text('Decode'))),
              ],
            ),
            const SizedBox(height: 40),
            const Text('Result:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
              child: SelectableText(_output),
            ),
          ],
        ),
      ),
    );
  }
}
