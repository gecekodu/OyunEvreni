import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/services.dart';

class WebViewPage extends StatefulWidget {
  final String? htmlPath;
  final String? htmlContent;
  final String gameTitle;

  const WebViewPage({
    super.key,
    this.htmlPath,
    this.htmlContent,
    required this.gameTitle,
  }) : assert(htmlPath != null || htmlContent != null);

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewController controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() => isLoading = true);
          },
          onPageFinished: (String url) {
            setState(() => isLoading = false);
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView error: ${error.description}');
          },
        ),
      );

    if (widget.htmlContent != null && widget.htmlContent!.isNotEmpty) {
      controller.loadHtmlString(widget.htmlContent!);
    } else if (widget.htmlPath != null && widget.htmlPath!.isNotEmpty) {
      _loadAssetHtml(widget.htmlPath!);
    }
  }

  Future<void> _loadAssetHtml(String assetPath) async {
    try {
      String html = await rootBundle.loadString(assetPath);
      final dir = assetPath.substring(0, assetPath.lastIndexOf('/'));

      // CSS
      html = html.replaceAllMapped(
        RegExp(r'href="([^"]+\.css)"'),
        (Match m) => 'href="/$dir/${m.group(1)}"',
      );

      // JS
      html = html.replaceAllMapped(
        RegExp(r'src="([^"]+\.js)"'),
        (Match m) => 'src="/$dir/${m.group(1)}"',
      );

      // Images
      html = html.replaceAllMapped(
        RegExp(r'src="((?!/).+?\.(?:png|jpg|jpeg|gif|svg|webp))"'),
        (Match m) => 'src="/$dir/${m.group(1)}"',
      );

      controller.loadHtmlString(html);
    } catch (e) {
      debugPrint('Asset error: $e');
      controller.loadHtmlString('<html><body>Error: $e</body></html>');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.gameTitle),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.reload(),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: controller),
          if (isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
