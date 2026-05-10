import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';

class ReminderAlertScreen extends StatefulWidget {
  const ReminderAlertScreen({super.key});

  @override
  State<ReminderAlertScreen> createState() => _ReminderAlertScreenState();
}

class _ReminderAlertScreenState extends State<ReminderAlertScreen> {
  final _firestoreService = FirestoreService();
  final _user = FirebaseAuth.instance.currentUser;

  Future<void> _addReminder() async {
    final titleController = TextEditingController();
    TimeOfDay selectedTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: const Text('Add Reminder'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleController, decoration: const InputDecoration(hintText: 'Reminder Title')),
              const SizedBox(height: 10),
              ListTile(
                title: Text('Time: ${selectedTime.format(context)}'),
                trailing: const Icon(Icons.access_time),
                onTap: () async {
                  final time = await showTimePicker(context: context, initialTime: selectedTime);
                  if (time != null) setModalState(() => selectedTime = time);
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            TextButton(
              onPressed: () async {
                if (titleController.text.isNotEmpty) {
                  final currentData = await _firestoreService.getToolData('reminderAlerts');
                  List<dynamic> alerts = (currentData is List) ? List.from(currentData) : [];

                  alerts.add({
                    'title': titleController.text.trim(),
                    'time': '${selectedTime.hour}:${selectedTime.minute}',
                    'createdAt': DateTime.now().toIso8601String(),
                  });

                  await _firestoreService.saveToolData('reminderAlerts', alerts);
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteReminder(int index, List<dynamic> currentAlerts) async {
    List<dynamic> alerts = List.from(currentAlerts);
    alerts.removeAt(index);
    await _firestoreService.saveToolData('reminderAlerts', alerts);
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) return const Scaffold(body: Center(child: Text('Please log in')));

    return Scaffold(
      appBar: AppBar(title: const Text('Reminder Alert')),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestoreService.getToolDataStream('reminderAlerts'),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          final docData = snapshot.data?.data() as Map<String, dynamic>?;
          final List<dynamic> alerts = (docData != null && docData['data'] is List) ? docData['data'] : [];

          if (alerts.isEmpty) {
            return const Center(child: Text('No alerts set.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              final alert = alerts[index] as Map<String, dynamic>;
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.notifications_active, color: Colors.orange),
                  title: Text(alert['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Time: ${alert['time']}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.grey), 
                    onPressed: () => _deleteReminder(index, alerts)
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(onPressed: _addReminder, child: const Icon(Icons.add_alert)),
    );
  }
}
