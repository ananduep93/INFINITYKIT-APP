import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BudgetTrackerScreen extends StatefulWidget {
  const BudgetTrackerScreen({super.key});

  @override
  State<BudgetTrackerScreen> createState() => _BudgetTrackerScreenState();
}

class _BudgetTrackerScreenState extends State<BudgetTrackerScreen> {
  final _budgetController = TextEditingController();
  final _user = FirebaseAuth.instance.currentUser;
  final _firestore = FirebaseFirestore.instance;

  Future<void> _saveBudget() async {
    if (_budgetController.text.isEmpty) return;
    await _firestore.collection('users').doc(_user?.uid).update({
      'monthlyBudget': double.parse(_budgetController.text),
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Budget Updated!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Budget Tracker')),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestore.collection('users').doc(_user?.uid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          final budget = data?['monthlyBudget']?.toDouble() ?? 0.0;

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        const Text('Monthly Budget', style: TextStyle(fontSize: 18, color: Colors.grey)),
                        const SizedBox(height: 10),
                        Text('₹${budget.toStringAsFixed(2)}', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.blue)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: _budgetController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Set New Budget', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveBudget,
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 55)),
                  child: const Text('Update Budget'),
                ),
                const SizedBox(height: 40),
                const Text('Tip: Track your expenses daily to stay within your budget!', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
              ],
            ),
          );
        },
      ),
    );
  }
}
