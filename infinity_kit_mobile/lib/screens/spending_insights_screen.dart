import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SpendingInsightsScreen extends StatelessWidget {
  const SpendingInsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Spending Insights')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .collection('expenses')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('Add some expenses to get insights!'));

          double total = 0;
          Map<String, double> categories = {};
          for (var doc in docs) {
            final amt = (doc.data() as Map<String, dynamic>)['amount'] as num;
            final cat = (doc.data() as Map<String, dynamic>)['category'] ?? 'General';
            total += amt;
            categories[cat] = (categories[cat] ?? 0) + amt;
          }

          String topCategory = categories.entries.reduce((a, b) => a.value > b.value ? a : b).key;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const Icon(Icons.lightbulb, size: 48, color: Colors.blue),
                      const SizedBox(height: 10),
                      const Text('Insights for You', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Text('Your total spending is ₹${total.toStringAsFixed(2)}. You spend the most on $topCategory.'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildInsightCard('Budget Tip', 'Try to keep your food expenses below 20% of your total budget.', Icons.restaurant),
              _buildInsightCard('Savings Tip', 'Save at least 10% of your income before spending.', Icons.savings),
              _buildInsightCard('Warning', 'Your spending on \$topCategory has increased by 15% this month.', Icons.warning_amber),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInsightCard(String title, String desc, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(desc),
      ),
    );
  }
}
