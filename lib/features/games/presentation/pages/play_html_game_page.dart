import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../core/services/webview_service.dart';

class PlayHtmlGamePage extends StatefulWidget {
  final Map<String, dynamic> gameJson;
  const PlayHtmlGamePage({super.key, required this.gameJson});

  @override
  State<PlayHtmlGamePage> createState() => _PlayHtmlGamePageState();
}

class _PlayHtmlGamePageState extends State<PlayHtmlGamePage> {
  late WebViewService _webViewService;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _webViewService = WebViewService();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HTML Oyun')), 
      body: FutureBuilder<String>(
        future: loadGameEngine(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final htmlContent = snapshot.data!;
          final controller = _webViewService.initializeWebView(
            htmlPath: htmlContent,
            onGameResult: (result) {
              // Oyun sonucu geldiğinde yapılacaklar
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Skor: ${result.score}')),
              );
            },
          );
          // Oyun JSON'unu gönder
          _webViewService.startGame(widget.gameJson);
          return WebViewWidget(controller: controller);
        },
      ),
    );
  }

  @override
  void dispose() {
    _webViewService.dispose();
    super.dispose();
  }
}
