import 'package:flutter/material.dart';
import '../utils/theme.dart';

class ExamMarksCalculatorScreen extends StatefulWidget {
  const ExamMarksCalculatorScreen({super.key});

  @override
  State<ExamMarksCalculatorScreen> createState() => _ExamMarksCalculatorScreenState();
}

class SubjectMark {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController obtainedController = TextEditingController();
  final TextEditingController totalController = TextEditingController();

  SubjectMark() {
    totalController.text = '100';
  }
}

class _ExamMarksCalculatorScreenState extends State<ExamMarksCalculatorScreen> {
  final List<SubjectMark> _subjects = [SubjectMark()];
  double _totalObtained = 0;
  double _totalPossible = 0;
  double _percentage = 0;
  String _grade = '';

  void _addSubject() {
    setState(() => _subjects.add(SubjectMark()));
  }

  void _removeSubject(int index) {
    if (_subjects.length > 1) {
      setState(() => _subjects.removeAt(index));
      _calculate();
    }
  }

  void _calculate() {
    double totalObtained = 0;
    double totalPossible = 0;

    for (var s in _subjects) {
      double obtained = double.tryParse(s.obtainedController.text) ?? 0;
      double possible = double.tryParse(s.totalController.text) ?? 100;
      totalObtained += obtained;
      totalPossible += possible;
    }

    setState(() {
      _totalObtained = totalObtained;
      _totalPossible = totalPossible;
      _percentage = totalPossible > 0 ? (totalObtained / totalPossible) * 100 : 0;
      
      if (_percentage >= 90) {
        _grade = 'A+';
      } else if (_percentage >= 80) {
        _grade = 'A';
      } else if (_percentage >= 70) {
        _grade = 'B';
      } else if (_percentage >= 60) {
        _grade = 'C';
      } else if (_percentage >= 50) {
        _grade = 'D';
      } else {
        _grade = 'F';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📝 Exam Marks Calculator')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _subjects.length,
                itemBuilder: (context, index) => _buildSubjectRow(index),
              ),
            ),
            const SizedBox(height: 20),
            if (_totalPossible > 0)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildResultItem('Total', '${_totalObtained.toStringAsFixed(0)}/${_totalPossible.toStringAsFixed(0)}'),
                    _buildResultItem('Percent', '${_percentage.toStringAsFixed(1)}%'),
                    _buildResultItem('Grade', _grade, color: _grade == 'F' ? Colors.red : Colors.green),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _addSubject,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Subject'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[50], foregroundColor: Colors.blue, elevation: 0),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _calculate,
                    style: ElevatedButton.styleFrom(minimumSize: const Size(0, 50)),
                    child: const Text('Calculate'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectRow(int index) {
    final s = _subjects[index];
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: s.nameController,
                    decoration: InputDecoration(hintText: 'Subject ${index + 1}', isDense: true),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.redAccent, size: 20),
                  onPressed: () => _removeSubject(index),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: s.obtainedController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Obtained', isDense: true, border: OutlineInputBorder()),
                    onChanged: (_) => _calculate(),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: s.totalController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Out Of', isDense: true, border: OutlineInputBorder()),
                    onChanged: (_) => _calculate(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultItem(String label, String value, {Color? color}) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.subtitleColor)),
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color ?? AppTheme.primaryColor)),
      ],
    );
  }
}
