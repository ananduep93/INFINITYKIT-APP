import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';

class MedicineReminderScreen extends StatefulWidget {
  const MedicineReminderScreen({super.key});

  @override
  State<MedicineReminderScreen> createState() => _MedicineReminderScreenState();
}

class _MedicineReminderScreenState extends State<MedicineReminderScreen> {
  final _firestoreService = FirestoreService();
  final _user = FirebaseAuth.instance.currentUser;

  Future<void> _addReminder() async {
    final nameController = TextEditingController();
    TimeOfDay selectedTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: const Text('Add Medicine'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(hintText: 'Medicine Name')),
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
                if (nameController.text.isNotEmpty) {
                  final currentData = await _firestoreService.getToolData('medicineReminders');
                  List<dynamic> reminders = (currentData is List) ? List.from(currentData) : [];

                  reminders.add({
                    'name': nameController.text.trim(),
                    'time': '${selectedTime.hour}:${selectedTime.minute}',
                    'createdAt': DateTime.now().toIso8601String(),
                  });

                  await _firestoreService.saveToolData('medicineReminders', reminders);
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

  Future<void> _deleteReminder(int index, List<dynamic> currentReminders) async {
    List<dynamic> reminders = List.from(currentReminders);
    reminders.removeAt(index);
    await _firestoreService.saveToolData('medicineReminders', reminders);
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) return const Scaffold(body: Center(child: Text('Please log in')));

    return Scaffold(
      appBar: AppBar(title: const Text('Medicine Reminder')),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestoreService.getToolDataStream('medicineReminders'),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          final docData = snapshot.data?.data() as Map<String, dynamic>?;
          final List<dynamic> reminders = (docData != null && docData['data'] is List) ? docData['data'] : [];

          if (reminders.isEmpty) {
            return const Center(child: Text('No reminders set.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reminders.length,
            itemBuilder: (context, index) {
              final reminder = reminders[index] as Map<String, dynamic>;
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.medication, color: Colors.red),
                  title: Text(reminder['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Reminder at ${reminder['time']}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.grey), 
                    onPressed: () => _deleteReminder(index, reminders)
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(onPressed: _addReminder, child: const Icon(Icons.add_alarm)),
    );
  }
}
