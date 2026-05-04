import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TextToSpeechScreen extends StatefulWidget {
  const TextToSpeechScreen({super.key});

  @override
  State<TextToSpeechScreen> createState() => _TextToSpeechScreenState();
}

class _TextToSpeechScreenState extends State<TextToSpeechScreen> {
  final FlutterTts _tts = FlutterTts();
  final _controller = TextEditingController();

  void _speak() async {
    if (_controller.text.isNotEmpty) {
      await _tts.speak(_controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Text to Speech')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              maxLines: 5,
              decoration: const InputDecoration(hintText: 'Enter text here...', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _speak,
              icon: const Icon(Icons.volume_up),
              label: const Text('Speak Now'),
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 55)),
            ),
          ],
        ),
      ),
    );
  }
}
