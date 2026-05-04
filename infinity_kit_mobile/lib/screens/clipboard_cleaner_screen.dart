import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/theme.dart';

class ClipboardCleanerScreen extends StatefulWidget {
  const ClipboardCleanerScreen({super.key});

  @override
  State<ClipboardCleanerScreen> createState() => _ClipboardCleanerScreenState();
}

class _ClipboardCleanerScreenState extends State<ClipboardCleanerScreen> {
  String _status = 'Ready to clean';
  bool _isCleaning = false;

  Future<void> _cleanClipboard() async {
    setState(() => _isCleaning = true);
    
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      if (data != null && data.text != null) {
        // Clean logic: Trim and remove extra whitespace/newlines
        final cleanedText = data.text!.trim().replaceAll(RegExp(r'\n\s*\n'), '\n\n');
        await Clipboard.setData(ClipboardData(text: cleanedText));
        
        setState(() {
          _status = 'Clipboard cleaned and reformatted!';
        });
      } else {
        setState(() {
          _status = 'Clipboard is empty or does not contain text.';
        });
      }
    } catch (e) {
      setState(() => _status = 'Error cleaning clipboard: $e');
    } finally {
      setState(() => _isCleaning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clipboard Cleaner')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cleaning_services_rounded, size: 80, color: AppTheme.primaryColor.withValues(alpha: 0.2)),
              const SizedBox(height: 30),
              const Text(
                'Clean & Format Clipboard',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'This tool removes trailing spaces, extra newlines, and hidden formatting from your copied text.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.subtitleColor),
              ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  _status,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: _isCleaning ? null : _cleanClipboard,
                icon: _isCleaning 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                    : const Icon(Icons.auto_fix_high),
                label: const Text('Clean Clipboard Now'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
