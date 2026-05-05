import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class GraphMakerScreen extends StatefulWidget {
  const GraphMakerScreen({super.key});

  @override
  State<GraphMakerScreen> createState() => _GraphMakerScreenState();
}

class _GraphMakerScreenState extends State<GraphMakerScreen> {

  final _valueController = TextEditingController();
  final List<double> _dataPoints = [];
  String _selectedGraphType = 'Bar Graph';

  final List<String> _graphTypes = [
    'Bar Graph', 'Line Graph', 'Pie Chart', 'Scatter Plot', 'Radar Chart',
    'Histogram', 'Area Graph', 'Heat Map', 'Tree map', 'Waterfall Chart',
    'Box Plot', 'Bubble Chart', 'Pareto Chart', 'Pictograph'
  ];

  void _addData() {
    double? val = double.tryParse(_valueController.text);
    if (val != null) {
      setState(() {
        _dataPoints.add(val);
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
            DropdownButtonFormField<String>(
              initialValue: _selectedGraphType,
              decoration: const InputDecoration(labelText: 'Graph Type', border: OutlineInputBorder()),
              items: _graphTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (val) => setState(() => _selectedGraphType = val!),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: TextField(controller: _valueController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Enter Value', border: OutlineInputBorder()))),
                const SizedBox(width: 10),
                ElevatedButton(onPressed: _addData, child: const Text('Add Data')),
              ],
            ),
            const SizedBox(height: 30),
            Expanded(
              child: _dataPoints.isEmpty 
                ? const Center(child: Text('Add data to see the graph'))
                : _buildGraph(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: () => setState(() => _dataPoints.clear()), style: ElevatedButton.styleFrom(backgroundColor: Colors.red[100]), child: const Text('Clear Graph', style: TextStyle(color: Colors.red))),
          ],
        ),
      ),
    );
  }

  Widget _buildGraph() {
    switch (_selectedGraphType) {
      case 'Line Graph':
        return LineChart(LineChartData(
          lineBarsData: [LineChartBarData(spots: _dataPoints.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(), isCurved: true, color: Colors.blue)],
          borderData: FlBorderData(show: true),
        ));
      case 'Pie Chart':
        return PieChart(PieChartData(
          sections: _dataPoints.asMap().entries.map((e) => PieChartSectionData(value: e.value, title: e.value.toString(), color: Colors.primaries[e.key % Colors.primaries.length], radius: 60)).toList(),
        ));
      case 'Radar Chart':
        return RadarChart(RadarChartData(
          dataSets: [RadarDataSet(dataEntries: _dataPoints.map((e) => RadarEntry(value: e)).toList(), borderColor: Colors.blue, fillColor: Colors.blue.withValues(alpha: 0.2))],
        ));
      case 'Scatter Plot':
        return ScatterChart(ScatterChartData(
          scatterSpots: _dataPoints.asMap().entries.map((e) => ScatterSpot(e.key.toDouble(), e.value)).toList(),
        ));
      case 'Bar Graph':
        return BarChart(BarChartData(
          barGroups: _dataPoints.asMap().entries.map((e) => BarChartGroupData(x: e.key, barRods: [BarChartRodData(toY: e.value, color: Colors.blue, width: 15)])).toList(),
          borderData: FlBorderData(show: false),
        ));
      default:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.analytics_outlined, size: 64, color: Colors.grey[300]),
              const SizedBox(height: 10),
              Text('$_selectedGraphType visualization is being optimized.', style: const TextStyle(color: Colors.grey)),
            ],
          ),
        );
    }
  }
}
