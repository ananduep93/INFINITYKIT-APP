import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
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

  SubjectMark({String? name, String? obtained, String? total}) {
    nameController.text = name ?? '';
    obtainedController.text = obtained ?? '';
    totalController.text = total ?? '100';
  }

  Map<String, String> toJson() => {
    'name': nameController.text,
    'obtained': obtainedController.text,
    'total': totalController.text,
  };
}

class _ExamMarksCalculatorScreenState extends State<ExamMarksCalculatorScreen> {
  final List<SubjectMark> _subjects = [SubjectMark()];
  final FirestoreService _firestoreService = FirestoreService();
  final User? _user = FirebaseAuth.instance.currentUser;
  
  double _totalObtained = 0;
  double _totalPossible = 0;
  double _percentage = 0;
  String _grade = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await _firestoreService.getToolData('examMarks');
    if (data is List && data.isNotEmpty) {
      setState(() {
        _subjects.clear();
        for (var item in data) {
          final m = item as Map<String, dynamic>;
          _subjects.add(SubjectMark(
            name: m['name'],
            obtained: m['obtained'],
            total: m['total'],
          ));
        }
        _calculate();
      });
    }
  }

  Future<void> _saveData() async {
    if (_user == null) return;
    final data = _subjects.map((s) => s.toJson()).toList();
    await _firestoreService.saveToolData('examMarks', data);
  }

  void _addSubject() {
    setState(() => _subjects.add(SubjectMark()));
    _saveData();
  }

  void _removeSubject(int index) {
    if (_subjects.length > 1) {
      setState(() => _subjects.removeAt(index));
      _calculate();
      _saveData();
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
                    onPressed: () {
                      _calculate();
                      _saveData();
                    },
                    style: ElevatedButton.styleFrom(minimumSize: const Size(0, 50)),
                    child: const Text('Calculate & Save'),
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
                    onChanged: (_) => _saveData(),
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
                    onChanged: (_) {
                      _calculate();
                      _saveData();
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: s.totalController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Out Of', isDense: true, border: OutlineInputBorder()),
                    onChanged: (_) {
                      _calculate();
                      _saveData();
                    },
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
