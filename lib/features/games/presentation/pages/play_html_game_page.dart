import 'package:flutter/foundation.dart';
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
  String? htmlContent;

  @override
  void initState() {
    super.initState();
    htmlContent = widget.gameJson?['html'] ?? _generateBasicHtml();
    if (!kIsWeb) {
      _initializeWebView();
    }
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
      ..loadHtmlString(htmlContent ?? _generateBasicHtml());
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
      body: kIsWeb
          ? Center(
              child: SizedBox(
                width: 800,
                height: 600,
                child: htmlContent != null
                    ? HtmlGameIframe(htmlContent: htmlContent!)
                    : const Text('Oyun içeriği bulunamadı.'),
              ),
            )
          : _isLoading
              ? const Center(child: CircularProgressIndicator())
              : WebViewWidget(controller: _controller),
    );
  }
}

/// Web platformunda HTML içeriği iframe ile gösteren widget
class HtmlGameIframe extends StatelessWidget {
  final String htmlContent;
  const HtmlGameIframe({super.key, required this.htmlContent});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
      child: Center(
        child: Column(
          children: [
            Expanded(
              child: IgnorePointer(
                child: SizedBox(
                  width: double.infinity,
                  child: SelectableText(
                    'Oyun HTML içeriği aşağıda. Kopyalayıp yeni bir sekmede çalıştırabilirsiniz:',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: SingleChildScrollView(
                child: SelectableText(
                  htmlContent,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
