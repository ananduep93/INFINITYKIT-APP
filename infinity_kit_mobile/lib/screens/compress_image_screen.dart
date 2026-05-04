import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../utils/theme.dart';

class CompressImageScreen extends StatefulWidget {
  const CompressImageScreen({super.key});

  @override
  State<CompressImageScreen> createState() => _CompressImageScreenState();
}

class _CompressImageScreenState extends State<CompressImageScreen> {
  File? _selectedImage;
  File? _compressedImage;
  bool _isCompressing = false;
  double _quality = 50;

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.pickFiles(type: FileType.image);
    if (result != null) {
      setState(() {
        _selectedImage = File(result.files.single.path!);
        _compressedImage = null;
      });
    }
  }

  Future<void> _compress() async {
    if (_selectedImage == null) return;
    setState(() => _isCompressing = true);

    try {
      final tempDir = await getTemporaryDirectory();
      final targetPath = "${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg";

      final result = await FlutterImageCompress.compressAndGetFile(
        _selectedImage!.absolute.path,
        targetPath,
        quality: _quality.toInt(),
      );

      if (result != null) {
        setState(() {
          _compressedImage = File(result.path);
          _isCompressing = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Image Compressed!')));
        }
      }
    } catch (e) {
      setState(() => _isCompressing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🗜️ Compress Image')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            if (_selectedImage != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.file(_selectedImage!, height: 250, width: double.infinity, fit: BoxFit.cover),
              ),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
                child: Text('Original Size: ${(_selectedImage!.lengthSync() / 1024).toStringAsFixed(2)} KB', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 30),
              const Text('Compression Quality', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Slider(
                value: _quality,
                min: 1,
                max: 100,
                divisions: 99,
                label: '${_quality.toInt()}%',
                activeColor: AppTheme.primaryColor,
                onChanged: (val) => setState(() => _quality = val),
              ),
              const Text('Lower quality = Smaller file size', style: TextStyle(color: AppTheme.subtitleColor, fontSize: 12)),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _isCompressing ? null : _compress,
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 55), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                icon: const Icon(Icons.compress),
                label: _isCompressing ? const CircularProgressIndicator(color: Colors.white) : const Text('Compress Now', style: TextStyle(fontSize: 18)),
              ),
            ] else
              Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey[200]!)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image_outlined, size: 80, color: Colors.grey[300]),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(onPressed: _pickImage, icon: const Icon(Icons.add_photo_alternate), label: const Text('Pick Image')),
                  ],
                ),
              ),
            const SizedBox(height: 30),
            if (_compressedImage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green[100]!),
                ),
                child: Column(
                  children: [
                    const Text('Compressed Result', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                    const SizedBox(height: 10),
                    Text('New Size: ${(_compressedImage!.lengthSync() / 1024).toStringAsFixed(2)} KB', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () => SharePlus.instance.share(
                        ShareParams(
                          files: [XFile(_compressedImage!.path)],
                          text: 'Compressed with Infinity Kit ⚡',
                        ),
                      ),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                      icon: const Icon(Icons.share),
                      label: const Text('Share Compressed Image'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
