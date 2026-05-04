import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdfx/pdfx.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../utils/theme.dart';

class PdfToImageScreen extends StatefulWidget {
  const PdfToImageScreen({super.key});

  @override
  State<PdfToImageScreen> createState() => _PdfToImageScreenState();
}

class _PdfToImageScreenState extends State<PdfToImageScreen> {
  File? _selectedPdf;
  List<Uint8List> _images = [];
  bool _isProcessing = false;
  String _status = '';

  Future<void> _pickPdf() async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() {
        _selectedPdf = File(result.files.single.path!);
        _images = [];
        _status = '';
      });
    }
  }

  Future<void> _convertToImages() async {
    if (_selectedPdf == null) return;

    setState(() {
      _isProcessing = true;
      _status = 'Opening PDF...';
    });

    try {
      final document = await PdfDocument.openFile(_selectedPdf!.path);
      final pageCount = document.pagesCount;
      List<Uint8List> extractedImages = [];

      for (int i = 1; i <= pageCount; i++) {
        setState(() => _status = 'Extracting Page $i of $pageCount...');
        final page = await document.getPage(i);
        final pageImage = await page.render(
          width: page.width * 2, // Higher resolution
          height: page.height * 2,
          format: PdfPageImageFormat.jpeg,
          quality: 80,
        );
        if (pageImage != null) {
          extractedImages.add(pageImage.bytes);
        }
        await page.close();
      }

      await document.close();

      setState(() {
        _images = extractedImages;
        _isProcessing = false;
        _status = 'Success! ${_images.length} images extracted.';
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _status = 'Error: $e';
      });
    }
  }

  Future<void> _shareImages() async {
    if (_images.isEmpty) return;

    setState(() => _isProcessing = true);
    try {
      final tempDir = await getTemporaryDirectory();
      List<XFile> xFiles = [];

      for (int i = 0; i < _images.length; i++) {
        final path = '${tempDir.path}/page_${i + 1}.jpg';
        final file = File(path);
        await file.writeAsBytes(_images[i]);
        xFiles.add(XFile(path));
      }

      await SharePlus.instance.share(
        ShareParams(
          files: xFiles,
          text: 'Extracted images from PDF',
        ),
      );
      setState(() => _isProcessing = false);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error sharing: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📸 PDF to Image')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            if (_selectedPdf == null)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.picture_as_pdf_outlined, size: 100, color: Colors.grey[300]),
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
                  subtitle: Text('${(_selectedPdf!.lengthSync() / 1024 / 1024).toStringAsFixed(2)} MB'),
                  trailing: IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() => _selectedPdf = null)),
                ),
              ),
              const SizedBox(height: 20),
              if (_images.isEmpty && !_isProcessing)
                ElevatedButton.icon(
                  onPressed: _convertToImages,
                  icon: const Icon(Icons.transform),
                  label: const Text('Convert to Images'),
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 55)),
                ),
              if (_isProcessing) ...[
                const CircularProgressIndicator(),
                const SizedBox(height: 10),
                Text(_status, style: const TextStyle(color: AppTheme.subtitleColor)),
              ],
              if (_images.isNotEmpty) ...[
                Text(_status, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: _images.length,
                    itemBuilder: (context, index) => ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.memory(_images[index], fit: BoxFit.cover),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _shareImages,
                  icon: const Icon(Icons.share),
                  label: const Text('Share All Images'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 55),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
