import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';

class ExpenseAnalyticsScreen extends StatefulWidget {
  const ExpenseAnalyticsScreen({super.key});

  @override
  State<ExpenseAnalyticsScreen> createState() => _ExpenseAnalyticsScreenState();
}

class _ExpenseAnalyticsScreenState extends State<ExpenseAnalyticsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    if (user == null) return const Scaffold(body: Center(child: Text('Please log in')));

    return Scaffold(
      appBar: AppBar(title: const Text('Expense Analytics')),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestoreService.getToolDataStream('infinityKitExpenseDB'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data?.data() as Map<String, dynamic>?;
          final List<dynamic> rawExpenses = (data != null && data['data'] is Map && data['data']['expenses'] is List) 
              ? data['data']['expenses'] 
              : [];
          
          final List<Map<String, dynamic>> expenses = rawExpenses.map((e) => Map<String, dynamic>.from(e)).toList();

          if (expenses.isEmpty) {
            return const Center(child: Text('No data for analytics.'));
          }

          // Data aggregation for Pie Chart
          Map<String, double> categoryData = {};
          for (var expense in expenses) {
            final cat = expense['category'] ?? 'General';
            final amt = (expense['amount'] as num).toDouble();
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
