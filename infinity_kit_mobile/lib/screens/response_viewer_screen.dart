import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/survey_service.dart';
import '../utils/theme.dart';

class ResponseViewerScreen extends StatelessWidget {
  final String surveyId;
  final String surveyTitle;

  const ResponseViewerScreen({super.key, required this.surveyId, required this.surveyTitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Responses: $surveyTitle')),
      body: StreamBuilder<QuerySnapshot>(
        stream: SurveyService.getResponses(surveyId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text('No responses yet.'));

          final docs = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final resp = docs[index].data() as Map<String, dynamic>;
              final answers = (resp['answers'] as List).cast<Map<String, dynamic>>();
              final submittedAt = (resp['submittedAt'] as Timestamp?)?.toDate() ?? DateTime.now();

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ExpansionTile(
                  title: Text('Response #${docs.length - index}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Submitted: ${submittedAt.toString().substring(0, 16)}'),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: answers.map((a) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Q: ${a['questionId']}', style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.primaryColor)),
                                const SizedBox(height: 4),
                                _buildAnswerValue(a['value']),
                                const Divider(),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildAnswerValue(dynamic value) {
    final valStr = value.toString();
    final isImageUrl = valStr.startsWith('http') && (valStr.contains('imgbb.com') || valStr.contains('.png') || valStr.contains('.jpg') || valStr.contains('.jpeg'));

    if (isImageUrl) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(valStr, height: 150, fit: BoxFit.cover, errorBuilder: (_, _, _) => const Icon(Icons.broken_image)),
          ),
          const SizedBox(height: 4),
          Text(valStr, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      );
    }
    return Text('A: $valStr', style: const TextStyle(fontSize: 16));
  }
}
