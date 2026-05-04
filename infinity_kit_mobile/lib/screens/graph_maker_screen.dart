import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class GraphMakerScreen extends StatefulWidget {
  const GraphMakerScreen({super.key});

  @override
  State<GraphMakerScreen> createState() => _GraphMakerScreenState();
}

class _GraphMakerScreenState extends State<GraphMakerScreen> {

  final _valueController = TextEditingController();
  final List<BarChartGroupData> _barGroups = [];
  int _counter = 0;

  void _addData() {
    double? val = double.tryParse(_valueController.text);
    if (val != null) {
      setState(() {
        _barGroups.add(
          BarChartGroupData(
            x: _counter++,
            barRods: [BarChartRodData(toY: val, color: Colors.blue, width: 15)],
          ),
        );
        _valueController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Graph Maker')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: TextField(controller: _valueController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Enter Value', border: OutlineInputBorder()))),
                const SizedBox(width: 10),
                ElevatedButton(onPressed: _addData, child: const Text('Add Data')),
              ],
            ),
            const SizedBox(height: 30),
            Expanded(
              child: _barGroups.isEmpty 
                ? const Center(child: Text('Add data to see the graph'))
                : BarChart(
                    BarChartData(
                      barGroups: _barGroups,
                      borderData: FlBorderData(show: false),
                      titlesData: const FlTitlesData(show: true),
                    ),
                  ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: () => setState(() => _barGroups.clear()), style: ElevatedButton.styleFrom(backgroundColor: Colors.red[100]), child: const Text('Clear Graph', style: TextStyle(color: Colors.red))),
          ],
        ),
      ),
    );
  }
}
