import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
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
    // HTML içeriğini kontrol et
    if (widget.game.htmlContent.isEmpty) {
      setState(() {
        _errorMessage = 'Oyun içeriği bulunamadı';
        _isLoading = false;
      });
      print('❌ HTML içerik boş!');
      return;
    }

    print('✅ HTML yükleniyor: ${widget.game.htmlContent.length} karakter');
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..enableZoom(false)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            print('🌐 Sayfa yükleniyor: $url');
            // ✅ Timeout ekle
            Future.delayed(const Duration(seconds: 10), () {
              if (_isLoading && mounted) {
                setState(() {
                  _errorMessage = 'Yükleme zaman aşımına uğradı';
                  _isLoading = false;
                });
              }
            });
          },
          onPageFinished: (String url) {
            print('✅ Sayfa yüklendi: $url');
            setState(() => _isLoading = false);
            // HTML oyunlar farkli bridge'ler kullanabiliyor; shim ekle.
            _controller.runJavaScript('''
              if (!window.flutter_inappwebview) {
                window.flutter_inappwebview = {
                  callHandler: function(name, msg) {
                    if (name === 'GameChannel') {
                      try { GameChannel.postMessage(String(msg)); } catch (e) {}
                    }
                  }
                };
              }
              if (!window.GameChannel) {
                window.GameChannel = {
                  postMessage: function(msg) {
                    try { GameChannel.postMessage(String(msg)); } catch (e) {}
                  }
                };
              }
            ''');
          },
          onWebResourceError: (WebResourceError error) {
            print('❌ WebView Hatası: ${error.description}');
            setState(() {
              _errorMessage = 'Yükleme hatası: ${error.description}';
              _isLoading = false;
            });
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
      )
      ..loadHtmlString(widget.game.htmlContent);
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
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    _controller.reload();
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
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Geri Dön'),
            ),
          ],
        ),
      ),
    );
  }
}
