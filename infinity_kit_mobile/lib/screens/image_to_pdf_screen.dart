import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../utils/theme.dart';

class ImageToPdfScreen extends StatefulWidget {
  const ImageToPdfScreen({super.key});

  @override
  State<ImageToPdfScreen> createState() => _ImageToPdfScreenState();
}

class _ImageToPdfScreenState extends State<ImageToPdfScreen> {
  final List<File> _images = [];
  bool _isGenerating = false;
  
  String _pageSize = 'A4';
  String _fitMode = 'Contain';

  final List<String> _pageSizes = ['A4', 'Letter', 'A3'];
  final List<String> _fitModes = ['Contain', 'Cover', 'Original'];

  Future<void> _pickImages() async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );

    if (result != null) {
      setState(() {
        _images.addAll(result.paths.map((path) => File(path!)).toList());
      });
    }
  }

  PdfPageFormat _getPdfPageFormat() {
    switch (_pageSize) {
      case 'Letter': return PdfPageFormat.letter;
      case 'A3': return PdfPageFormat.a3;
      default: return PdfPageFormat.a4;
    }
  }

  Future<void> _generatePdf() async {
    if (_images.isEmpty) return;
    setState(() => _isGenerating = true);

    final pdf = pw.Document();
    final format = _getPdfPageFormat();

    for (var imageFile in _images) {
      final image = pw.MemoryImage(imageFile.readAsBytesSync());
      pdf.addPage(pw.Page(
        pageFormat: format,
        build: (pw.Context context) {
          if (_fitMode == 'Original') {
            return pw.Center(child: pw.Image(image));
          } else if (_fitMode == 'Cover') {
            return pw.FullPage(ignoreMargins: true, child: pw.Image(image, fit: pw.BoxFit.cover));
          } else {
            return pw.Center(child: pw.Image(image, fit: pw.BoxFit.contain));
          }
        },
      ));
    }

    try {
      final output = await getTemporaryDirectory();
      final file = File("${output.path}/infinity_kit_${DateTime.now().millisecondsSinceEpoch}.pdf");
      await file.writeAsBytes(await pdf.save());

      setState(() => _isGenerating = false);
      
      if (mounted) {
        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(file.path)],
            text: 'Generated with Infinity Kit ⚡',
          ),
        );
      }
    } catch (e) {
      setState(() => _isGenerating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📄 Image to PDF')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: _pickImages, 
              icon: const Icon(Icons.add_photo_alternate), 
              label: const Text('Add Images'),
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
            ),
            const SizedBox(height: 20),
            if (_images.isNotEmpty) ...[
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _pageSize,
                      decoration: const InputDecoration(labelText: 'Page Size', border: OutlineInputBorder()),
                      items: _pageSizes.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (val) => setState(() => _pageSize = val!),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _fitMode,
                      decoration: const InputDecoration(labelText: 'Fit Mode', border: OutlineInputBorder()),
                      items: _fitModes.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (val) => setState(() => _fitMode = val!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
            Expanded(
              child: _images.isEmpty
                  ? const Center(child: Text('No images selected', style: TextStyle(color: AppTheme.subtitleColor)))
                  : ListView.builder(
                      itemCount: _images.length,
                      itemBuilder: (context, index) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.file(_images[index], width: 50, height: 50, fit: BoxFit.cover),
                          ),
                          title: Text('Image ${index + 1}', style: const TextStyle(fontSize: 14)),
                          subtitle: Text(_images[index].path.split('/').last, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                          trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.redAccent), onPressed: () => setState(() => _images.removeAt(index))),
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _images.isEmpty || _isGenerating ? null : _generatePdf,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: _isGenerating 
                ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
                : const Text('Convert & Share PDF', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
