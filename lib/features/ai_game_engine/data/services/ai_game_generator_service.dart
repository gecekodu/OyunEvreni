// 🤖 AI GAME GENERATOR SERVICE
// Gemini kullanarak doğal dil açıklamasından oyun configuration üretir

import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:convert';
import '../../domain/entities/game_template.dart';

/// 🤖 AI Oyun Üretici Servis
class AIGameGeneratorService {
  final String apiKey;
  late final GenerativeModel _model;

  AIGameGeneratorService({required this.apiKey}) {
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
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

     final prompt = '''
Sen, html-css-javascript-games repository'sinin 30 HTML oyununu (Quiz Game, Memory Card Game, Speed Typing Game, Hangman vb.) analiz eden deneyimli oyun ve eğitim geliştiricisin.

OYUN TANIMI: "$userDescription"
YAŞ GRUBU: $targetAge yaş
ZORLUK: $difficulty

İŞ: 
1. Verilen açıklamaya uygun HTML5 oyun yap
2. Mimarisi şu oyunlardan biri gibi ol: Quiz (soru-cevap), Memory (eşleştirme), Typing (hız-doğruluk), Collector (toplama)
3. Oyun mekaniklerini eğitim kazanımlarıyla yap
4. Oyunun başında kazanımları göster
5. Oyun sonunda başarı analizi göster

KAZANIM ÖRNEKLERI (5-6 tane):
- Öğrenci X konseptini anlayacak
- Öğrenci Y problemini çözebilecek
- Öğrenci Z hızını artıracak
- Öğrenci dikkatini geliştirecek

TEKNIK GEREKLER:
- Tek HTML dosyası (CSS + JS içine entegre)
- Canvas veya DOM-based (seçim tamam)
- Tam çalışan, eksik kod YOK
- TODO, placeholder, pseudo-code YOK
- Oyun açılır açılmaz oynanabilir
- Mobil + Desktop uyumlu
- Dokunma + Klavye kontrol

HTML YAPISI:
1. Başlık + Kazanımları gösteren intro ekranı
2. Oyun başlatma butonu
3. Oyun alanı (score, timer göster)
4. Oyun bitişinde sonuç ekranı (başarıya göre kazanım göster)
5. Yeniden oyna butonu

MEKANIK:
- Min 2 dakika oyun süresi
- Progressive zorluk
- Skor sistemi
- Hata sayıcısı
- Teşvik mesajları

ÇIKTI: SADECE COMPLETE HTML KOD (açıklama YOK)
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
