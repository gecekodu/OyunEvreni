// 🤖 AI GAME GENERATOR SERVICE
// Gemini kullanarak doğal dil açıklamasından oyun configuration üretir

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../../domain/entities/game_template.dart';

/// 🤖 AI Oyun Üretici Servis
class AIGameGeneratorService {
  final String apiKey;
  late final GenerativeModel _model;

  AIGameGeneratorService({required this.apiKey}) {
    _model = GenerativeModel(
      model: 'gemini-2.5-flash-lite',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.9, // Yaratıcılık için yüksek
        maxOutputTokens: 20000, // Daha uzun, detaylı oyunlar için
      ),
    );
  }

  /// 🎮 DOĞAL DİL'DEN OYUN OLUŞTUR
  /// Kullanıcı: "7 yaş için toplama öğreten platform oyunu yap"
  /// Output: AIGameConfig JSON
  Future<AIGameConfig> generateGameFromDescription({
    required String userDescription,
    String difficulty = 'medium',
    int targetAge = 8,
  }) async {
    print('🤖 AI Oyun üretiyor: "$userDescription"');

    final prompt = _buildGameGenerationPrompt(
      userDescription: userDescription,
      difficulty: difficulty,
      targetAge: targetAge,
    );

    try {
      final response = await _model.generateContent([
        Content.text(prompt),
      ]);

      if (response.text == null || response.text!.isEmpty) {
        throw Exception('Gemini response bos');
      }

      // JSON parse et
      final jsonStr = _extractJson(response.text!);
      final gameData = jsonDecode(jsonStr);

      // AIGameConfig objesine donustur
      final config = AIGameConfig.fromJson(gameData);

      print('✅ Oyun basariyla uretildi: ${config.title}');
      return config;
    } catch (e) {
      print('❌ Oyun uretim hatasi: $e');
      rethrow;
    }
  }

  /// 🎮 OYUN ŞABLONUNDAn OYUN OLUŞTUR
  /// Template seçilmiş, sadece içeriği doldur
  Future<AIGameConfig> generateGameFromTemplate({
    required GameTemplate template,
    required String subject, // matematik, kelime, fen
    required String difficulty,
    required int targetAge,
    String? customTheme, // opsiyonel tema (uzay, orman, vs)
  }) async {
    print('🤖 Sablondan oyun uretiyor: ${template.name}');

    final prompt = _buildTemplateGamePrompt(
      template: template,
      subject: subject,
      difficulty: difficulty,
      targetAge: targetAge,
      customTheme: customTheme,
    );

    try {
      final response = await _model.generateContent([
        Content.text(prompt),
      ]);

      if (response.text == null || response.text!.isEmpty) {
        throw Exception('Gemini response bos');
      }

      final jsonStr = _extractJson(response.text!);
      final gameData = jsonDecode(jsonStr);
      final config = AIGameConfig.fromJson(gameData);

      print('✅ Sablon oyun basariyla uretildi: ${config.title}');
      return config;
    } catch (e) {
      print('❌ Sablon oyun hatasi: $e');
      rethrow;
    }
  }

  /// 🔄 OYUNU YENİDEN OLUŞTUR (Aynı parametrelerle farklı içerik)
  Future<AIGameConfig> regenerateGame(AIGameConfig previousConfig) async {
    print('🔄 Oyun yeniden uretiliyor...');

    final prompt = '''
Asagidaki oyun yapilandirmasina benzer ama FARKLI icerikli yeni bir oyun olustur:

Onceki Oyun:
- Baslik: ${previousConfig.title}
- Sablon: ${previousConfig.template.name}
- Zorluk: ${previousConfig.difficulty}
- Yas: ${previousConfig.targetAge}

ONEMLI: Ayni sablon ve mekaniği kullan ama:
- Farkli baslik
- Farkli sorular/içerik
- Farkli tema renkleri

$_gameJsonSchema
''';

    try {
      final response = await _model.generateContent([
        Content.text(prompt),
      ]);

      final jsonStr = _extractJson(response.text!);
      final gameData = jsonDecode(jsonStr);
      return AIGameConfig.fromJson(gameData);
    } catch (e) {
      print('❌ Yeniden uretim hatasi: $e');
      rethrow;
    }
  }

  /// 🎮 HTML OYUN OLUŞTUR (Eğitim Amaçlı)
  /// Referans: html-css-javascript-games repository (30 oyun)
  /// - Quiz Game, Memory Card Game, Typing Game mimarisinden ilham al
  /// - Oyunla eğitim kazanımlarını birleştir
  Future<String> generateHTML3DGame({
    required String userDescription,
    required String difficulty,
    required int targetAge,
  }) async {
    print('🎮 Eğitim Oyunu üretiliyor: "$userDescription"');

    final referenceHtml = await _loadReferenceHtmlSamples();
    final referenceBlock = _buildReferenceBlock(referenceHtml);

     final prompt = '''
Sen http-css-javascript-games repository'sinin yapısını bilen ve bunun 30 oyununu (01-Candy-Crush, 02-Archery, 03-Speed-Typing, 04-Breakout, 05-Minesweeper, 07-Ping-Pong, 08-Tetris, 10-Memory-Card, 13-Tic-Tac-Toe, 14-Snake, 18-Hangman, 19-Flappy-Bird, 27-Quiz-Game vb.) analiz edip öğrenen deneyimli oyun ve eğitim tasarımcısısın.

UYGULAMADAKI GERCEK HTML OYUN REFERANSLARI (KOD OZETLERI):
$referenceBlock

REFERANS OYUN MİMARİLERİ:
1. Quiz-Game (27): Soru-cevap, çoktan seçmeli, score tracking, result screen
2. Memory-Card-Game (10): Eşleştirme mekanikli, flip animation, skor, zorluk seviyeleri  
3. Speed-Typing-Game (03): Hız ve doğruluk testi, timer, WPM sayacı, ilerleme barı
4. Hangman-Game (18): Kelime tahmin, yanılış sayıcı, kategoriler
5. Snake-Game (14): Duvar çarpışma, büyüme mekanikli, skor
6. Tic-Tac-Toe (13): Turn-based, AI vs Player, kazanan algılama
7. Tetris-Game (08): Grid-based, rotation, hız artışı, line clear
8. Breakout-Game (04): Paddle control, ball physics, brick break, score

OYUN TANIMI: "$userDescription"
YAŞ GRUBU: $targetAge yaş
ZORLUK: $difficulty

İŞ:
1. Verilen açıklamaya en uygun oyun mimarisini seç (Quiz, Memory, Typing, Hangman, vb.)
2. Seçilen mimarinin yapısını kopyala (CSS animasyonlar, game loop, collision detection, vb.)
3. İçerideki hazır mekanikler kalmalı ama EĞİTİM İÇERİĞİ EKLE
4. Oyunun başında 5-6 Kazanım (Learning Outcome) göster
5. Oyun sonunda kazanım bazlı sonuç ekranı yap (başarıya göre ⭐)

KAZANIM YAPISI (Örnek):
- 🎯 Kazanım 1: "Öğrenci X'i anlayacak"
- 🎯 Kazanım 2: "Öğrenci Y'yi çözebilecek" 
- 🎯 Kazanım 3: "Öğrenci Z'yi geliştirecek"
- 🎯 Kazanım 4: "Öğrenci W'de başarılı olacak"
- 🎯 Kazanım 5: "Öğrenci V'de hız kazanacak"
- 🎯 Kazanım 6: "Öğrenci U'de dikkat artacak"

TEKNIK GEREKLER:
- Tek HTML dosyası (CSS + JS içine entegre)
- Canvas VEYA DOM-based (seçim senin)
- Tam çalışan, EKSİK KOD YOK
- TODO, placeholder, pseudo-code YOK
- Oyun açılır açılmaz OYNANABILIR
- Mobile + Desktop uyumlu
- Dokunma + Klavye kontrol
- Minimal assets (base64 veya Unicode karakterler kullan)
- Kod kisa olmasin: en az 12000 karakter ve birden fazla oyun ekranina sahip olsun
- Baslangic, oyun, sonuc ekranlari ve puan/ilerleme HUD'u zorunlu

HTML YAPISI:
1. Loading başlangıcı
2. INTRO EKRAN: Oyun başlığı + 6 Kazanım + START butonu
3. OYUN EKRAN: Oyun alanı + score/timer + progress
4. RESULT EKRAN: 
   - Kazanım bazlı başarı (★★★★☆ gibi)
   - Her kazanım için elde edilen puan göster
   - "Başarıyla Tamamlandı" / "Tekrar Dene" seçeneği

MEKANIK SEÇENEKLERI (Seç bir tanesini):
A) Quiz Tipi: 5-10 soru, doğru cevap = 1 kazanım unlock
B) Memory Tipi: Eşleştirme oyunu, hata sayısı az = daha çok kazanım
C) Typing Tipi: Yazma hızı, doğruluk oranı = kazanım seviyesi
D) Hangman Tipi: Kelime tahmin, hakkı az = daha zor kazanımlar
E) Snake Tipi: Hızlı oyun, puan = kazanım level'i

PUAN HESAPLAMASI:
- Her kazanım max 100 puan
- Başarı = puan / 600 * %100
- %80+ = Tüm kazanımlar bitirildi
- %50-79% = Bazı kazanımlar
- %0-49% = Temel kazanım

ÇIKTI: SADECE COMPLETE HTML KOD (açıklama YOK)
<!DOCTYPE html>
<html>
<!-- Buradan başla -->
''';

    try {
      final response = await _model.generateContent([
        Content.text(prompt),
      ]);

      if (response.text == null || response.text!.isEmpty) {
        throw Exception('Gemini HTML oyun üretimi boş');
      }

      String htmlContent = response.text!;
      
      // Eğer açıklama metni varsa, sadece HTML kısmını al
      if (htmlContent.contains('<!DOCTYPE')) {
        final startIdx = htmlContent.indexOf('<!DOCTYPE');
        if (startIdx >= 0) {
          htmlContent = htmlContent.substring(startIdx);
        }
      }

      if (htmlContent.length < 12000) {
        htmlContent = await _expandHtmlOutput(
          htmlContent: htmlContent,
          userDescription: userDescription,
        );
      }

      print('✅ HTML 3D oyun başarıyla oluşturuldu (${htmlContent.length} karakter)');
      return htmlContent;
    } catch (e) {
      print('❌ HTML oyun üretim hatası: $e');
      rethrow;
    }
  }

  /// 📝 Doğal dil promptu oluştur
  String _buildGameGenerationPrompt({
    required String userDescription,
    required String difficulty,
    required int targetAge,
  }) {
    return '''
Sen bir profesyonel egitim oyunu tasarimcisisin. Asagidaki aciklamaya gore 2D egitim oyunu yapilandirmasi olustur:

KULLANICI ACIKLAMASI: "$userDescription"

PARAMETRELER:
- Zorluk seviyesi: $difficulty
- Hedef yas: $targetAge yas

GOREV:
1. Kullanicinin istedigi oyunu analiz et
2. En uygun oyun sablonunu sec (platformer, collector, puzzle, educational, runner, shooter)
3. Oyun mekanikleri belirle
4. Egitimsel icerik olustur (sorular, cevaplar, aciklamalar)
5. Gorsel tema tasarla
6. Oyun kurallarini belirle

$_gameJsonSchema

ONEMLI KURALLAR:
- Sorular cocuk yasina uygun olmali
- Tum metinler Turkce olmali
- Renkler cocuk dostu olmali
- Talimatlar NET ve KISA olmali
- 3-5 soru kullan
- Baslik yaratici ve cekici olmali
''';
  }

  Future<List<Map<String, String>>> _loadReferenceHtmlSamples() async {
    const assetPaths = [
      'assets/html_games/example_games/besin_ninja.html',
      'assets/html_games/example_games/lazer_fizik.html',
      'assets/html_games/example_games/matematik_okcusu.html',
      'assets/html_games/example_games/araba_surtunme.html',
    ];

    final samples = <Map<String, String>>[];
    for (final path in assetPaths) {
      try {
        final html = await rootBundle.loadString(path);
        samples.add({'path': path, 'html': html});
      } catch (e) {
        print('⚠️ Referans HTML yüklenemedi: $path - $e');
      }
    }

    return samples;
  }

  String _buildReferenceBlock(List<Map<String, String>> samples) {
    if (samples.isEmpty) {
      return 'Referans bulunamadi. Tipik HTML oyun yapisini takip et.';
    }

    final buffer = StringBuffer();
    for (final sample in samples) {
      final path = sample['path'] ?? '';
      final html = sample['html'] ?? '';

      final style = _extractSection(html, 'style', 1200);
      final script = _extractSection(html, 'script', 1400);
      final head = _truncate(_stripTags(html), 600);

      buffer.writeln('--- REF: $path ---');
      buffer.writeln('HEAD_SNIPPET:\n$head');
      if (style.isNotEmpty) buffer.writeln('STYLE_SNIPPET:\n$style');
      if (script.isNotEmpty) buffer.writeln('SCRIPT_SNIPPET:\n$script');
      buffer.writeln('--- END REF ---\n');
    }

    return buffer.toString();
  }

  String _extractSection(String html, String tag, int maxLen) {
    final regex = RegExp('<$tag[^>]*>([\s\S]*?)</$tag>', caseSensitive: false);
    final match = regex.firstMatch(html);
    if (match == null) return '';
    final content = match.group(1) ?? '';
    return _truncate(content, maxLen);
  }

  String _stripTags(String html) {
    return html.replaceAll(RegExp('<[^>]*>'), ' ').replaceAll(RegExp('\s+'), ' ').trim();
  }

  String _truncate(String text, int maxLen) {
    if (text.length <= maxLen) return text;
    return text.substring(0, maxLen) + '...';
  }

  Future<String> _expandHtmlOutput({
    required String htmlContent,
    required String userDescription,
  }) async {
    final expandPrompt = '''
Onceki HTML ciktisi kisa kaldigi icin GENISLET.

KURALLAR:
- Mevcut HTML'yi temel al, yapisini bozma
- En az 12000 karaktere ulas
- Baslangic, oyun, sonuc ekranlarini koru ve zenginlestir
- Yeni HUD, seviye/ilerleme, ek animasyonlar ve daha fazla oyun ici mantik ekle
- Tek HTML dosyasi olarak dondur, aciklama yazma

OYUN TANIMI: "$userDescription"

MEVCUT HTML:
$htmlContent
''';

    final response = await _model.generateContent([Content.text(expandPrompt)]);
    if (response.text == null || response.text!.isEmpty) {
      return htmlContent;
    }

    String expanded = response.text!;
    if (expanded.contains('<!DOCTYPE')) {
      final startIdx = expanded.indexOf('<!DOCTYPE');
      if (startIdx >= 0) {
        expanded = expanded.substring(startIdx);
      }
    }

    return expanded;
  }

  /// 📝 Template promptu oluştur
  String _buildTemplateGamePrompt({
    required GameTemplate template,
    required String subject,
    required String difficulty,
    required int targetAge,
    String? customTheme,
  }) {
    final themeText = customTheme != null ? '\n- Tema: $customTheme' : '';

    return '''
Sen bir profesyonel ogretmen ve oyun tasarimcisisin. Asagidaki parametrelere gore 2D egitim oyunu olustur:

SABLON: ${template.name}
KONU: $subject
ZORLUK: $difficulty
HEDEF YAS: $targetAge$themeText

SABLON ACIKLAMALARI:
- platformer: Mario benzeri platform oyunu (zipla, topla, engelleri atla)
- collector: Pac-Man benzeri koleksiyon oyunu (objeleri topla)
- puzzle: Sokoban/Tetris benzeri bulmaca oyunu
- educational: Soru-cevap odakli egitim oyunu
- runner: Endless runner (surekli kosmaca)
- shooter: Space shooter (uzay gemisi)

GOREV:
1. Konuya uygun sorular olustur ($subject - matemaik, kelime, fen vb)
2. Oyun mekaniklerini belirleme (sablon kaygili)
3. Cocuk yarkin estetik tema secme
4. Ogretici ve egleseli kurallar sec

$_gameJsonSchema

ONEMLI:
- Egutum konusuna odaklan
- $targetAge yas uygunlugu kontrol et
- Talimatlar cerasik ve NET
- Turkce icerik kullan
''';
  }

  /// 📋 JSON Schema (Gemini'ye format goster)
  String get _gameJsonSchema => '''
JSON FORMATI (SADECE JSON DONDUR, baska metin ekleme):
{
  "gameId": "unique-id",
  "title": "Oyun Basligi",
  "description": "Kisa aciklama",
  "template": "platformer|collector|puzzle|educational|runner|shooter",
  "difficulty": "easy|medium|hard",
  "targetAge": 8,
  "mechanics": {
    "hasGravity": true,
    "hasJump": true,
    "hasCollectibles": true,
    "hasEnemies": false,
    "hasTimeLimit": false,
    "hasLives": true,
    "playerSpeed": 200.0,
    "jumpHeight": 300.0
  },
  "educationalContent": {
    "subject": "matematik",
    "questions": [
      {
        "id": "q1",
        "text": "5 + 3 = ?",
        "options": ["6", "8", "10", "12"],
        "correctIndex": 1,
        "explanation": "5 artı 3 esittir 8",
        "imageDescription": "Bes elma artı uc elma"
      }
    ],
    "showFeedback": true,
    "trackProgress": true
  },
  "visualTheme": {
    "backgroundColor": 4287531723,
    "playerColor": 4283215696,
    "enemyColor": 4294934123,
    "collectibleColor": 4294956800,
    "uiColor": 4280391411,
    "styleDescription": "Pastel renkler, cocuk dostu"
  },
  "rules": {
    "winConditionScore": 100,
    "maxLives": 3,
    "timeLimit": 0,
    "allowPause": true,
    "instructions": [
      "Ok tuslari ile hareket et",
      "Sorulari dogru cevapla",
      "Yildizlari topla"
    ]
  }
}
''';

  /// 🔍 JSON'ı metinden çıkar
  String _extractJson(String text) {
    // Markdown code block içindeyse çıkar
    final codeBlockRegex = RegExp(r'```json\s*(\{[\s\S]*?\})\s*```');
    final codeMatch = codeBlockRegex.firstMatch(text);
    if (codeMatch != null) {
      return codeMatch.group(1)!;
    }

    // Direk JSON ara
    final jsonRegex = RegExp(r'\{[\s\S]*\}');
    final jsonMatch = jsonRegex.firstMatch(text);
    if (jsonMatch != null) {
      return jsonMatch.group(0)!;
    }

    // Hic bulamazsa tum metni dene
    return text.trim();
  }
}
