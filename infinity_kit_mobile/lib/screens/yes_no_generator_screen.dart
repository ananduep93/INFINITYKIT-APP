import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/theme.dart';

class YesNoGeneratorScreen extends StatefulWidget {
  const YesNoGeneratorScreen({super.key});

  @override
  State<YesNoGeneratorScreen> createState() => _YesNoGeneratorScreenState();
}

class _YesNoGeneratorScreenState extends State<YesNoGeneratorScreen> with SingleTickerProviderStateMixin {
  final _questionController = TextEditingController();
  String _answer = '';
  Color _answerColor = AppTheme.primaryColor;
  bool _isThinking = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  final List<Map<String, dynamic>> _responses = [
    {'text': 'Yes ✓', 'color': Colors.green},
    {'text': 'No ✗', 'color': Colors.red},
    {'text': 'Maybe 🤷', 'color': Colors.orange},
    {'text': 'Absolutely!', 'color': Colors.green},
    {'text': 'Definitely not', 'color': Colors.red},
    {'text': 'Ask again later', 'color': Colors.blue},
    {'text': 'Signs point to yes', 'color': Colors.teal},
    {'text': 'Don\'t count on it', 'color': Colors.deepOrange},
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _questionController.dispose();
    super.dispose();
  }

  void _generate() async {
    setState(() {
      _isThinking = true;
      _answer = '';
    });

    HapticFeedback.mediumImpact();
    
    // Simulate thinking
    await Future.delayed(const Duration(seconds: 1));

    final response = _responses[Random().nextInt(_responses.length)];
    
    if (mounted) {
      setState(() {
        _isThinking = false;
        _answer = response['text'];
        _answerColor = response['color'];
      });
      _controller.reset();
      _controller.forward();
      HapticFeedback.heavyImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🎯 Yes / No Generator')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              'Ask a question and get a quick answer!',
              style: TextStyle(color: AppTheme.subtitleColor),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _questionController,
              decoration: InputDecoration(
                labelText: 'Your Question',
                hintText: 'e.g. Should I go for a walk?',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isThinking ? null : _generate,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: _isThinking
                  ? const CircularProgressIndicator()
                  : const Text('Get Answer', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            const Spacer(),
            if (_isThinking)
              const Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text('Consulting the magic ball...', style: TextStyle(fontStyle: FontStyle.italic)),
                ],
              ),
            if (_answer.isNotEmpty)
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: _answerColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: _answerColor.withValues(alpha: 0.3), width: 2),
                  ),
                  child: Text(
                    _answer,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: _answerColor,
                    ),
                  ),
                ),
              ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
