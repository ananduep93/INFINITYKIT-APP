import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../utils/theme.dart';
import 'package:intl/intl.dart';

class PasswordSaverScreen extends StatefulWidget {
  const PasswordSaverScreen({super.key});

  @override
  State<PasswordSaverScreen> createState() => _PasswordSaverScreenState();
}

class _PasswordSaverScreenState extends State<PasswordSaverScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final User? _user = FirebaseAuth.instance.currentUser;

  Future<void> _addOrEditPassword([int? index, Map<String, dynamic>? initialData]) async {
    final titleController = TextEditingController(text: initialData?['appName']);
    final passwordController = TextEditingController(text: initialData?['password']);
    bool obscurePassword = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20, left: 20, right: 20,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Save Password', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildField('Title (e.g. Gmail)', titleController),
              _buildField('Password', passwordController, isPassword: true, obscure: obscurePassword, onToggle: () {
                setModalState(() => obscurePassword = !obscurePassword);
              }),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final title = titleController.text.trim();
                  final password = passwordController.text.trim();
                  if (title.isEmpty || password.isEmpty) return;

                  final currentData = await _firestoreService.getToolData('savedPasswords');
                  List<dynamic> passwords = (currentData is List) ? List.from(currentData) : [];

                  final newData = {
                    'appName': title,
                    'password': password,
                    'date': DateFormat('dd/MM/yyyy, HH:mm:ss').format(DateTime.now()),
                  };

                  if (index == null) {
                    passwords.add(newData);
                  } else {
                    passwords[index] = newData;
                  }

                  await _firestoreService.saveToolData('savedPasswords', passwords);
                  if (context.mounted) Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
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

  Future<void> _deletePassword(int index) async {
    final currentData = await _firestoreService.getToolData('savedPasswords');
    if (currentData is List) {
      List<dynamic> passwords = List.from(currentData);
      passwords.removeAt(index);
      await _firestoreService.saveToolData('savedPasswords', passwords);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) return const Scaffold(body: Center(child: Text('Please log in')));

    return Scaffold(
      appBar: AppBar(title: const Text('🔒 Password Saver')),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestoreService.getToolDataStream('savedPasswords'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          
          final data = snapshot.data?.data() as Map<String, dynamic>?;
          final List<dynamic> passwords = (data != null && data['data'] is List) ? data['data'] : [];

          if (passwords.isEmpty) return const Center(child: Text('No passwords saved yet.'));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: passwords.length,
            itemBuilder: (context, index) {
              final pwd = passwords[index] as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const Icon(Icons.security, color: AppTheme.primaryColor),
                  title: Text(pwd['appName'] ?? 'Untitled', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(pwd['date'] ?? ''),
                  trailing: const Icon(Icons.edit, size: 18),
                  onTap: () => _addOrEditPassword(index, pwd),
                  onLongPress: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Credentials?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                          TextButton(
                            onPressed: () async {
                              await _deletePassword(index);
                              if (context.mounted) Navigator.pop(context);
                            },
                            child: const Text('Delete', style: TextStyle(color: Colors.red)),
                          ),
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
