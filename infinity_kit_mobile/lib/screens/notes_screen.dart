import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../services/firestore_service.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final User? _user = FirebaseAuth.instance.currentUser;

  Future<void> _addOrEditNote([int? index, Map<String, dynamic>? initialNote]) async {
    final TextEditingController controller = TextEditingController(text: initialNote?['content'] ?? '');
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 20,
          left: 20,
          right: 20,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(index == null ? 'New Note' : 'Edit Note', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 5,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Start typing...',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final text = controller.text.trim();
                if (text.isEmpty) return;

                // Fetch current list
                final currentData = await _firestoreService.getToolData('quickNotes');
                List<dynamic> notes = (currentData is List) ? List.from(currentData) : [];

                final newNote = {
                  'title': text.length > 50 ? text.substring(0, 50) : text,
                  'content': text,
                  'date': DateFormat('dd/MM/yyyy, HH:mm:ss').format(DateTime.now()), // Matches web's toLocaleString roughly
                };

                if (index == null) {
                  notes.add(newNote);
                } else {
                  notes[index] = newNote;
                }

                await _firestoreService.saveToolData('quickNotes', notes);
                
                if (context.mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Save Note'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteNote(int index) async {
    final currentData = await _firestoreService.getToolData('quickNotes');
    if (currentData is List) {
      List<dynamic> notes = List.from(currentData);
      notes.removeAt(index);
      await _firestoreService.saveToolData('quickNotes', notes);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) return const Scaffold(body: Center(child: Text('Please log in')));

    return Scaffold(
      appBar: AppBar(
        title: const Text('📝 Quick Notes'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestoreService.getToolDataStream('quickNotes'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          
          final data = snapshot.data?.data() as Map<String, dynamic>?;
          final List<dynamic> notes = (data != null && data['data'] is List) ? data['data'] : [];

          if (notes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.note_add_outlined, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text('No notes yet. Create one!'),
                ],
              ),
            );
          }

          // Reverse for display to show newest first
          final reversedNotes = notes.reversed.toList();

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1,
            ),
            itemCount: reversedNotes.length,
            itemBuilder: (context, index) {
              final note = reversedNotes[index] as Map<String, dynamic>;
              // Original index in the list
              final originalIndex = notes.length - 1 - index;
              return _buildNoteCard(originalIndex, note);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditNote(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildNoteCard(int originalIndex, Map<String, dynamic> note) {
    return InkWell(
      onTap: () => _addOrEditNote(originalIndex, note),
      onLongPress: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Note?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              TextButton(
                onPressed: () async {
                  await _deleteNote(originalIndex);
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.yellow[100],
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              note['content'] ?? '',
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const Spacer(),
            Text(
              note['date'] ?? '',
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
