import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../domain/entities/game_models.dart';

class PlayGameSimple extends StatefulWidget {
  final Game game;
  const PlayGameSimple({super.key, required this.game});

  @override
  State<PlayGameSimple> createState() => _PlayGameSimpleState();
}

class _PlayGameSimpleState extends State<PlayGameSimple> {
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
      ..loadHtmlString(widget.game.htmlContent);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.game.title),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : WebViewWidget(controller: _controller),
    );
  }
}
