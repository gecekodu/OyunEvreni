import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PlayHtmlGamePage extends StatefulWidget {
  final Map<String, dynamic>? gameJson;
  const PlayHtmlGamePage({super.key, this.gameJson});

  @override
  State<PlayHtmlGamePage> createState() => _PlayHtmlGamePageState();
}

class _PlayHtmlGamePageState extends State<PlayHtmlGamePage> {
  late WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
          },
        ),
      )
      ..loadHtmlString(_generateBasicHtml());
  }

  String _generateBasicHtml() {
    return '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Oyun</title>
    <style>
        body { font-family: Arial; text-align: center; padding: 20px; background: #f0f0f0; }
        .container { background: white; padding: 40px; border-radius: 10px; }
        h1 { color: #667eea; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🎮 Oyun Başlıyor...</h1>
    </div>
</body>
</html>
''';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🎮 Oyun Oyna')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : WebViewWidget(controller: _controller),
    );
  }
}
