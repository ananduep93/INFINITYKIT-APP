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
  double _speed = 0.5;
  double _pitch = 1.0;

  void _speak() async {
    if (_controller.text.isNotEmpty) {
      await _tts.setSpeechRate(_speed);
      await _tts.setPitch(_pitch);
      await _tts.speak(_controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Text to Speech')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _controller,
              maxLines: 5,
              decoration: const InputDecoration(hintText: 'Enter text here...', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 25),
            Text('Speed: ${_speed.toStringAsFixed(1)}', style: const TextStyle(fontWeight: FontWeight.bold)),
            Slider(
              value: _speed,
              min: 0.1,
              max: 1.0,
              onChanged: (val) => setState(() => _speed = val),
            ),
            const SizedBox(height: 10),
            Text('Pitch: ${_pitch.toStringAsFixed(1)}', style: const TextStyle(fontWeight: FontWeight.bold)),
            Slider(
              value: _pitch,
              min: 0.5,
              max: 2.0,
              onChanged: (val) => setState(() => _pitch = val),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _speak,
              icon: const Icon(Icons.volume_up),
              label: const Text('Speak Now'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
