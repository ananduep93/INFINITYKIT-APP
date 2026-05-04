import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/survey_service.dart';
import '../services/upload_service.dart';
import '../utils/theme.dart';

class PublicSurveyScreen extends StatefulWidget {
  final String? surveyId;
  final String? userId;

  const PublicSurveyScreen({super.key, this.surveyId, this.userId});

  @override
  State<PublicSurveyScreen> createState() => _PublicSurveyScreenState();
}

class _PublicSurveyScreenState extends State<PublicSurveyScreen> {
  final _idController = TextEditingController();
  final _userIdController = TextEditingController();
  bool _isLoading = false;
  Map<String, dynamic>? _surveyData;
  final Map<String, dynamic> _answers = {};
  final Map<String, bool> _uploadingStatus = {};

  @override
  void initState() {
    super.initState();
    if (widget.surveyId != null && widget.userId != null) {
      _loadSurvey(widget.surveyId!, widget.userId!);
    }
  }

  Future<void> _loadSurvey(String sid, String uid) async {
    setState(() => _isLoading = true);
    try {
      final doc = await SurveyService.getSurvey(sid, uid);
      if (doc.exists) {
        setState(() => _surveyData = doc.data() as Map<String, dynamic>);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Survey not found.')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _submit() async {
    final questions = _surveyData!['questions'] as List;
    for (var q in questions) {
      if (q['required'] == true && (_answers[q['id']] == null || _answers[q['id']].toString().isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please answer: ${q['text']}')));
        return;
      }
    }

    if (_uploadingStatus.values.contains(true)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please wait for files to finish uploading.')));
      return;
    }

    setState(() => _isLoading = true);
    final responseList = _answers.entries.map((e) => {'questionId': e.key, 'value': e.value}).toList();
    
    await SurveyService.submitResponse(widget.surveyId ?? _idController.text, responseList);
    
    setState(() {
      _isLoading = false;
      _surveyData = null;
      _answers.clear();
    });

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Success!'),
          content: const Text('Your response has been submitted. Thank you!'),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_surveyData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Fill Public Survey')),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const Text('Enter Survey Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextField(controller: _idController, decoration: const InputDecoration(labelText: 'Survey ID', border: OutlineInputBorder())),
              const SizedBox(height: 15),
              TextField(controller: _userIdController, decoration: const InputDecoration(labelText: 'Owner User ID', border: OutlineInputBorder())),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : () => _loadSurvey(_idController.text, _userIdController.text),
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 55)),
                child: _isLoading ? const CircularProgressIndicator() : const Text('Load Survey'),
              ),
            ],
          ),
        ),
      );
    }

    final questions = _surveyData!['questions'] as List;

    return Scaffold(
      appBar: AppBar(title: Text(_surveyData!['title'])),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_surveyData!['description'] ?? '', style: const TextStyle(color: AppTheme.subtitleColor, fontSize: 16)),
            const SizedBox(height: 30),
            ...questions.map((q) => _buildQuestionInput(q)),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 60), backgroundColor: AppTheme.primaryColor, foregroundColor: Colors.white),
              child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Submit Response'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionInput(Map<String, dynamic> q) {
    return Container(
      margin: const EdgeInsets.only(bottom: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(q['text'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          if (q['required'] == true) const Text('* Required', style: TextStyle(color: Colors.red, fontSize: 12)),
          const SizedBox(height: 10),
          _buildInputByType(q),
        ],
      ),
    );
  }

  Widget _buildInputByType(Map<String, dynamic> q) {
    final id = q['id'];
    switch (q['type']) {
      case 'short':
        return TextField(onChanged: (val) => _answers[id] = val, decoration: const InputDecoration(border: OutlineInputBorder()));
      case 'long':
        return TextField(onChanged: (val) => _answers[id] = val, maxLines: 4, decoration: const InputDecoration(border: OutlineInputBorder()));
      case 'mcq':
        final options = (q['options'] as List).cast<String>();
        return RadioGroup<String>(
          groupValue: _answers[id],
          onChanged: (val) => setState(() => _answers[id] = val),
          child: Column(
            children: options.map((opt) => RadioListTile<String>(
              title: Text(opt),
              value: opt,
            )).toList(),
          ),
        );
      case 'dropdown':
        final options = (q['options'] as List).cast<String>();
        return DropdownButtonFormField<String>(
          items: options.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
          onChanged: (val) => _answers[id] = val,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        );
      case 'image-mcq':
        final imgOptions = (q['imageOptions'] as List).cast<String>();
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: imgOptions.map((url) => GestureDetector(
            onTap: () => setState(() => _answers[id] = url),
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                border: Border.all(color: _answers[id] == url ? AppTheme.primaryColor : Colors.grey[300]!, width: 3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: Image.network(url, fit: BoxFit.cover),
              ),
            ),
          )).toList(),
        );
      case 'file':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_answers[id] != null) 
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text('Uploaded: ${_answers[id].toString().split('/').last}', style: const TextStyle(color: Colors.green)),
              ),
            ElevatedButton.icon(
              onPressed: _uploadingStatus[id] == true ? null : () async {
                FilePickerResult? result = await FilePicker.pickFiles(type: FileType.image);
                if (result != null) {
                  setState(() => _uploadingStatus[id] = true);
                  final url = await UploadService.uploadToImgBB(File(result.files.single.path!));
                  if (url != null) {
                    setState(() => _answers[id] = url);
                  }
                  setState(() => _uploadingStatus[id] = false);
                }
              },
              icon: _uploadingStatus[id] == true ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.upload_file),
              label: Text(_uploadingStatus[id] == true ? 'Uploading...' : 'Pick & Upload Image'),
            ),
          ],
        );
      default:
        return const Text('Unsupported question type');
    }
  }
}
