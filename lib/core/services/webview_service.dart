// 🌐 WebView Service - HTML Oyunlar için Flutter ↔ HTML Bridge

import 'package:webview_flutter/webview_flutter.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';

class GameResult {
  final int score;
  final bool completed;
  final int timeSpent; // saniye cinsinden
  final bool success;

  GameResult({
    required this.score,
    required this.completed,
    required this.timeSpent,
    required this.success,
  });

  factory GameResult.fromJson(Map<String, dynamic> json) {
    return GameResult(
      score: json['score'] as int? ?? 0,
      completed: json['completed'] as bool? ?? false,
      timeSpent: json['time'] as int? ?? 0,
      success: json['success'] as bool? ?? false,
    );
  }
}

class WebViewService {
  late WebViewController _controller;
  final Completer<void> _controllerCompleter = Completer<void>();
  late Future<GameResult?> _gameResultFuture;
  late Completer<GameResult?> _gameResultCompleter;

  WebViewController get controller => _controller;

  /// WebView Controller'ı başlat
  WebViewController initializeWebView({
    required String htmlPath,
    required Function(GameResult) onGameResult,
  }) {
    _gameResultCompleter = Completer<GameResult?>();
    _gameResultFuture = _gameResultCompleter.future;

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            print('📱 Sayfa yüklenmeye başladı: $url');
          },
          onPageFinished: (String url) {
            print('✅ Sayfa tamamen yüklendi: $url');
            _controllerCompleter.complete();
          },
          onWebResourceError: (WebResourceError error) {
            print('❌ WebView Error: ${error.description}');
          },
        ),
      )
      ..addJavaScriptChannel(
        'flutter_inappwebview',
        onMessageReceived: (JavaScriptMessage message) {
          _handleJavaScriptMessage(message.message, onGameResult);
        },
      )
      ..loadRequest(Uri.dataFromString(htmlPath, mimeType: 'text/html'));

    return _controller;
  }

  /// HTML'e oyun JSON'u gönder ve başlat
  Future<void> startGame(Map<String, dynamic> gameJson) async {
    await _controllerCompleter.future;
    final jsonString = jsonEncode(gameJson);
    final jsCode = '''
      gameConfig = $jsonString;
      initializeGame();
      startGame();
    ''';
    await _controller.evaluateJavascript(source: jsCode);
  }

  /// Oyun sonucunu dinle
  Future<GameResult?> getGameResult() async {
    return await _gameResultFuture;
  }

  /// JavaScript mesajlarını işle
  void _handleJavaScriptMessage(
    String message,
    Function(GameResult) onGameResult,
  ) {
    try {
      final data = jsonDecode(message);

      if (data is Map<String, dynamic>) {
        if (data.containsKey('score')) {
          // Oyun sonucu
          final result = GameResult.fromJson(data);
          if (!_gameResultCompleter.isCompleted) {
            _gameResultCompleter.complete(result);
          }
          onGameResult(result);
        }
      }
    } catch (e) {
      print('❌ JavaScript mesajı işlenirken hata: $e');
    }
  }

  /// HTML oyundan config iste
  Future<Map<String, dynamic>> getGameConfig() async {
    await _controllerCompleter.future;
    final result = await _controller.evaluateJavascript(
      source: 'JSON.stringify(gameConfig)',
    );
    if (result != null) {
      return jsonDecode(result);
    }
    return {};
  }

  /// Oyunu sıfırla
  Future<void> resetGame() async {
    await _controllerCompleter.future;
    await _controller.evaluateJavascript(source: 'resetGame();');
    _gameResultCompleter = Completer<GameResult?>();
    _gameResultFuture = _gameResultCompleter.future;
  }

  /// WebView'u temizle
  void dispose() {
    if (!_gameResultCompleter.isCompleted) {
      _gameResultCompleter.completeError('WebView disposed');
    }
  }
}

/// HTML oyun engine'ini asset'ten yükle
Future<String> loadGameEngine() async {
  return await rootBundle.loadString('assets/html_games/game_engine/game_engine.html');
}
