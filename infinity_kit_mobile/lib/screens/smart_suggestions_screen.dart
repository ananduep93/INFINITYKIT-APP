import 'package:flutter/material.dart';

class SmartSuggestionsScreen extends StatelessWidget {
  const SmartSuggestionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Smart Suggestions')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('AI Suggestions based on your habits', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _buildSuggestionTile('Limit Dining Out', 'You spent ₹2500 on restaurants this week. Try cooking at home to save ₹1500.', Icons.restaurant),
          _buildSuggestionTile('Subscription Review', 'We noticed 3 active streaming subscriptions. Do you use them all?', Icons.subscriptions),
          _buildSuggestionTile('Shopping Alert', 'You usually spend more on weekends. Try to plan your shopping on weekdays.', Icons.shopping_bag),
          _buildSuggestionTile('Investment Tip', 'You have ₹5000 unallocated this month. Consider a small SIP.', Icons.trending_up),
        ],
      ),
    );
  }

  Widget _buildSuggestionTile(String title, String desc, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(desc),
        trailing: const Icon(Icons.check_circle_outline, color: Colors.green),
      ),
    );
  }
}
