import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import 'package:intl/intl.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _firestoreService = FirestoreService();
  String _selectedCategory = 'Food';
  final List<String> _categories = [
    'Food',
    'Transport',
    'Shopping',
    'Bills',
    'Health',
    'Entertainment',
    'Education',
    'Travel',
    'Other'
  ];

  Future<void> _saveExpense() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _amountController.text.isEmpty) return;

    final double amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount <= 0) return;

    final String note = _noteController.text.trim();
    final String date = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // Fetch current DB
    final currentData = await _firestoreService.getToolData('infinityKitExpenseDB');
    Map<String, dynamic> db = (currentData is Map) ? Map<String, dynamic>.from(currentData) : {'expenses': [], 'budgets': {}};
    
    List<dynamic> expenses = List.from(db['expenses'] ?? []);
    
    // Create new expense object matching web structure
    final newExpense = {
      'id': '${DateTime.now().millisecondsSinceEpoch}${((999999 - 100000) * (DateTime.now().microsecond / 1000000)).toInt() + 100000}',
      'amount': amount,
      'category': _selectedCategory,
      'date': date,
      'note': note,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    };

    expenses.add(newExpense);
    db['expenses'] = expenses;

    await _firestoreService.saveToolData('infinityKitExpenseDB', db);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Expense Added!')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('➕ Add Expense')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                hintText: '0.00',
                prefixText: '₹ ',
                border: InputBorder.none,
              ),
            ),
            const SizedBox(height: 30),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
              items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (val) => setState(() => _selectedCategory = val!),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                labelText: 'Note (e.g. Lunch)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _saveExpense,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Save Expense'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
