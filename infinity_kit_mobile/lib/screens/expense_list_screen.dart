import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/theme.dart';

class ExpenseListScreen extends StatelessWidget {
  const ExpenseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final expensesRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection('expenses');

    return Scaffold(
      appBar: AppBar(title: const Text('📋 Expense List')),
      body: StreamBuilder<QuerySnapshot>(
        stream: expensesRef.orderBy('date', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('No expenses recorded yet.'));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                    child: const Icon(Icons.money_off, color: AppTheme.primaryColor),
                  ),
                  title: Text(data['title'] ?? 'Untitled', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(data['category'] ?? 'General'),
                  trailing: Text(
                    '-₹ ${data['amount']}',
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
