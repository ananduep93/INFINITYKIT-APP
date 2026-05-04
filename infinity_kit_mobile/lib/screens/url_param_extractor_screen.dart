import 'package:flutter/material.dart';

class UrlParamExtractorScreen extends StatefulWidget {
  const UrlParamExtractorScreen({super.key});

  @override
  State<UrlParamExtractorScreen> createState() => _UrlParamExtractorScreenState();
}

class _UrlParamExtractorScreenState extends State<UrlParamExtractorScreen> {
  final _controller = TextEditingController();
  Map<String, String> _params = {};

  void _extract() {
    try {
      final uri = Uri.parse(_controller.text.trim());
      setState(() => _params = uri.queryParameters);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid URL')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('URL Parameter Extractor')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(labelText: 'Enter Full URL', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _extract, child: const Text('Extract Parameters')),
            const SizedBox(height: 30),
            if (_params.isNotEmpty)
              Expanded(
                child: ListView(
                  children: _params.entries.map((e) => Card(
                    child: ListTile(
                      title: Text(e.key, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(e.value),
                    ),
                  )).toList(),
                ),
              )
            else
              const Center(child: Text('No parameters found or URL not parsed.')),
          ],
        ),
      ),
    );
  }
}
