import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/theme.dart';

class UsernameGeneratorScreen extends StatefulWidget {
  const UsernameGeneratorScreen({super.key});

  @override
  State<UsernameGeneratorScreen> createState() => _UsernameGeneratorScreenState();
}

class _UsernameGeneratorScreenState extends State<UsernameGeneratorScreen> {
  final TextEditingController _keywordController = TextEditingController();
  List<String> _recommendations = [];
  int _displayStartIndex = 0;

  final List<String> _prefixes = ['the', 'real', 'mr', 'ms', 'dr', 'pro', 'super', 'epic', 'itz', 'its', 'iam'];
  final List<String> _suffixes = ['_x', '007', 'pro', 'dev', '_', '123', 'official', 'gaming', 'vlogs', 'yt', 'hub'];

  void _generateUsernames() {
    final keyword = _keywordController.text.trim();
    if (keyword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a name or keyword')));
      return;
    }

    final random = Random();
    Set<String> resultSet = {};
    
    resultSet.add(keyword);
    resultSet.add('${keyword}_${DateTime.now().year}');

    while (resultSet.length < 100) {
      int type = random.nextInt(4);
      String name = '';
      if (type == 0) {
        name = '$keyword${random.nextInt(9999)}';
      } else if (type == 1) {
        name = '${_prefixes[random.nextInt(_prefixes.length)]}_$keyword';
      } else if (type == 2) {
        name = '$keyword${_suffixes[random.nextInt(_suffixes.length)]}';
      } else {
        name = '${_prefixes[random.nextInt(_prefixes.length)]}$keyword${random.nextInt(99)}';
      }
      resultSet.add(name);
    }

    setState(() {
      _recommendations = resultSet.toList();
      _displayStartIndex = 0;
    });
  }

  void _showNext() {
    setState(() {
      _displayStartIndex = (_displayStartIndex + 10) % _recommendations.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('👤 Username Generator')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: _keywordController,
              decoration: const InputDecoration(
                labelText: 'Name / Keyword',
                hintText: 'e.g. john',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _generateUsernames(),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _generateUsernames,
                    style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                    child: const Text('Generate Recommendations'),
                  ),
                ),
                if (_recommendations.isNotEmpty) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _showNext,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green[50], foregroundColor: Colors.green, minimumSize: const Size(double.infinity, 50)),
                      child: const Icon(Icons.refresh),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 25),
            if (_recommendations.isNotEmpty) ...[
              Text(
                'Showing recommendations ${_displayStartIndex + 1} to ${_displayStartIndex + 10} of 100',
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.subtitleColor),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    final username = _recommendations[_displayStartIndex + index];
                    return Card(
                      child: ListTile(
                        title: Text(username, style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                        trailing: IconButton(
                          icon: const Icon(Icons.copy, size: 20),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: username));
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Copied: $username')));
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ] else
              const Expanded(child: Center(child: Text('Enter a keyword to generate usernames', style: TextStyle(color: AppTheme.subtitleColor)))),
          ],
        ),
      ),
    );
  }
}
