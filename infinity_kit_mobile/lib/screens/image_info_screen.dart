import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class ImageInfoScreen extends StatefulWidget {
  const ImageInfoScreen({super.key});

  @override
  State<ImageInfoScreen> createState() => _ImageInfoScreenState();
}

class _ImageInfoScreenState extends State<ImageInfoScreen> {
  File? _image;
  Map<String, String> _info = {};

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.pickFiles(type: FileType.image);
    if (result != null) {
      File file = File(result.files.single.path!);
      final bytes = await file.readAsBytes();
      final image = await decodeImageFromList(bytes);

      setState(() {
        _image = file;
        _info = {
          'Filename': result.files.single.name,
          'Size': '${(file.lengthSync() / 1024).toStringAsFixed(2)} KB',
          'Resolution': '${image.width} x ${image.height}',
          'Path': file.path,
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Image Info')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            ElevatedButton.icon(onPressed: _pickImage, icon: const Icon(Icons.image_search), label: const Text('Select Image')),
            const SizedBox(height: 30),
            if (_image != null) ...[
              ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.file(_image!, height: 200, fit: BoxFit.cover)),
              const SizedBox(height: 30),
              Expanded(
                child: ListView(
                  children: _info.entries.map((e) => Card(
                    child: ListTile(
                      title: Text(e.key, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(e.value),
                    ),
                  )).toList(),
                ),
              ),
            ] else
              const Expanded(child: Center(child: Text('Select an image to view information'))),
          ],
        ),
      ),
    );
  }
}
