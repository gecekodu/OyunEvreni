import 'dart:convert';

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
    final normalizedPath = assetPath.startsWith('/')
        ? assetPath.substring(1)
        : assetPath;

    try {
      await controller.loadFlutterAsset(normalizedPath);
    } catch (e) {
      debugPrint('Asset loading error (loadFlutterAsset): $e');
      try {
        final html = await rootBundle.loadString(normalizedPath);
        final htmlData = Uri.dataFromString(
          html,
          mimeType: 'text/html',
          encoding: utf8,
        );
        await controller.loadRequest(htmlData);
      } catch (e2) {
        debugPrint('Asset loading error (loadString): $e2');
        final errorHtml = '''
          <html>
            <head>
              <style>
                body { font-family: Arial; padding: 20px; text-align: center; }
                .error { color: red; }
                .details { color: #666; margin-top: 20px; }
              </style>
            </head>
            <body>
              <h1 class="error">⚠️ Oyun Yüklenemedi</h1>
              <p class="details">Path: $assetPath</p>
              <p class="details">Hata: $e2</p>
            </body>
          </html>
        ''';
        await controller.loadHtmlString(errorHtml);
      }
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
