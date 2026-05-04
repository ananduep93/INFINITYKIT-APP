import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/theme.dart';

class ChoiceComparatorScreen extends StatefulWidget {
  const ChoiceComparatorScreen({super.key});

  @override
  State<ChoiceComparatorScreen> createState() => _ChoiceComparatorScreenState();
}

class _ChoiceComparatorScreenState extends State<ChoiceComparatorScreen> {
  final _choiceAProsController = TextEditingController();
  final _choiceAConsController = TextEditingController();
  final _choiceBProsController = TextEditingController();
  final _choiceBConsController = TextEditingController();

  double _scoreA = 0;
  double _scoreB = 0;
  String _recommendation = '';
  bool _calculated = false;

  void _compare() {
    int aPros = _choiceAProsController.text.split('\n').where((l) => l.trim().isNotEmpty).length;
    int aCons = _choiceAConsController.text.split('\n').where((l) => l.trim().isNotEmpty).length;
    int bPros = _choiceBProsController.text.split('\n').where((l) => l.trim().isNotEmpty).length;
    int bCons = _choiceBConsController.text.split('\n').where((l) => l.trim().isNotEmpty).length;

    // Logic from website: Pros are positive, Cons are -0.7 weight
    setState(() {
      _scoreA = aPros - (aCons * 0.7);
      _scoreB = bPros - (bCons * 0.7);
      _calculated = true;

      if (_scoreA > _scoreB) {
        _recommendation = '✓ Choice A looks better!';
      } else if (_scoreB > _scoreA) {
        _recommendation = '✓ Choice B looks better!';
      } else {
        _recommendation = '⚖️ Both are equally good!';
      }
    });
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('⚖️ Choice Comparator')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildChoiceSection('Choice A', _choiceAProsController, _choiceAConsController),
            const SizedBox(height: 20),
            _buildChoiceSection('Choice B', _choiceBProsController, _choiceBConsController),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _compare,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text('Compare Now', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            if (_calculated) ...[
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildScore('Choice A', _scoreA, Colors.blue),
                        const VerticalDivider(),
                        _buildScore('Choice B', _scoreB, Colors.purple),
                      ],
                    ),
                    const Divider(height: 40),
                    Text(
                      'Recommendation',
                      style: TextStyle(color: AppTheme.subtitleColor, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _recommendation,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceSection(String title, TextEditingController pros, TextEditingController cons) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: pros,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Pros (one per line)',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  fillColor: Colors.green.withValues(alpha: 0.02),
                  filled: true,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: cons,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Cons (one per line)',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  fillColor: Colors.red.withValues(alpha: 0.02),
                  filled: true,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildScore(String label, double score, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Text(
          score.toStringAsFixed(1),
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}
