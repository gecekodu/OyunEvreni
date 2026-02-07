// 🔧 TEST PANELİ - Firebase ve Gemini API Testi

import 'package:flutter/material.dart';
import '../../../../core/services/firebase_service.dart';
import '../../../../core/services/gemini_game_service.dart';
import '../../../../main.dart';

class TestPanelPage extends StatefulWidget {
  const TestPanelPage({super.key});

  @override
  State<TestPanelPage> createState() => _TestPanelPageState();
}

class _TestPanelPageState extends State<TestPanelPage> {
  final firebaseService = getIt<FirebaseService>();
  late final GeminiGameService geminiService;
  
  String firebaseStatus = '⏳ Test beklemede...';
  String geminiStatus = '⏳ Test beklemede...';
  String testLog = '';
  bool isTestRunning = false;

  @override
  void initState() {
    super.initState();
    // TODO: Gerçek API key kullanılacak
    geminiService = GeminiGameService(apiKey: 'YOUR_GEMINI_API_KEY');
  }

  void _addLog(String message) {
    setState(() {
      testLog += '${DateTime.now().toString().split('.')[0]} - $message\n';
    });
  }

  Future<void> _testFirebase() async {
    setState(() => isTestRunning = true);
    _addLog('🔥 Firebase Testi Başladı...');

    try {
      // Firestore bağlantısı test et
      _addLog('Firestore test koleksiyonuna yazılıyor...');
      
      await firebaseService.firestore.collection('test').add({
        'name': 'Test Verisi',
        'timestamp': DateTime.now(),
        'status': 'success',
      });

      _addLog('✅ Firestore yazma başarılı!');

      // Veriyi oku
      _addLog("Firestore'dan veri okunuyor...");
      final querySnapshot = await firebaseService.firestore
          .collection('test')
          .where('name', isEqualTo: 'Test Verisi')
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        _addLog('✅ Firestore okuma başarılı! (${querySnapshot.docs.length} belge)');
        setState(() => firebaseStatus = '✅ Firebase Çalışıyor');
      } else {
        throw Exception('Veri okunamadı');
      }
    } catch (e) {
      _addLog('❌ Firebase Hatası: $e');
      setState(() => firebaseStatus = '❌ Firebase Hatası: $e');
    } finally {
      setState(() => isTestRunning = false);
    }
  }

  Future<void> _testGemini() async {
    setState(() => isTestRunning = true);
    _addLog('🤖 Gemini API Testi Başladı...');

    try {
      _addLog('Gemini bağlantısı test ediliyor...');
      final isConnected = await geminiService.testConnection();

      if (!isConnected) {
        throw Exception('Gemini API bağlantı başarısız');
      }

      _addLog('✅ Gemini bağlantısı başarılı!');

      // Matematik oyunu içeriği oluştur
      _addLog('Matematik oyunu içeriği oluşturuluyor...');
      final mathContent = await geminiService.generateMathGameContent(
        topic: 'addition',
        difficulty: 'easy',
        questionCount: 3,
      );

      if (mathContent['questions'] != null) {
        _addLog('✅ Matematik oyunu içeriği oluşturuldu!');
        _addLog('Sorular: ${mathContent['questions'].length}');
        setState(() => geminiStatus = '✅ Gemini Çalışıyor');
      } else {
        throw Exception('İçerik boş');
      }
    } catch (e) {
      _addLog('❌ Gemini Hatası: $e');
      setState(() => geminiStatus = '❌ Gemini Hatası: $e');
    } finally {
      setState(() => isTestRunning = false);
    }
  }

  Future<void> _testAllGameTypes() async {
    setState(() => isTestRunning = true);
    _addLog('🎮 Tüm Oyun Türleri Testi Başladı...');

    try {
      // 1. Matematik
      _addLog('\n1️⃣ Matematik Oyunu...');
      final math = await geminiService.generateMathGameContent(
        topic: 'multiplication',
        difficulty: 'medium',
        questionCount: 5,
      );
      _addLog('✅ ${math['title']} - ${math['questions'].length} soru');

      // 2. Kelime
      _addLog('\n2️⃣ Kelime Oyunu...');
      final word = await geminiService.generateWordGameContent(
        difficulty: 'easy',
        wordCount: 5,
      );
      _addLog('✅ ${word['title']} - ${word['words'].length} kelime');

      // 3. Renk
      _addLog('\n3️⃣ Renk Oyunu...');
      final color = await geminiService.generateColorGameContent(
        difficulty: 'easy',
        colorCount: 6,
      );
      _addLog('✅ ${color['title']} - ${color['colors'].length} renk');

      // 4. Bulmaca
      _addLog('\n4️⃣ Bulmaca...');
      final puzzle = await geminiService.generatePuzzleGameContent(
        difficulty: 'easy',
        puzzleCount: 3,
      );
      _addLog('✅ ${puzzle['title']} - ${puzzle['puzzles'].length} bulmaca');

      // 5. Hafıza
      _addLog('\n5️⃣ Hafıza Oyunu...');
      final memory = await geminiService.generateMemoryGameContent(
        difficulty: 'easy',
        pairCount: 4,
      );
      _addLog('✅ ${memory['title']} - ${memory['pairs'].length} kart');

      _addLog('\n🎉 Tüm oyun türleri başarıyla oluşturuldu!');
    } catch (e) {
      _addLog('❌ Hata: $e');
    } finally {
      setState(() => isTestRunning = false);
    }
  }

  Future<void> _clearLogs() async {
    setState(() => testLog = '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔧 Test Paneli'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Durum Kartları
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Firebase Durumu
                Card(
                  color: firebaseStatus.contains('✅')
                      ? Colors.green.shade50
                      : Colors.red.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Text('🔥', style: TextStyle(fontSize: 32)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Firebase',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              Text(firebaseStatus,
                                  style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Gemini Durumu
                Card(
                  color: geminiStatus.contains('✅')
                      ? Colors.green.shade50
                      : Colors.red.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Text('🤖', style: TextStyle(fontSize: 32)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Gemini API',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              Text(geminiStatus,
                                  style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Test Butonları
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton.icon(
                  onPressed: isTestRunning ? null : _testFirebase,
                  icon: const Icon(Icons.storage),
                  label: const Text('Firebase Testi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: isTestRunning ? null : _testGemini,
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Gemini Testi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: isTestRunning ? null : _testAllGameTypes,
                  icon: const Icon(Icons.games),
                  label: const Text('Tüm Oyun Türleri'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          const Divider(),

          // Test Logları
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade700),
              ),
              child: SingleChildScrollView(
                child: Text(
                  testLog.isEmpty ? '⏳ Testler başladığında loglar burada görünecek...' : testLog,
                  style: const TextStyle(
                    color: Colors.green,
                    fontFamily: 'Courier',
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          ),

          // Alt Butonlar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _clearLogs,
                    icon: const Icon(Icons.delete),
                    label: const Text('Logları Temizle'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Geri'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
