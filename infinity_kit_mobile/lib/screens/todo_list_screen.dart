import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../utils/theme.dart';

class ToDoListScreen extends StatefulWidget {
  const ToDoListScreen({super.key});

  @override
  State<ToDoListScreen> createState() => _ToDoListScreenState();
}

class _ToDoListScreenState extends State<ToDoListScreen> {
  final TextEditingController _controller = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  final User? _user = FirebaseAuth.instance.currentUser;

  Future<void> _addTodo() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    
    final currentData = await _firestoreService.getToolData('todos');
    List<dynamic> todos = (currentData is List) ? List.from(currentData) : [];
    
    todos.add({
      'text': text,
      'completed': false,
    });
    
    await _firestoreService.saveToolData('todos', todos);
    _controller.clear();
  }

  Future<void> _toggleTodo(int index) async {
    final currentData = await _firestoreService.getToolData('todos');
    if (currentData is List) {
      List<dynamic> todos = List.from(currentData);
      final item = Map<String, dynamic>.from(todos[index]);
      item['completed'] = !(item['completed'] ?? false);
      todos[index] = item;
      await _firestoreService.saveToolData('todos', todos);
    }
  }

  Future<void> _deleteTodo(int index) async {
    final currentData = await _firestoreService.getToolData('todos');
    if (currentData is List) {
      List<dynamic> todos = List.from(currentData);
      todos.removeAt(index);
      await _firestoreService.saveToolData('todos', todos);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) return const Scaffold(body: Center(child: Text('Please log in')));

    return Scaffold(
      appBar: AppBar(
        title: const Text('✓ To-Do List'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Add a new task...',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => _addTodo(),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _addTodo,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: _firestoreService.getToolDataStream('todos'),
              builder: (context, snapshot) {
                if (snapshot.hasError) return const Center(child: Text('Something went wrong'));
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final data = snapshot.data?.data() as Map<String, dynamic>?;
                final List<dynamic> todos = (data != null && data['data'] is List) ? data['data'] : [];

                if (todos.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.list_alt, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        const Text('No tasks yet. Add one to get started!'),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: todos.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    // Show newest first if you prefer, or follow original order.
                    // Web usually appends to the end, so index is index.
                    final todo = todos[index] as Map<String, dynamic>;
                    final text = todo['text'] ?? '';
                    final completed = todo['completed'] ?? false;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: Checkbox(
                          value: completed,
                          onChanged: (_) => _toggleTodo(index),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                        title: Text(
                          text,
                          style: TextStyle(
                            decoration: completed ? TextDecoration.lineThrough : null,
                            color: completed ? Colors.grey : AppTheme.textColor,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          onPressed: () => _deleteTodo(index),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
