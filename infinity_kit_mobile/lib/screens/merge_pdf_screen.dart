import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdf_merger/pdf_merger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../utils/theme.dart';

class MergePdfScreen extends StatefulWidget {
  const MergePdfScreen({super.key});

  @override
  State<MergePdfScreen> createState() => _MergePdfScreenState();
}

class _MergePdfScreenState extends State<MergePdfScreen> {
  final List<File> _pdfFiles = [];
  bool _isProcessing = false;
  String _status = '';

  Future<void> _pickFiles() async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: true,
    );

    if (result != null) {
      setState(() {
        _pdfFiles.addAll(result.paths.map((path) => File(path!)).toList());
      });
    }
  }

  Future<void> _mergePdfs() async {
    if (_pdfFiles.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select at least 2 PDF files')));
      return;
    }

    setState(() {
      _isProcessing = true;
      _status = 'Merging PDFs...';
    });

    try {
      final tempDir = await getTemporaryDirectory();
      final outputFileName = 'merged_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final outputPath = '${tempDir.path}/$outputFileName';

      List<String> paths = _pdfFiles.map((f) => f.path).toList();

      final response = await PdfMerger.mergeMultiplePDF(
        paths: paths,
        outputDirPath: outputPath,
      );

      if (response.status == "success") {
        setState(() {
          _isProcessing = false;
          _status = 'Success! PDFs merged.';
        });
        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(outputPath)],
            text: 'Merged PDF',
          ),
        );
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _status = 'Error: $e';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📎 Merge PDF')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              'Select multiple PDF files to combine them into a single document.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.subtitleColor),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _pickFiles, 
              icon: const Icon(Icons.add), 
              label: const Text('Add PDF Files'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                foregroundColor: AppTheme.primaryColor,
                elevation: 0,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _pdfFiles.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.library_books_outlined, size: 80, color: Colors.grey[200]),
                          const Text('No files selected', style: TextStyle(color: AppTheme.subtitleColor)),
                        ],
                      ),
                    )
                  : ReorderableListView.builder(
                      itemCount: _pdfFiles.length,
                      onReorder: (oldIndex, newIndex) {
                        setState(() {
                          if (newIndex > oldIndex) newIndex -= 1;
                          final item = _pdfFiles.removeAt(oldIndex);
                          _pdfFiles.insert(newIndex, item);
                        });
                      },
                      itemBuilder: (context, index) => Card(
                        key: ValueKey(_pdfFiles[index].path),
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.red[50],
                            child: const Text('PDF', style: TextStyle(fontSize: 10, color: Colors.red, fontWeight: FontWeight.bold)),
                          ),
                          title: Text(_pdfFiles[index].path.split('/').last, maxLines: 1, overflow: TextOverflow.ellipsis),
                          subtitle: Text('${(_pdfFiles[index].lengthSync() / 1024).toStringAsFixed(1)} KB'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() => _pdfFiles.removeAt(index))),
                              const Icon(Icons.drag_handle, color: Colors.grey),
                            ],
                          ),
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 20),
            if (_isProcessing)
              Column(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 10),
                  Text(_status, style: const TextStyle(color: AppTheme.subtitleColor)),
                ],
              )
            else
              ElevatedButton(
                onPressed: _pdfFiles.length < 2 ? null : _mergePdfs,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text('Merge & Share PDF', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
      ),
    );
  }
}
