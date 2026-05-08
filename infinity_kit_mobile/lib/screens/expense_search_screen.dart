import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';

class ExpenseSearchScreen extends StatefulWidget {
  const ExpenseSearchScreen({super.key});

  @override
  State<ExpenseSearchScreen> createState() => _ExpenseSearchScreenState();
}

class _ExpenseSearchScreenState extends State<ExpenseSearchScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  String _query = '';
  final _user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    if (_user == null) return const Scaffold(body: Center(child: Text('Please log in')));

    return Scaffold(
      appBar: AppBar(title: const Text('Search Expenses')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by note...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
              ),
              onChanged: (val) => setState(() => _query = val.toLowerCase()),
            ),
          ),
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: _firestoreService.getToolDataStream('infinityKitExpenseDB'),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final data = snapshot.data?.data() as Map<String, dynamic>?;
                final List<dynamic> rawExpenses = (data != null && data['data'] is Map && data['data']['expenses'] is List) 
                    ? data['data']['expenses'] 
                    : [];
                
                final List<Map<String, dynamic>> expenses = rawExpenses
                    .map((e) => Map<String, dynamic>.from(e))
                    .where((e) {
                      final note = e['note']?.toString().toLowerCase() ?? '';
                      final cat = e['category']?.toString().toLowerCase() ?? '';
                      return note.contains(_query) || cat.contains(_query);
                    }).toList();

                if (expenses.isEmpty) return const Center(child: Text('No matching expenses found.'));

                return ListView.builder(
                  itemCount: expenses.length,
                  itemBuilder: (context, index) {
                    final expense = expenses[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(expense['note'] ?? expense['category'] ?? 'Untitled', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(expense['category'] ?? 'General'),
                        trailing: Text('₹${expense['amount'] ?? '0.00'}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
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
