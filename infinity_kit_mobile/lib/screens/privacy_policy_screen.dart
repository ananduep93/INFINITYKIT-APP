import 'package:flutter/material.dart';
import '../utils/theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Privacy Policy for Infinity Kit',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text('Last updated: May 01, 2026', style: TextStyle(color: AppTheme.subtitleColor)),
            const SizedBox(height: 20),
            _buildSection('1. Information Collection', 'We collect information you provide directly to us, such as when you create an account, use our tools, or communicate with us.'),
            _buildSection('2. How We Use Information', 'We use the information we collect to provide, maintain, and improve our services, and to develop new tools.'),
            _buildSection('3. Information Sharing', 'We do not share your personal information with third parties except as described in this policy.'),
            _buildSection('4. Data Security', 'We take reasonable measures to protect your personal information from loss, theft, and misuse.'),
            _buildSection('5. Contact Us', 'If you have any questions about this Privacy Policy, please contact us at support@infinitykit.app.'),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(height: 1.5)),
        ],
      ),
    );
  }
}
