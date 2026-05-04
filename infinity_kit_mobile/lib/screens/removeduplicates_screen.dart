import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/theme.dart';

class RemoveDuplicatesScreen extends StatefulWidget {
  const RemoveDuplicatesScreen({super.key});

  @override
  State<RemoveDuplicatesScreen> createState() => _RemoveDuplicatesScreenState();
}

class _RemoveDuplicatesScreenState extends State<RemoveDuplicatesScreen> {
  final TextEditingController _controller = TextEditingController();

  void _removeDuplicates() {
    String text = _controller.text;
    if (text.isEmpty) return;

    List<String> lines = text.split('\n');
    List<String> uniqueLines = lines.toSet().toList();

    setState(() {
      _controller.text = uniqueLines.join('\n');
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Removed ${lines.length - uniqueLines.length} duplicate lines')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('✨ Remove Duplicates')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              'Enter a list of items (one per line) to remove duplicates.',
              style: TextStyle(color: AppTheme.subtitleColor),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: TextField(
                controller: _controller,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  hintText: 'Item 1\nItem 2\nItem 1...',
                  border: const OutlineInputBorder(),
                  suffixIcon: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: _controller.text));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Copied to clipboard!')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _removeDuplicates,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text('Remove Duplicates', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => _controller.clear(),
              child: const Text('Clear All', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }
}
