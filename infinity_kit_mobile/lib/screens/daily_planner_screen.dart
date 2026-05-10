import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';

class DailyPlannerScreen extends StatefulWidget {
  const DailyPlannerScreen({super.key});

  @override
  State<DailyPlannerScreen> createState() => _DailyPlannerScreenState();
}

class _DailyPlannerScreenState extends State<DailyPlannerScreen> {
  final _firestoreService = FirestoreService();
  final _user = FirebaseAuth.instance.currentUser;

  Future<void> _addTask() async {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Task'),
        content: TextField(controller: controller, decoration: const InputDecoration(hintText: 'Task name')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                final currentData = await _firestoreService.getToolData('dailyPlanner');
                List<dynamic> tasks = (currentData is List) ? List.from(currentData) : [];
                
                tasks.add({
                  'task': controller.text.trim(),
                  'completed': false,
                  'createdAt': DateTime.now().toIso8601String(),
                });
                
                await _firestoreService.saveToolData('dailyPlanner', tasks);
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleTask(int index, List<dynamic> currentTasks) async {
    List<dynamic> tasks = List.from(currentTasks);
    final item = Map<String, dynamic>.from(tasks[index]);
    item['completed'] = !(item['completed'] ?? false);
    tasks[index] = item;
    await _firestoreService.saveToolData('dailyPlanner', tasks);
  }

  Future<void> _deleteTask(int index, List<dynamic> currentTasks) async {
    List<dynamic> tasks = List.from(currentTasks);
    tasks.removeAt(index);
    await _firestoreService.saveToolData('dailyPlanner', tasks);
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) return const Scaffold(body: Center(child: Text('Please log in')));

    return Scaffold(
      appBar: AppBar(title: const Text('Daily Planner')),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestoreService.getToolDataStream('dailyPlanner'),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          final docData = snapshot.data?.data() as Map<String, dynamic>?;
          final List<dynamic> tasks = (docData != null && docData['data'] is List) ? docData['data'] : [];

          if (tasks.isEmpty) {
            return const Center(child: Text('No tasks planned for today.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index] as Map<String, dynamic>;
              return CheckboxListTile(
                title: Text(task['task'] ?? '', style: TextStyle(decoration: (task['completed'] ?? false) ? TextDecoration.lineThrough : null)),
                value: task['completed'] ?? false,
                onChanged: (_) => _toggleTask(index, tasks),
                secondary: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: () => _deleteTask(index, tasks),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(onPressed: _addTask, child: const Icon(Icons.add_task)),
    );
  }
}
