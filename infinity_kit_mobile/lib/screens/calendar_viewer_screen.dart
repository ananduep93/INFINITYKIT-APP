import 'package:flutter/material.dart';

class CalendarViewerScreen extends StatelessWidget {
  const CalendarViewerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calendar Viewer')),
      body: CalendarDatePicker(
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
        onDateChanged: (date) {
          // You could link this to the Daily Planner later
        },
      ),
    );
  }
}
