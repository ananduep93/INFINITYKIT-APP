import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import '../services/survey_service.dart';
import '../utils/theme.dart';
import 'survey_builder_screen.dart';
import 'response_viewer_screen.dart';

class MySurveysScreen extends StatelessWidget {
  const MySurveysScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Surveys'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SurveyBuilderScreen())),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: SurveyService.getMySurveys(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.poll_outlined, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 20),
                  const Text('No surveys created yet.', style: TextStyle(color: Colors.grey, fontSize: 18)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SurveyBuilderScreen())),
                    child: const Text('Create Your First Survey'),
                  ),
                ],
              ),
            );
          }

          final docs = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final id = doc.id;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text(data['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                            child: Text('${(data['questions'] as List).length} Questions', style: const TextStyle(color: AppTheme.primaryColor, fontSize: 12)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(data['description'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppTheme.subtitleColor)),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildAction(Icons.link, 'Link', () {
                            Clipboard.setData(ClipboardData(text: 'https://infinitykit.online/survey/?id=$id'));
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Survey link copied to clipboard!')));
                          }),
                          _buildAction(Icons.bar_chart, 'Responses', () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => ResponseViewerScreen(surveyId: id, surveyTitle: data['title'])));
                          }),
                          _buildAction(Icons.edit, 'Edit', () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => SurveyBuilderScreen(existingSurvey: data, surveyId: id)));
                          }),
                          _buildAction(Icons.delete, 'Delete', () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete Survey?'),
                                content: const Text('This will also delete all responses. Action cannot be undone.'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                  TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              await SurveyService.deleteSurvey(id);
                            }
                          }, color: Colors.red),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildAction(IconData icon, String label, VoidCallback onTap, {Color color = AppTheme.primaryColor}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: color, fontSize: 12)),
        ],
      ),
    );
  }
}
