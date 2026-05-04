import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdf_manipulator/pdf_manipulator.dart';
import 'package:pdfx/pdfx.dart';
import 'package:share_plus/share_plus.dart';
import '../utils/theme.dart';

class RotatePdfScreen extends StatefulWidget {
  const RotatePdfScreen({super.key});

  @override
  State<RotatePdfScreen> createState() => _RotatePdfScreenState();
}

class _RotatePdfScreenState extends State<RotatePdfScreen> {
  File? _selectedPdf;
  bool _isProcessing = false;
  String _status = '';
  double _rotationAngle = 90;

  Future<void> _pickPdf() async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() {
        _selectedPdf = File(result.files.single.path!);
        _status = '';
      });
    }
  }

  Future<void> _rotatePdf() async {
    if (_selectedPdf == null) return;

    setState(() {
      _isProcessing = true;
      _status = 'Rotating PDF...';
    });

    try {
      // Get page count using pdfx
      final document = await PdfDocument.openFile(_selectedPdf!.path);
      final pageCount = document.pagesCount;
      await document.close();

      List<PageRotationInfo> rotationInfos = [];
      for (int i = 1; i <= pageCount; i++) {
        rotationInfos.add(PageRotationInfo(
          pageNumber: i,
          rotationAngle: _rotationAngle.toInt(),
        ));
      }

      final rotatedPath = await PdfManipulator().pdfPageRotator(
        params: PDFPageRotatorParams(
          pdfPath: _selectedPdf!.path,
          pagesRotationInfo: rotationInfos,
        ),
      );

      if (rotatedPath != null) {
        setState(() {
          _isProcessing = false;
          _status = 'Success! PDF rotated.';
        });
        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(rotatedPath)],
            text: 'Rotated PDF',
          ),
        );
      } else {
        throw Exception('Failed to rotate PDF');
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
      appBar: AppBar(title: const Text('🔄 Rotate PDF')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              'Rotate all pages in your PDF document by a specific angle.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.subtitleColor),
            ),
            const SizedBox(height: 30),
            if (_selectedPdf == null)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.rotate_right_outlined, size: 100, color: Colors.grey[200]),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _pickPdf,
                        icon: const Icon(Icons.file_open),
                        label: const Text('Select PDF File'),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              Card(
                child: ListTile(
                  leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                  title: Text(_selectedPdf!.path.split('/').last),
                  subtitle: Text('${(_selectedPdf!.lengthSync() / 1024).toStringAsFixed(1)} KB'),
                  trailing: IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() => _selectedPdf = null)),
                ),
              ),
              const SizedBox(height: 40),
              const Text('Select Rotation Angle:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildAngleOption(90, '↷ 90°'),
                  const SizedBox(width: 15),
                  _buildAngleOption(180, '↻ 180°'),
                  const SizedBox(width: 15),
                  _buildAngleOption(270, '↶ 270°'),
                ],
              ),
              const SizedBox(height: 50),
              if (_isProcessing)
                Column(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 10),
                    Text(_status, style: const TextStyle(color: AppTheme.subtitleColor)),
                  ],
                )
              else
                ElevatedButton.icon(
                  onPressed: _rotatePdf,
                  icon: const Icon(Icons.rotate_right),
                  label: const Text('Rotate & Save', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAngleOption(double angle, String label) {
    bool isSelected = _rotationAngle == angle;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) setState(() => _rotationAngle = angle);
      },
      selectedColor: AppTheme.primaryColor,
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
    );
  }
}
