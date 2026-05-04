import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../models/tool_models.dart';
import '../utils/theme.dart';

class ToolScreen extends StatefulWidget {
  final Tool tool;

  const ToolScreen({super.key, required this.tool});

  @override
  State<ToolScreen> createState() => _ToolScreenState();
}

class _ToolScreenState extends State<ToolScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppTheme.backgroundColor)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            // Inject CSS to hide website headers/footers if necessary
            _controller.runJavaScript("""
              const style = document.createElement('style');
              style.innerHTML = 'header, footer, nav { display: none !important; }';
              document.head.appendChild(style);
            """);
          },
        ),
      )
      ..loadRequest(Uri.parse('https://infinity-kit-79c58.web.app/tools/${widget.tool.id}.html'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tool.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller.reload(),
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Share tool link
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            ),
        ],
      ),
    );
  }
}
