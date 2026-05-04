import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/theme.dart';

class PasswordSaverScreen extends StatefulWidget {
  const PasswordSaverScreen({super.key});

  @override
  State<PasswordSaverScreen> createState() => _PasswordSaverScreenState();
}

class _PasswordSaverScreenState extends State<PasswordSaverScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _user = FirebaseAuth.instance.currentUser;

  CollectionReference get _passwordsRef => _firestore
      .collection('users')
      .doc(_user?.uid)
      .collection('passwords');

  void _addOrEditPassword([String? id, Map<String, dynamic>? initialData]) {
    final titleController = TextEditingController(text: initialData?['title']);
    final usernameController = TextEditingController(text: initialData?['username']);
    final passwordController = TextEditingController(text: initialData?['password']);
    bool obscurePassword = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20, left: 20, right: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Save Password', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildField('Title (e.g. Facebook)', titleController),
              _buildField('Username/Email', usernameController),
              _buildField('Password', passwordController, isPassword: true, obscure: obscurePassword, onToggle: () {
                setModalState(() => obscurePassword = !obscurePassword);
              }),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final data = {
                    'title': titleController.text.trim(),
                    'username': usernameController.text.trim(),
                    'password': passwordController.text.trim(),
                    'updatedAt': FieldValue.serverTimestamp(),
                  };
                  if (id == null) {
                    await _passwordsRef.add(data);
                  } else {
                    await _passwordsRef.doc(id).update(data);
                  }
                  if (context.mounted) Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                child: const Text('Save Credentials'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String hint, TextEditingController controller, {bool isPassword = false, bool obscure = false, VoidCallback? onToggle}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          suffixIcon: isPassword ? IconButton(icon: Icon(obscure ? Icons.visibility : Icons.visibility_off), onPressed: onToggle) : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🔒 Password Saver')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _passwordsRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('No passwords saved yet.'));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.security, color: AppTheme.primaryColor),
                  title: Text(data['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(data['username']),
                  trailing: const Icon(Icons.edit, size: 18),
                  onTap: () => _addOrEditPassword(doc.id, data),
                  onLongPress: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Credentials?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                          TextButton(onPressed: () { _passwordsRef.doc(doc.id).delete(); Navigator.pop(context); }, child: const Text('Delete', style: TextStyle(color: Colors.red))),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(onPressed: () => _addOrEditPassword(), child: const Icon(Icons.add)),
    );
  }
}
