// 🌐 ENHANCED WEBVIEW - HTML Oyun ↔ Flutter ↔ Firebase Köprüsü

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/services.dart';
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
  InAppWebViewController? _webViewController;
  late ScoreService _scoreService;
  late FirebaseAuth _auth;
  int _totalScoreThisSession = 0;
  bool _isLoading = true;
  bool _isSubmittingScore = false;  // Puan gönderme kontrolü
  String? _htmlData;

  @override
  void initState() {
    super.initState();
    _scoreService = GetIt.instance<ScoreService>();
    _auth = FirebaseAuth.instance;
    _loadGameContent();
  }

  Future<void> _loadGameContent() async {
    if (widget.gameUrl.startsWith('assets/')) {
      try {
        debugPrint('🎮 Oyun asset\'i yükleniyor: ${widget.gameUrl}');
        final html = await rootBundle.loadString(widget.gameUrl);
        debugPrint('✅ HTML yüklendi: ${html.length} karakter');
        if (mounted) {
          setState(() {
            _htmlData = html;
          });
        }
      } catch (e) {
        debugPrint('❌ Asset yükleme hatası: $e');
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
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
            if (_htmlData != null)
              InAppWebView(
                initialSettings: InAppWebViewSettings(
                  useShouldOverrideUrlLoading: true,
                  useOnLoadResource: true,
                  mediaPlaybackRequiresUserGesture: false,
                  allowContentAccess: true,
                  allowFileAccess: true,
                  allowFileAccessFromFileURLs: true,
                  allowUniversalAccessFromFileURLs: true,
                  javaScriptEnabled: true,
                  domStorageEnabled: true,
                ),
                onWebViewCreated: (controller) async {
                  _webViewController = controller;
                  debugPrint('📱 WebView oluşturuldu: ${widget.gameName}');
                  
                  // HTML content yükle
                  debugPrint('🎲 HTML yükleniyor (${_htmlData!.length} karakter)...');
                  await controller.loadData(
                    data: _htmlData!,
                    mimeType: 'text/html',
                    encoding: 'utf-8',
                  );
                  debugPrint('✅ HTML WebView\'a yüklendi');
                  
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
                    debugPrint('🎮 Oyun başladı: ${widget.gameName}');
                    setState(() => _totalScoreThisSession = 0);
                  },
                );
              },
              onLoadStop: (controller, url) {
                debugPrint('✅ Sayfa yüklendi: $url');
                setState(() => _isLoading = false);
                _injectGameScript();
              },
              onLoadError: (controller, url, code, message) {
                debugPrint('❌ WebView hatası: $message (Code: $code, URL: $url)');
                setState(() => _isLoading = false);
              },
              onConsoleMessage: (controller, consoleMessage) {
                debugPrint('🖥️ Console: ${consoleMessage.message}');
              },
            ),
            if (_htmlData == null || _isLoading)
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
  void _handleScoreFromGame(List<dynamic> args) async {
    try {
      int score = args[0] as int;
      
      setState(() {
        _totalScoreThisSession = score;
      });

      print('⭐ Oyundan puan alındı: $score');

      // Kullanıcı bilgilerini al
      final user = _auth.currentUser;
      if (user != null) {
        final userName = user.displayName ?? user.email?.split('@').first ?? 'Oyuncu';
        
        await _scoreService.addScoreToUserProfile(
          userId: user.uid,
          userName: userName,
          score: score,
          userAvatar: user.photoURL ?? '',
        );

        final rankData = await _getUserRankData(user.uid);
        final totalScore = rankData['totalScore'] ?? score;
        final rank = rankData['rank'] ?? 'Başlangıç';
        
        _showGameOverDialog(score, totalScore, rank);
      }
    } catch (e) {
      print('❌ Puan işleme hatası: $e');
    }
  }
  
  Future<Map<String, dynamic>> _getUserRankData(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      
      if (userDoc.exists) {
        final data = userDoc.data();
        final totalScore = (data?['totalScore'] as num?)?.toInt() ?? 0;
        
        // Global rank'i hesapla (basit versiyonu)
        final allUsers = await FirebaseFirestore.instance
            .collection('users')
            .where('totalScore', isGreaterThan: totalScore)
            .get();
        
        final globalRank = allUsers.docs.length + 1;
        
        return {
          'totalScore': totalScore,
          'rank': globalRank > 0 ? '#$globalRank' : 'Başlangıç',
        };
      }
    } catch (e) {
      debugPrint('Rank verileri alinamadi: $e');
    }
    return {'totalScore': 0, 'rank': 'Başlangıç'};
  }

  void _showGameOverDialog(int earnedPoints, int totalPoints, String rank) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '🎮 Oyun Bitti!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
                const SizedBox(height: 20),
                
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Kazandığın Puan',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '+$earnedPoints',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            const Text('Toplam Puan', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            const SizedBox(height: 4),
                            Text(
                              '$totalPoints',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.purple.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            const Text('Rütben', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            const SizedBox(height: 4),
                            Text(
                              rank,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.purple),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                StatefulBuilder(
                  builder: (context, setState) => Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isSubmittingScore ? null : () async {
                            // Çift tıklama önle
                            if (_isSubmittingScore) return;
                            
                            setState(() => _isSubmittingScore = true);
                            
                            try {
                              // Puanı Firebase'e kaydet
                              await _recordFinalScore(earnedPoints);
                              
                              if (mounted) {
                                // Dialog kapat
                                Navigator.of(context).pop();
                                
                                // Başarı mesajı göster
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Row(
                                      children: [
                                        Icon(Icons.check_circle, color: Colors.white),
                                        SizedBox(width: 8),
                                        Text('Tebrikler! Puan eklendi ✨'),
                                      ],
                                    ),
                                    backgroundColor: Colors.green,
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                                
                                // İçeriği sabitlemek için bekle ve çık
                                await Future.delayed(const Duration(milliseconds: 800));
                                if (mounted) {
                                  Navigator.of(context).pop(); // WebView'dan çık ve ana sayfaya dön
                                }
                              }
                            } catch (e) {
                              if (mounted) {
                                setState(() => _isSubmittingScore = false);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Hata: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isSubmittingScore ? Colors.grey : Colors.green.shade600,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: _isSubmittingScore
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Icon(Icons.check_circle, color: Colors.white),
                          label: Text(
                            _isSubmittingScore ? 'Kaydediliyor...' : 'Puanı Al',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _isSubmittingScore ? null : () {
                                Navigator.of(context).pop();
                                _webViewController?.reload();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isSubmittingScore ? Colors.grey : Colors.orange,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              icon: const Icon(Icons.replay, color: Colors.white),
                              label: const Text('Tekrar Oyna', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _isSubmittingScore ? null : () {
                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isSubmittingScore ? Colors.grey : Colors.deepPurple,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              icon: const Icon(Icons.home, color: Colors.white),
                              label: const Text('Ana Menü', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
                _webViewController?.reload();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey,
              ),
              child: const Text('Tekrar Oyna'),
            ),
            ElevatedButton.icon(
              onPressed: _isSubmittingScore ? null : () async {
                // Çift tıklama önleme
                if (_isSubmittingScore) return;
                setState(() => _isSubmittingScore = true);
                
                try {
                  // Puanı Firebase'e kaydet
                  await _recordFinalScore(finalScore);
                  
                  // Dialog kapat
                  if (mounted) {
                    Navigator.pop(context);
                    
                    // Başarı mesajı göster
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.white),
                            SizedBox(width: 8),
                            Text('Tebrikler! Puan eklendi ✨'),
                          ],
                        ),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );
                    
                    // Ana sayfaya dön
                    await Future.delayed(const Duration(milliseconds: 500));
                    if (mounted) {
                      Navigator.pop(context); // WebView'dan çık
                    }
                  }
                } catch (e) {
                  if (mounted) {
                    setState(() => _isSubmittingScore = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Hata: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              icon: _isSubmittingScore 
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.check_circle),
              label: Text(_isSubmittingScore ? 'Kaydediliyor...' : 'Puanı Al'),
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
    _webViewController?.evaluateJavascript(source: '''
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
    _webViewController?.clearCache();
    super.dispose();
  }
}
