import 'package:flutter/material.dart';

class PdfUtilityScreen extends StatefulWidget {
  final String title;
  const PdfUtilityScreen({super.key, required this.title});

  @override
  State<PdfUtilityScreen> createState() => _PdfUtilityScreenState();
}

class _PdfUtilityScreenState extends State<PdfUtilityScreen> {
  bool _isProcessing = false;
  String _message = 'Select files to begin';

  void _startProcess() {
    setState(() {
      _isProcessing = true;
      _message = 'Processing your PDF...';
    });
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _isProcessing = false;
        _message = 'Simulation Complete: In a live app, your PDF would be modified here.';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.picture_as_pdf, size: 100, color: Colors.red[400]),
              const SizedBox(height: 30),
              Text(_message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 50),
              if (!_isProcessing)
                ElevatedButton.icon(
                  onPressed: _startProcess,
                  icon: const Icon(Icons.file_open),
                  label: Text('Select & \${widget.title}'),
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 55)),
                )
              else
                const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
