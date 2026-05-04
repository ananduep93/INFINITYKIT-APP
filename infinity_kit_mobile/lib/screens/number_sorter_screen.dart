import 'package:flutter/material.dart';

class NumberSorterScreen extends StatefulWidget {
  const NumberSorterScreen({super.key});

  @override
  State<NumberSorterScreen> createState() => _NumberSorterScreenState();
}

class _NumberSorterScreenState extends State<NumberSorterScreen> {
  final _controller = TextEditingController();
  List<double> _sortedList = [];

  void _sort(bool ascending) {
    List<double> numbers = _controller.text.split(',').map((e) => double.tryParse(e.trim()) ?? 0).toList();
    if (numbers.isNotEmpty) {
      numbers.sort();
      if (!ascending) numbers = numbers.reversed.toList();
      setState(() => _sortedList = numbers);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Number Sorter')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Enter numbers separated by comma', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: ElevatedButton(onPressed: () => _sort(true), child: const Text('Sort Low to High'))),
                const SizedBox(width: 10),
                Expanded(child: ElevatedButton(onPressed: () => _sort(false), child: const Text('Sort High to Low'))),
              ],
            ),
            const SizedBox(height: 30),
            Expanded(
              child: ListView.builder(
                itemCount: _sortedList.length,
                itemBuilder: (context, index) => ListTile(
                  leading: CircleAvatar(child: Text('${index + 1}')),
                  title: Text(_sortedList[index].toString()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
