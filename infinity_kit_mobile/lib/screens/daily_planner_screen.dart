import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DailyPlannerScreen extends StatefulWidget {
  const DailyPlannerScreen({super.key});

  @override
  State<DailyPlannerScreen> createState() => _DailyPlannerScreenState();
}

class _DailyPlannerScreenState extends State<DailyPlannerScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _user = FirebaseAuth.instance.currentUser;

  CollectionReference get _plannerRef => _firestore
      .collection('users')
      .doc(_user?.uid)
      .collection('planner');

  void _addTask() {
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
                await _plannerRef.add({
                  'task': controller.text.trim(),
                  'completed': false,
                  'createdAt': FieldValue.serverTimestamp(),
                });
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daily Planner')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _plannerRef.orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              return CheckboxListTile(
                title: Text(data['task'], style: TextStyle(decoration: data['completed'] ? TextDecoration.lineThrough : null)),
                value: data['completed'],
                onChanged: (val) => _plannerRef.doc(doc.id).update({'completed': val}),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(onPressed: _addTask, child: const Icon(Icons.add_task)),
    );
  }
}
