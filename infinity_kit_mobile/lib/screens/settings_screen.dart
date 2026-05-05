import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../utils/theme.dart';
import 'package:url_launcher/url_launcher.dart';
import 'privacy_policy_screen.dart';
import 'edit_profile_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch \$url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.user;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // Profile Header
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                  backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                  child: user?.photoURL == null 
                    ? Text(user?.displayName?[0] ?? 'U', style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold))
                    : null,
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?.displayName ?? 'User', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Text(user?.email ?? 'No email', style: const TextStyle(color: AppTheme.subtitleColor)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // Account Settings
          _buildSectionTitle('Account'),
          _buildListTile(Icons.person_outline, 'Edit Profile', () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen()));
          }),
          
          const SizedBox(height: 20),
          
          // App Information
          _buildSectionTitle('App Info'),
          _buildListTile(Icons.privacy_tip_outlined, 'Privacy Policy', () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()));
          }),
          _buildListTile(Icons.description_outlined, 'Terms of Service', () {
            _launchUrl('https://infinitykit.app/terms');
          }),
          _buildListTile(Icons.info_outline, 'About Infinity Kit', () {
            _launchUrl('https://infinitykit.app');
          }),
          
          const SizedBox(height: 40),
          
          // Logout Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton.icon(
              onPressed: () async {
                HapticFeedback.mediumImpact();
                await authService.signOut();
                if (context.mounted) Navigator.pop(context);
              },
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Center(child: Text('Version 1.0.0', style: TextStyle(color: Colors.grey, fontSize: 12))),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.subtitleColor, letterSpacing: 1),
      ),
    );
  }

  Widget _buildListTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      tileColor: Colors.white,
    );
  }
}
