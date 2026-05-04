import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ExpenseAnalyticsScreen extends StatelessWidget {
  const ExpenseAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Expense Analytics')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .collection('expenses')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('No data for analytics.'));

          // Simple data aggregation for Pie Chart
          Map<String, double> categoryData = {};
          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            final cat = data['category'] ?? 'General';
            final amt = (data['amount'] as num).toDouble();
            categoryData[cat] = (categoryData[cat] ?? 0) + amt;
          }

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const Text('Expense Distribution', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 30),
                SizedBox(
                  height: 300,
                  child: PieChart(
                    PieChartData(
                      sections: categoryData.entries.map((e) {
                        return PieChartSectionData(
                          value: e.value,
                          title: '${e.key}\n₹${e.value.toInt()}',
                          color: Colors.primaries[categoryData.keys.toList().indexOf(e.key) % Colors.primaries.length],
                          radius: 100,
                          titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: ListView(
                    children: categoryData.entries.map((e) => ListTile(
                      leading: CircleAvatar(backgroundColor: Colors.primaries[categoryData.keys.toList().indexOf(e.key) % Colors.primaries.length]),
                      title: Text(e.key),
                      trailing: Text('₹${e.value.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    )).toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
