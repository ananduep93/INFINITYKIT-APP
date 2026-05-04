import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../services/upload_service.dart';
import '../services/survey_service.dart';
import '../utils/theme.dart';

class SurveyBuilderScreen extends StatefulWidget {
  final Map<String, dynamic>? existingSurvey;
  final String? surveyId;

  const SurveyBuilderScreen({super.key, this.existingSurvey, this.surveyId});

  @override
  State<SurveyBuilderScreen> createState() => _SurveyBuilderScreenState();
}

class _SurveyBuilderScreenState extends State<SurveyBuilderScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  List<Map<String, dynamic>> _questions = [];

  @override
  void initState() {
    super.initState();
    if (widget.existingSurvey != null) {
      _titleController.text = widget.existingSurvey!['title'] ?? '';
      _descController.text = widget.existingSurvey!['description'] ?? '';
      _questions = List<Map<String, dynamic>>.from(widget.existingSurvey!['questions'] ?? []);
    }
  }

  void _addQuestion() {
    _showQuestionDialog();
  }

  void _showQuestionDialog({int? index}) {
    final isEditing = index != null;
    final q = isEditing ? _questions[index] : null;

    String type = q?['type'] ?? 'short';
    final textController = TextEditingController(text: q?['text'] ?? '');
    final optionsController = TextEditingController(text: (q?['options'] as List?)?.join('\n') ?? '');
    List<String> imageOptions = List<String>.from(q?['imageOptions'] ?? []);
    bool required = q?['required'] ?? false;
    bool isUploading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'Edit Question' : 'Add Question'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: type,
                  items: ['short', 'long', 'mcq', 'checkbox', 'dropdown', 'image-mcq', 'file']
                      .map((t) => DropdownMenuItem(value: t, child: Text(t.toUpperCase())))
                      .toList(),
                  onChanged: (val) => setDialogState(() => type = val!),
                  decoration: const InputDecoration(labelText: 'Question Type'),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: textController,
                  decoration: const InputDecoration(labelText: 'Question Text', hintText: 'What is your favorite color?'),
                ),
                if (['mcq', 'checkbox', 'dropdown'].contains(type)) ...[
                  const SizedBox(height: 15),
                  TextField(
                    controller: optionsController,
                    maxLines: 4,
                    decoration: const InputDecoration(labelText: 'Options (One per line)', hintText: 'Red\nBlue\nGreen'),
                  ),
                ],
                if (type == 'image-mcq') ...[
                  const SizedBox(height: 15),
                  const Text('Image Options:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Wrap(
                    spacing: 8,
                    children: [
                      ...imageOptions.map((url) => Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(url, width: 60, height: 60, fit: BoxFit.cover),
                          ),
                          Positioned(
                            right: -5,
                            top: -5,
                            child: IconButton(
                              icon: const Icon(Icons.cancel, color: Colors.red, size: 20),
                              onPressed: () => setDialogState(() => imageOptions.remove(url)),
                            ),
                          ),
                        ],
                      )),
                      if (isUploading)
                        const SizedBox(width: 60, height: 60, child: Center(child: CircularProgressIndicator())),
                      IconButton(
                        icon: const Icon(Icons.add_a_photo, size: 40, color: AppTheme.primaryColor),
                        onPressed: isUploading ? null : () async {
                          FilePickerResult? result = await FilePicker.pickFiles(type: FileType.image, allowMultiple: true);
                          if (result != null) {
                            setDialogState(() => isUploading = true);
                            for (var path in result.paths) {
                              if (path != null) {
                                final url = await UploadService.uploadToImgBB(File(path));
                                if (url != null) setDialogState(() => imageOptions.add(url));
                              }
                            }
                            setDialogState(() => isUploading = false);
                          }
                        },
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 15),
                SwitchListTile(
                  title: const Text('Required'),
                  value: required,
                  onChanged: (val) => setDialogState(() => required = val),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: isUploading ? null : () {
                if (textController.text.isEmpty) return;
                final questionData = {
                  'id': q?['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
                  'type': type,
                  'text': textController.text.trim(),
                  'required': required,
                  'options': optionsController.text.split('\n').where((o) => o.trim().isNotEmpty).toList(),
                  'imageOptions': imageOptions,
                };
                setState(() {
                  if (isEditing) {
                    _questions[index] = questionData;
                  } else {
                    _questions.add(questionData);
                  }
                });
                Navigator.pop(context);
              },
              child: Text(isEditing ? 'Update' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveSurvey() async {
    if (_titleController.text.isEmpty || _questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add a title and at least one question')));
      return;
    }

    final data = {
      'title': _titleController.text.trim(),
      'description': _descController.text.trim(),
      'questions': _questions,
      'createdAt': widget.existingSurvey?['createdAt'] ?? DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };

    await SurveyService.saveSurvey(data, id: widget.surveyId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Survey Saved!')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Survey Builder')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildHeader(),
                const SizedBox(height: 30),
                const Text('Questions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                if (_questions.isEmpty)
                  const Center(child: Padding(padding: EdgeInsets.all(40.0), child: Text('No questions added yet.', style: TextStyle(color: Colors.grey))))
                else
                  ...List.generate(_questions.length, (i) => _buildQuestionCard(i)),
              ],
            ),
          ),
          _buildFooterActions(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15)],
      ),
      child: Column(
        children: [
          TextField(
            controller: _titleController,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(hintText: 'Survey Title', border: InputBorder.none),
          ),
          const Divider(),
          TextField(
            controller: _descController,
            maxLines: 2,
            decoration: const InputDecoration(hintText: 'Survey Description', border: InputBorder.none),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(int index) {
    final q = _questions[index];
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1), child: Text('${index + 1}', style: const TextStyle(color: AppTheme.primaryColor))),
        title: Text(q['text'], style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Type: ${q['type']} ${q['required'] ? '(Required)' : ''}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: () => _showQuestionDialog(index: index)),
            IconButton(icon: const Icon(Icons.delete, size: 20, color: Colors.red), onPressed: () => setState(() => _questions.removeAt(index))),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))]),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _addQuestion,
              icon: const Icon(Icons.add),
              label: const Text('Add Question'),
              style: OutlinedButton.styleFrom(minimumSize: const Size(0, 55), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _saveSurvey,
              icon: const Icon(Icons.save),
              label: const Text('Save Survey'),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, foregroundColor: Colors.white, minimumSize: const Size(0, 55), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
            ),
          ),
        ],
      ),
    );
  }
}
