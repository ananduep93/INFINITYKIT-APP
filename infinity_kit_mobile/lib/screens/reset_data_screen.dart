import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ResetDataScreen extends StatelessWidget {
  const ResetDataScreen({super.key});

  Future<void> _resetExpenses(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    final batch = FirebaseFirestore.instance.batch();
    final docs = await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection('expenses')
        .get();

    for (var doc in docs.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All expense data cleared!')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Data')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.warning_rounded, size: 100, color: Colors.red),
              const SizedBox(height: 30),
              const Text('Are you sure?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text(
                'This will permanently delete all your recorded expenses. This action cannot be undone.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 50),
              ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Confirm Reset'),
                    content: const Text('Do you really want to clear all data?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _resetExpenses(context);
                        },
                        child: const Text('Yes, Reset', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 55),
                ),
                child: const Text('RESET ALL EXPENSES'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
