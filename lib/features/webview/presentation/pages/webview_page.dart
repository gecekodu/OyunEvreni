import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../games/data/services/leaderboard_service.dart';

class WebViewPage extends StatefulWidget {
  final String? htmlPath;
  final String? htmlContent;
  final String gameTitle;
  final String? gameId; // Oyun tanımlayıcı

  const WebViewPage({
    super.key,
    this.htmlPath,
    this.htmlContent,
    required this.gameTitle,
    this.gameId,
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
      )
      ..addJavaScriptChannel('GameScoreListener',
        onMessageReceived: (JavaScriptMessage message) {
          _handleGameScore(message.message);
        },
      );

    if (widget.htmlContent != null && widget.htmlContent!.isNotEmpty) {
      controller.loadHtmlString(widget.htmlContent!);
    } else if (widget.htmlPath != null && widget.htmlPath!.isNotEmpty) {
      _loadAssetHtml(widget.htmlPath!);
    }
  }

  Future<void> _handleGameScore(String jsonData) async {
    try {
      final data = jsonDecode(jsonData);
      final gameName = data['gameName'] as String?;
      final score = data['score'] is int 
          ? (data['score'] as int).toDouble() 
          : (data['score'] as num).toDouble();
      final rank = data['rank'] as String?;

      debugPrint('🎮 Oyun Puanı Alındı: $gameName = $score');

      // Leaderboard servisine puan kaydet
      final leaderboardService = GetIt.instance<LeaderboardService>();
      
      // Format: "oyun-adi-001" 
      final gameId = widget.gameId ?? gameName ?? 'unknown-game';
      
      // Firebase Auth'dan gerçek kullanıcı al
      final currentUser = FirebaseAuth.instance.currentUser;
      final userId = currentUser?.uid ?? 'guest-${DateTime.now().millisecondsSinceEpoch}';
      final userName = currentUser?.displayName ?? 'Anonim Oyuncu';
      final userAvatar = currentUser?.photoURL ?? 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(userName)}';
      
      await leaderboardService.saveGameScore(
        gameId: gameId,
        userId: userId,
        userName: userName,
        score: score.toInt(),
        userAvatar: userAvatar,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Puan kaydedildi: ${score.toInt()} | Kullanıcı: $userName'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Skor işleme hatası: $e');
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
