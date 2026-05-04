import 'package:flutter/material.dart';

class DaysBetweenDatesScreen extends StatefulWidget {
  const DaysBetweenDatesScreen({super.key});

  @override
  State<DaysBetweenDatesScreen> createState() => _DaysBetweenDatesScreenState();
}

class _DaysBetweenDatesScreenState extends State<DaysBetweenDatesScreen> {
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    int diff = _endDate.difference(_startDate).inDays.abs();

    return Scaffold(
      appBar: AppBar(title: const Text('Days Between Dates')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildDateRow('Start Date', _startDate, () => _selectDate(context, true)),
            const SizedBox(height: 16),
            _buildDateRow('End Date', _endDate, () => _selectDate(context, false)),
            const SizedBox(height: 60),
            const Text('Difference', style: TextStyle(fontSize: 18, color: Colors.grey)),
            Text('$diff Days', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.blue)),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRow(String label, DateTime date, VoidCallback onTap) {
    return ListTile(
      title: Text(label),
      subtitle: Text("${date.day}/${date.month}/${date.year}"),
      trailing: const Icon(Icons.calendar_today),
      onTap: onTap,
      tileColor: Colors.grey[100],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
