import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MetaTagViewerScreen extends StatefulWidget {
  const MetaTagViewerScreen({super.key});

  @override
  State<MetaTagViewerScreen> createState() => _MetaTagViewerScreenState();
}

class _MetaTagViewerScreenState extends State<MetaTagViewerScreen> {
  final _controller = TextEditingController();
  List<Map<String, String>> _tags = [];
  bool _isLoading = false;

  Future<void> _fetchTags() async {
    String url = _controller.text.trim();
    if (!url.startsWith('http')) url = 'https://$url';

    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse(url));
      final body = response.body;

      final regExp = RegExp(r'<meta\s+([^>]*)\/?>', caseSensitive: false);
      final matches = regExp.allMatches(body);

      List<Map<String, String>> extracted = [];
      for (var match in matches) {
        String content = match.group(1) ?? '';
        extracted.add({'tag': content});
      }

      setState(() {
        _tags = extracted;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to fetch meta tags')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meta Tag Viewer')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(labelText: 'Enter Website URL', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _fetchTags,
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              child: _isLoading ? const CircularProgressIndicator() : const Text('Fetch Meta Tags'),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: _tags.isEmpty
                  ? const Center(child: Text('No tags found or fetch failed.'))
                  : ListView.builder(
                      itemCount: _tags.length,
                      itemBuilder: (context, index) => Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(_tags[index]['tag']!, style: const TextStyle(fontSize: 12)),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
