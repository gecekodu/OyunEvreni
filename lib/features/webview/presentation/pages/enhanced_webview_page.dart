// 🌐 ENHANCED WEBVIEW - HTML Oyun ↔ Flutter ↔ Firebase Köprüsü

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get_it/get_it.dart';
import '../../../../features/games/data/services/score_service.dart';

class EnhancedWebviewPage extends StatefulWidget {
  final String gameUrl;
  final String gameName;
  final String? gameId;

  const EnhancedWebviewPage({
    super.key,
    required this.gameUrl,
    required this.gameName,
    this.gameId,
  });

  @override
  State<EnhancedWebviewPage> createState() => _EnhancedWebviewPageState();
}

class _EnhancedWebviewPageState extends State<EnhancedWebviewPage> {
  late InAppWebViewController _webViewController;
  late ScoreService _scoreService;
  late FirebaseAuth _auth;
  int _totalScoreThisSession = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _scoreService = GetIt.instance<ScoreService>();
    _auth = FirebaseAuth.instance;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Çıkış yapılırken oyun skorunu kaydet
        if (_totalScoreThisSession > 0) {
          await _saveGameSession();
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.gameName),
          centerTitle: true,
          backgroundColor: Colors.purple.shade700,
          elevation: 0,
          actions: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.orange, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '$_totalScoreThisSession',
                        style: TextStyle(
                          color: Colors.purple.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            InAppWebView(
              initialSettings: InAppWebViewSettings(
                useShouldOverrideUrlLoading: true,
                useOnLoadResource: true,
                mediaPlaybackRequiresUserGesture: false,
                allowContentAccess: true,
                allowFileAccess: true,
              ),
              initialUrlRequest: URLRequest(
                url: WebUri(widget.gameUrl),
              ),
              onWebViewCreated: (controller) async {
                _webViewController = controller;
                
                // ✅ Puan gönderme handler'ı tanımlama
                controller.addJavaScriptHandler(
                  handlerName: 'sendScore',
                  callback: (args) {
                    _handleScoreFromGame(args);
                  },
                );

                // ✅ Oyun tamamlanması handler'ı
                controller.addJavaScriptHandler(
                  handlerName: 'gameCompleted',
                  callback: (args) {
                    _handleGameCompleted(args);
                  },
                );

                // ✅ Oyun başlatma bildirimi
                controller.addJavaScriptHandler(
                  handlerName: 'gameStarted',
                  callback: (args) {
                    print('🎮 Oyun başladı: ${widget.gameName}');
                    setState(() => _totalScoreThisSession = 0);
                  },
                );
              },
              onLoadStop: (controller, url) {
                setState(() => _isLoading = false);
                _injectGameScript();
              },
              onLoadError: (controller, url, code, message) {
                setState(() => _isLoading = false);
                print('❌ WebView hatası: $message');
              },
            ),
            if (_isLoading)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${widget.gameName} yükleniyor...',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 🎮 HTML oyundan puan alındığında çağrılır
  void _handleScoreFromGame(List<dynamic> args) {
    try {
      int score = args[0] as int;
      
      setState(() {
        _totalScoreThisSession += score;
      });

      print('⭐ Oyundan puan alındı: +$score (Toplam: $_totalScoreThisSession)');

      // Anlık puan bildirgesi göster
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Harika! +$score puan kazandın!'),
              const Icon(Icons.star, color: Colors.orange),
            ],
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
        ),
      );

      // Gerçek zamanlı Firebase güncellemesi
      _updateScoreInRealtimeMode(score);
    } catch (e) {
      print('❌ Puan işleme hatası: $e');
    }
  }

  /// 🏁 Oyun tamamlandığında
  void _handleGameCompleted(List<dynamic> args) {
    try {
      int finalScore = args[0] as int;
      
      print('✅ Oyun tamamlandı! Final skor: $finalScore');

      // Toplam puanı güncelle
      setState(() {
        _totalScoreThisSession = finalScore;
      });

      // Tamamlanma dialogu göster
      showDialog(
        context: context,
        barrierDismissible: false, // Dışarı tıklanmaSını engelle
        builder: (context) => AlertDialog(
          title: const Text('🎉 Oyun Tamamlandı!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$finalScore',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'PUAN',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Puanı kabul edip Profile\'e dön',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Tekrar oyna - bir daha oyun reload et
                Navigator.pop(context);
                _webViewController.reload();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey,
              ),
              child: const Text('Tekrar Oyna'),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                // Puanı al ve profile git
                Navigator.pop(context); // Dialog kapat
                
                // Puanı Firebase'e kaydet
                await _recordFinalScore(finalScore);
                
                // Profile'e navigate et
                if (mounted) {
                  Navigator.pop(context); // WebView'dan çık
                }
              },
              icon: const Icon(Icons.check_circle),
              label: const Text('Puanı Al'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      print('❌ Oyun tamamlanma işleme hatası: $e');
    }
  }

  /// 💾 Final puanı Firebase'e kaydet
  Future<void> _recordFinalScore(int finalScore) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('⚠️ Kullanıcı giriş yapmamış');
        return;
      }

      print('💾 Final puan kaydediliyor: $finalScore');
      
      // Atomic increment ile Firebase güncellemesi
      await _scoreService.addScoreToUserProfile(
        userId: user.uid,
        userName: user.displayName ?? user.email ?? 'Kullanıcı',
        score: finalScore,
        userAvatar: user.photoURL ?? '',
      );

      print('✅ Final puan Firebase\'e kaydedildi: $finalScore');
      
      // Başarı notification göster
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('✅ $finalScore puan profiline eklendi!'),
                const SizedBox(width: 8),
              ],
            ),
            backgroundColor: Colors.green.shade700,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print('❌ Final puan kaydetme hatası: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Puan kaydedilemedi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 📊 Gerçek Zamanlı Puan Güncelleme (Veritabanına)
  void _updateScoreInRealtimeMode(int score) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('⚠️ Kullanıcı giriş yapmamış');
        return;
      }

      // Atomic increment ile Firebase güncellemesi
      await _scoreService.addScoreToUserProfile(
        userId: user.uid,
        userName: user.displayName ?? user.email ?? 'Kullanıcı',
        score: score,
        userAvatar: user.photoURL ?? '',
      );

      print('✅ Puan Firebase\'e kaydedildi: +$score');
    } catch (e) {
      print('❌ Firebase puan güncelleme hatası: $e');
    }
  }

  /// 💾 Oyun Seansını Kaydet
  Future<void> _saveGameSession() async {
    try {
      final user = _auth.currentUser;
      if (user == null || _totalScoreThisSession == 0) return;

      print('💾 Oyun seansı kaydediliyor: $_totalScoreThisSession puan');
      
      // Seansı Firebase\'e kaydet (isteğe bağlı analytics için)
      // ScoreService.saveScore() kullanabilirsin
    } catch (e) {
      print('❌ Seans kaydetme hatası: $e');
    }
  }

  /// 📝 HTML oyuna etkinlik scripti enjekte et
  void _injectGameScript() {
    _webViewController.evaluateJavascript(source: '''
      // Flutter ile iletişim kurmak için global fonksiyon
      window.flutter_send_score = function(score) {
        if (window.flutter_inappwebview) {
          window.flutter_inappwebview.callHandler('sendScore', score);
        }
      };

      window.flutter_game_started = function() {
        if (window.flutter_inappwebview) {
          window.flutter_inappwebview.callHandler('gameStarted');
        }
      };

      window.flutter_game_completed = function(finalScore) {
        if (window.flutter_inappwebview) {
          window.flutter_inappwebview.callHandler('gameCompleted', finalScore);
        }
      };

      console.log('✅ Flutter haberleşme fonksiyonları hazır');
    ''');
  }

  @override
  void dispose() {
    _webViewController.clearCache();
    super.dispose();
  }
}
