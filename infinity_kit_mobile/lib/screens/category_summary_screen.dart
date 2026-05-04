import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CategorySummaryScreen extends StatelessWidget {
  const CategorySummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Category Summary')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .collection('expenses')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;
          
          Map<String, double> summary = {};
          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            final cat = data['category'] ?? 'General';
            final amt = (data['amount'] as num).toDouble();
            summary[cat] = (summary[cat] ?? 0) + amt;
          }

          if (summary.isEmpty) return const Center(child: Text('No data found.'));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: summary.length,
            itemBuilder: (context, index) {
              String cat = summary.keys.elementAt(index);
              double amt = summary[cat]!;
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.category, color: Colors.blue),
                  title: Text(cat, style: const TextStyle(fontWeight: FontWeight.bold)),
                  trailing: Text('₹${amt.toStringAsFixed(2)}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
