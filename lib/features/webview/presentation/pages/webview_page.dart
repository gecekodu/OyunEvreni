import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  int lastScore = 0;
  String lastRank = 'Başlangıç';
  bool _isFullscreen = false;

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
            _sendAppData();
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
      )
      ..addJavaScriptChannel('PuanKanali',
        onMessageReceived: (JavaScriptMessage message) {
          _handlePuanMessage(message.message);
        },
      )
      ..addJavaScriptChannel('GameUi',
        onMessageReceived: (JavaScriptMessage message) {
          _handleGameUiMessage(message.message);
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

  Future<void> _handlePuanMessage(String puanStr) async {
    try {
      // Puanı int'e çevir
      int puan = int.parse(puanStr);
      debugPrint('🎮 Puan Alındı: $puan');

      // Firebase Auth'dan mevcut kullanıcıyı al
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        debugPrint('❌ Kullanıcı giriş yapmamıştır');
        return;
      }

      // Kullanıcı ID'si
      final userId = currentUser.uid;

      // Profil puanını ve rank'ı güncelle
      final rankData = await _updateUserScoreAndRank(userId, puan);
      
      lastScore = rankData['totalScore'];
      lastRank = rankData['rank'];

      if (mounted) {
        // Oyun sonu dialogunu göster
        _showGameOverDialog(puan, rankData['totalScore'], rankData['rank']);
      }
    } catch (e) {
      debugPrint('❌ Puan işleme hatası: $e');
    }
  }

  Future<void> _handleGameUiMessage(String message) async {
    try {
      final data = jsonDecode(message);
      final type = data['type'] as String? ?? '';

      switch (type) {
        case 'enterFullscreen':
          await _enterFullscreen();
          break;
        case 'exitFullscreen':
          await _exitFullscreen();
          break;
        case 'back':
          if (mounted) {
            Navigator.of(context).maybePop();
          }
          break;
        case 'requestAppData':
          await _sendAppData();
          break;
        case 'score':
          final score = (data['score'] as num?)?.toInt() ?? 0;
          await _handlePuanMessage(score.toString());
          break;
        case 'event':
          debugPrint('🎮 Game event: ${data['event']} ${data['data']}');
          break;
      }
    } catch (e) {
      debugPrint('GameUi mesajı parse edilemedi: $e');
    }
  }

  Future<void> _sendAppData() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final payload = {
      'userId': currentUser?.uid ?? '',
      'userName': currentUser?.displayName ?? 'Anonim Oyuncu',
      'userEmail': currentUser?.email ?? '',
      'userAvatar': currentUser?.photoURL ?? '',
      'gameId': widget.gameId ?? '',
      'gameTitle': widget.gameTitle,
      'platform': 'flutter',
    };

    final js = 'if (window.onAppData) { window.onAppData(${jsonEncode(payload)}); }';
    await controller.runJavaScript(js);
  }

  Future<void> _enterFullscreen() async {
    if (_isFullscreen) return;
    _isFullscreen = true;
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  Future<void> _exitFullscreen() async {
    if (!_isFullscreen) return;
    _isFullscreen = false;
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  Future<Map<String, dynamic>> _updateUserScoreAndRank(String userId, int newScore) async {
    try {
      final firestore = FirebaseFirestore.instance;

      // 1. Mevcut puanı çek (yoksa sıfırdan başla)
      final userDoc = await firestore.collection('users').doc(userId).get();
      int totalScore = userDoc.data()?['toplam_puan'] ?? 0;

      // 2. Yeni puanı ekle
      totalScore += newScore;

      // 3. Rank'ı hesapla
      String yeniRank = _calculateRank(totalScore);

      // 4. Veritabanında güncelle
      await firestore.collection('users').doc(userId).update({
        'toplam_puan': totalScore,
        'rank': yeniRank,
        'son_oyun_tarihi': FieldValue.serverTimestamp(),
      });

      debugPrint('✅ Kullanıcı Puanı Güncellendi: $totalScore | Rank: $yeniRank');
      
      return {
        'totalScore': totalScore,
        'rank': yeniRank,
      };
    } catch (e) {
      debugPrint('❌ Profil güncelleme hatası: $e');
      return {
        'totalScore': 0,
        'rank': 'Başlangıç',
      };
    }
  }

  String _calculateRank(int totalScore) {
    if (totalScore < 100) return 'Başlangıç';
    if (totalScore < 500) return 'Bronz';
    if (totalScore < 1000) return 'Gümüş';
    if (totalScore < 2000) return 'Altın';
    if (totalScore < 5000) return 'Elmas';
    return 'Büyücü';
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
                // Başlık
                const Text(
                  '🎮 Oyun Bitti!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Kazanılan Puan
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
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
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
                
                // Toplam Puan ve Rank
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
                            const Text(
                              'Toplam Puan',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$totalPoints',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
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
                            const Text(
                              'Rütben',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              rank,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Butonlar
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          // Oyunu yeniden yükle
                          controller.reload();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.replay, color: Colors.white),
                        label: const Text(
                          'Tekrar Oyna',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).pop(); // WebView'u kapat
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.home, color: Colors.white),
                        label: const Text(
                          'Ana Menü',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
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
    return WillPopScope(
      onWillPop: () async {
        if (_isFullscreen) {
          await _exitFullscreen();
          return false;
        }
        if (await controller.canGoBack()) {
          await controller.goBack();
          return false;
        }
        return true;
      },
      child: Scaffold(
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
      ),
    );
  }

  @override
  void dispose() {
    _exitFullscreen();
    super.dispose();
  }
}
