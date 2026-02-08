import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';
import '../../domain/entities/game_models.dart';
import '../../data/services/score_service.dart';
import 'leaderboard_page.dart';
import '../../../../main.dart';

class PlayGameSimple extends StatefulWidget {
  final Game game;
  const PlayGameSimple({super.key, required this.game});

  @override
  State<PlayGameSimple> createState() => _PlayGameSimpleState();
}

class _PlayGameSimpleState extends State<PlayGameSimple> {
  late WebViewController _controller;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _validateAndInitialize();
  }

  void _validateAndInitialize() {
    // HTML içeriğini kontrol et ve gerekirse fallback ekle
    print('DEBUG: Game ID: ${widget.game.id}');
    print('DEBUG: Game Title: ${widget.game.title}');
    print('DEBUG: Game Type: ${widget.game.gameType}');
    print('DEBUG: HTML Content Length: ${widget.game.htmlContent.length}');
    
    if (widget.game.htmlContent.isEmpty) {
      // Fallback: Test oyun HTML'i
      final fallbackHtml = _generateFallbackHtml();
      print('⚠️ HTML içerik boş, fallback yükleniyor');
      if (mounted) {
        _initializeWebViewWithHtml(fallbackHtml);
      }
      return;
    }

    print('✅ HTML yükleniyor: ${widget.game.htmlContent.length} karakter');
    if (mounted) {
      _initializeWebViewWithHtml(widget.game.htmlContent);
    }
  }

  String _generateFallbackHtml() {
    return '''<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${widget.game.title}</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body {
      font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      min-height: 100vh;
      display: flex;
      justify-content: center;
      align-items: center;
      padding: 20px;
    }
    .container {
      background: white;
      border-radius: 20px;
      padding: 40px;
      max-width: 400px;
      width: 100%;
      text-align: center;
      box-shadow: 0 20px 60px rgba(0,0,0,0.3);
    }
    h1 { color: #667eea; margin-bottom: 20px; }
    p { color: #666; line-height: 1.8; font-size: 16px; margin: 15px 0; }
    .emoji { font-size: 60px; margin-bottom: 20px; }
    button {
      background: linear-gradient(135deg, #667eea, #764ba2);
      color: white;
      border: none;
      padding: 15px 30px;
      border-radius: 10px;
      cursor: pointer;
      font-size: 16px;
      font-weight: bold;
      margin-top: 20px;
      transition: transform 0.2s;
    }
    button:active { transform: scale(0.95); }
  </style>
</head>
<body>
  <div class="container">
    <div class="emoji">🎮</div>
    <h1>${widget.game.title}</h1>
    <p>${widget.game.description}</p>
    <p style="color: #999; font-size: 14px;">Oyun motoru hazırlanıyor...</p>
    <button onclick="sendScore()">Test Puanı Gönder</button>
  </div>
  <script>
    function sendScore() {
      try {
        GameChannel.postMessage('SCORE:5/10');
      } catch (e) {
        console.log('Error: ' + e);
      }
    }
  </script>
</body>
</html>''';
  }

  void _initializeWebViewWithHtml(String htmlContent) {
    try {
      // WebView initialization - GPU devre dışı moda alabilir
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(// Lighter background for Emulator rendering
            Colors.white)
        ..enableZoom(false)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String url) {
              print('🌐 Sayfa yükleniyor: $url [${DateTime.now().toString()}]');
              if (!_isLoading && mounted) {
                setState(() => _isLoading = true);
              }
              // ✅ Timeout ekle
              Future.delayed(const Duration(seconds: 15), () {
                if (_isLoading && mounted) {
                  setState(() {
                    _errorMessage = 'Yükleme zaman aşımına uğradı (15s)';
                    _isLoading = false;
                  });
                }
              });
            },
            onPageFinished: (String url) {
              print('✅ Sayfa yüklendi: $url [${DateTime.now().toString()}]');
              if (mounted) {
                setState(() => _isLoading = false);
                // Small delay to ensure rendering
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (mounted) {
                    _controller.runJavaScript('''
                      window.GameChannel = window.GameChannel || {
                        postMessage: function(msg) {
                          console.log('Game message: ' + msg);
                        }
                      };
                      console.log('✅ Game Bridge Ready');
                    ''');
                  }
                });
              }
            },
            onWebResourceError: (WebResourceError error) {
              print('⚠️ WebView Hatası: ${error.description} [Code: ${error.errorCode}]');
              if (mounted) {
                setState(() {
                  _errorMessage = 'Bağlantı hatası: ${error.description}';
                  _isLoading = false;
                });
              }
            },
          ),
        )
        ..addJavaScriptChannel(
          'GameChannel',
          onMessageReceived: (JavaScriptMessage message) {
            print('📨 Oyundan mesaj: ${message.message}');
            // Oyun skorunu veya sonuçları burada yakalayabilirsin
            if (message.message.startsWith('SCORE:')) {
              final score = message.message.replaceFirst('SCORE:', '');
              _showScore(score);
            }
          },
        );

      // URL Data loadRequest
      final htmlData = Uri.dataFromString(
        htmlContent,
        mimeType: 'text/html',
        encoding: Encoding.getByName('utf-8'),
      );

      print('📦 HTML verisi: ${htmlData.toString().substring(0, 100)}...');
      _controller.loadRequest(htmlData);
      
    } catch (e) {
      print('❌ WebView initialization error: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'WebView Hatası: $e\n\nTechnical: WebView may be unavailable on this emulator. Try physical device.';
          _isLoading = false;
        });
      }
    }
  }

  void _showScore(String score) async {
    // Skor formatı: "8/10" veya "80"
    final parts = score.split('/');
    final correctAnswers = int.tryParse(parts[0]) ?? 0;
    final totalQuestions = parts.length > 1
        ? (int.tryParse(parts[1]) ?? 10)
        : 10;
    final scorePoints = correctAnswers * 10;

    try {
      final scoreService = getIt<ScoreService>();
      await scoreService.saveScore(
        gameId: widget.game.id,
        userId: 'demo-user', // TODO: Gerçek user ID
        userName: 'Oyuncu', // TODO: Gerçek kullanıcı adı
        score: scorePoints,
        correctAnswers: correctAnswers,
        totalQuestions: totalQuestions,
        metadata: {'gameType': widget.game.gameType},
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '🎯 Skor: $correctAnswers/$totalQuestions ⭐ Kaydedildi!',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Sıralama',
              textColor: Colors.white,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LeaderboardPage(game: widget.game),
                  ),
                );
              },
            ),
          ),
        );
      }
    } catch (e) {
      print('❌ Skor kaydetme hatası: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🎯 Puan: $score'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _reloadGame() {
    _validateAndInitialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.game.title),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Yeniden Yükle',
            onPressed: _reloadGame,
          ),
          IconButton(
            icon: const Icon(Icons.bug_report),
            tooltip: 'Debug',
            onPressed: () {
              print('🐛 DEBUG INFO:');
              print('- Oyun ID: ${widget.game.id}');
              print('- Başlık: ${widget.game.title}');
              print('- HTML uzunluğu: ${widget.game.htmlContent.length}');
              print('- Oyun türü: ${widget.game.gameType}');

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'HTML: ${widget.game.htmlContent.length} karakter',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: _errorMessage != null
          ? _buildErrorView()
          : _isLoading
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Oyun yükleniyor...'),
                    ],
                  ),
                )
              : WebViewWidget(controller: _controller),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Bilinmeyen hata',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _reloadGame,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Yeniden Dene'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Geri Dön'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
