import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../services/firestore_service.dart';


class ExpenseReportScreen extends StatefulWidget {
  const ExpenseReportScreen({super.key});

  @override
  State<ExpenseReportScreen> createState() => _ExpenseReportScreenState();
}

class _ExpenseReportScreenState extends State<ExpenseReportScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final User? user = FirebaseAuth.instance.currentUser;

  String _formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(amount);
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) return const Scaffold(body: Center(child: Text('Please log in')));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Report'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
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

          // Calculate Totals
          final now = DateTime.now();
          final todayStr = DateFormat('yyyy-MM-dd').format(now);
          final startOfWeek = now.subtract(Duration(days: now.weekday % 7)); 
          final startOfMonth = DateTime(now.year, now.month, 1);

          double todayTotal = 0;
          double weekTotal = 0;
          double monthTotal = 0;

          for (var expense in expenses) {
            final double amount = (expense['amount'] as num).toDouble();
            final String dateStr = expense['date'] ?? '';
            final DateTime? date = DateTime.tryParse(dateStr);

            if (dateStr == todayStr) todayTotal += amount;
            if (date != null && (date.isAfter(startOfWeek) || date.isAtSameMomentAs(startOfWeek))) weekTotal += amount;
            if (date != null && (date.isAfter(startOfMonth) || date.isAtSameMomentAs(startOfMonth))) monthTotal += amount;
          }

          // Sort expenses by date descending
          expenses.sort((a, b) {
            final dateA = a['date'] ?? '';
            final dateB = b['date'] ?? '';
            if (dateA == dateB) {
              return (b['createdAt'] ?? 0).compareTo(a['createdAt'] ?? 0);
            }
            return dateB.compareTo(dateA);
          });

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Summary Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('🗓️', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        Text(
                          'Daily / Monthly Report',
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        _buildSummaryItem('Today', todayTotal),
                        const SizedBox(width: 12),
                        _buildSummaryItem('This Week', weekTotal),
                        const SizedBox(width: 12),
                        _buildSummaryItem('This Month', monthTotal),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  'Recent Transactions',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              const SizedBox(height: 12),
              
              if (expenses.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Center(child: Text('No expenses recorded.')),
                )
              else
                ...expenses.map((expense) => _buildExpenseItem(expense)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryItem(String title, double amount) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                _formatCurrency(amount),
                style: const TextStyle(
                  color: Color(0xFF2563EB),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseItem(Map<String, dynamic> expense) {
    final category = expense['category'] ?? 'Other';
    final amount = (expense['amount'] as num).toDouble();
    final note = expense['note'] ?? '';
    final dateStr = expense['date'] ?? '';

    IconData icon;
    Color color;

    switch (category) {
      case 'Food': icon = Icons.restaurant; color = Colors.orange; break;
      case 'Transport': icon = Icons.directions_car; color = Colors.blue; break;
      case 'Shopping': icon = Icons.shopping_bag; color = Colors.purple; break;
      case 'Bills': icon = Icons.receipt; color = Colors.red; break;
      case 'Entertainment': icon = Icons.movie; color = Colors.green; break;
      case 'Health': icon = Icons.medical_services; color = Colors.teal; break;
      case 'Education': icon = Icons.school; color = Colors.indigo; break;
      case 'Travel': icon = Icons.flight; color = Colors.cyan; break;
      default: icon = Icons.category; color = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      color: Colors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          note.isNotEmpty ? note : category,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          dateStr,
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        trailing: Text(
          '-${_formatCurrency(amount)}',
          style: const TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
