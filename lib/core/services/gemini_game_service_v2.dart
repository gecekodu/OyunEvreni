// 🤖 GEMİNİ GAME SERVICE v2.0 - REFACTORED
// ✅ Tekli entry point, enum tabanlı, standart JSON şema, geliştirilmiş error handling

import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:convert';

/// 🎮 Desteklenen oyun türleri
enum GameType {
  math('Matematik', '🔢'),
  word('Kelime Oyunu', '📝'),
  color('Renk Oyunu', '🎨'),
  puzzle('Sayı Bulmaca', '🧩'),
  memory('Hafıza Oyunu', '🧠'),
  logic('Mantık Oyunu', '💡');

  final String displayName;
  final String emoji;
  const GameType(this.displayName, this.emoji);
}

/// 🎮 Geliştirilmiş Gemini Game Service
class GeminiGameServiceV2 {
  final String apiKey;
  late final GenerativeModel _model;

  GeminiGameServiceV2({required this.apiKey}) {
    // 🤖 Gemini 2.5 Flash Lite - Lightweight & responsive
    _model = GenerativeModel(
      model: 'gemini-2.5-flash-lite',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.6,
        maxOutputTokens: 4000,
      ),
    );
  }

  /// 🔄 Fallback Model
  GenerativeModel _getFallbackModel() {
    return GenerativeModel(
      model: 'gemini-pro',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.5,
        maxOutputTokens: 3000,
      ),
    );
  }

  /// 🎮 ANA OYUN ÜRETİCİ - TEK ENTRY POINT
  /// Tüm oyun türlerini birleştirilmiş yaklaşımla oluşturur
  Future<Map<String, dynamic>> generateGame({
    required GameType gameType,
    required String difficulty, // easy, medium, hard
    required int ageGroup, // yaş grubu
    Map<String, dynamic>? parameters,
    String? customDescription,
  }) async {
    print('🎮 Oyun oluşturuluyor: ${gameType.displayName}');

    try {
      // 1️⃣ Prompt oluştur (type-specific template)
      final prompt = _buildGamePrompt(
        gameType: gameType,
        difficulty: difficulty,
        ageGroup: ageGroup,
        parameters: parameters ?? {},
        customDescription: customDescription,
      );

      // 2️⃣ Gemini API'ye sor
      final response = await _safeGenerate(prompt);

      // 3️⃣ JSON extract et
      final jsonStr = _extractJson(response);

      // 4️⃣ Parse et
      final gameData = jsonDecode(jsonStr) as Map<String, dynamic>;

      // 5️⃣ Şemayı doğrula
      _validateGameSchema(gameData);

      // 6️⃣ Meta + content + ui yapısını bitir
      final game = _normalizeGameData(gameData, gameType, difficulty, ageGroup);

      print('✅ Oyun başarıyla oluşturuldu: ${game['meta']['gameType']}');
      return game;
    } catch (e) {
      print('❌ Oyun oluşturma hatası: $e');
      rethrow;
    }
  }

  // ============ PROMPT BUILDER ============

  String _buildGamePrompt({
    required GameType gameType,
    required String difficulty,
    required int ageGroup,
    required Map<String, dynamic> parameters,
    String? customDescription,
  }) {
    String contentTemplate = '';

    switch (gameType) {
      case GameType.math:
        contentTemplate =
            '''
"content": {
  "topic": "${parameters['topic'] ?? 'toplama'}",
  "questionCount": ${parameters['questionCount'] ?? 10},
  "questions": [
    {
      "question": "soru metni",
      "answers": ["a", "b", "c", "d"],
      "correctIndex": 0,
      "explanation": "açıklama"
    }
  ]
}
''';
        break;
      case GameType.word:
        contentTemplate =
            '''
"content": {
  "wordCount": ${parameters['wordCount'] ?? 10},
  "words": [
    {
      "word": "kelime",
      "clue": "ipucu",
      "difficulty": "easy"
    }
  ]
}
''';
        break;
      case GameType.memory:
        contentTemplate =
            '''
"content": {
  "pairs": ${parameters['pairCount'] ?? 6},
  "items": [
    {
      "id": 1,
      "text": "item",
      "pair": 2
    }
  ]
}
''';
        break;
      case GameType.logic:
        contentTemplate =
            '''
"content": {
  "puzzles": ${parameters['puzzleCount'] ?? 5},
  "puzzleSet": [
    {
      "question": "soru",
      "answer": "cevap",
      "options": ["a", "b", "c"]
    }
  ]
}
''';
        break;
      default:
        contentTemplate = '''
"content": {
  "description": "Oyun içeriği"
}
''';
    }

    return '''
Türkçe, çocuklara yönelik eğitici bir mini oyun oluştur.

Oyun Türü: ${gameType.name}
Zorluk: $difficulty
Hedef Yaş: $ageGroup
${customDescription != null ? 'Tema: $customDescription' : ''}

Ek Parametreler:
${jsonEncode(parameters)}

⚠️ KURALLAR:
- SADECE JSON döndür
- Başka açıklama yazma
- Emoji kullanabilirsin (ama JSON string'in içinde olsun)
- Pedagojik ve eğitici olmalı
- Türkçe metin kullan

JSON ŞEMASı:
{
  "meta": {
    "gameType": "${gameType.name}",
    "difficulty": "$difficulty",
    "ageGroup": $ageGroup,
    "title": "Oyun Başlığı"
  },
  $contentTemplate,
  "ui": {
    "hints": ["ipucu1", "ipucu2"],
    "encouragements": ["çok iyi!", "harika!", "mükemmel!"],
    "colors": ["#667eea", "#764ba2"]
  }
}
''';
  }

  // ============ API CALL (SAFE) ============

  Future<String> _safeGenerate(String prompt) async {
    try {
      final response = await _model
          .generateContent([Content.text(prompt)])
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Gemini API timeout (30s)');
            },
          );

      if (response.text == null || response.text!.isEmpty) {
        throw Exception('Gemini API boş cevap döndü');
      }

      return response.text!;
    } on Exception catch (e) {
      throw Exception('Gemini API hatası: $e');
    }
  }

  // ============ JSON PARSING ============

  String _extractJson(String text) {
    try {
      final match = RegExp(r'\{[\s\S]*\}', dotAll: true).firstMatch(text);
      if (match == null) {
        throw Exception('JSON bloku bulunamadı');
      }
      return match.group(0)!;
    } catch (e) {
      throw Exception('JSON çıkarma hatası: $e');
    }
  }

  // ============ VALIDATION ============

  void _validateGameSchema(Map<String, dynamic> gameData) {
    // Temel alanlar
    if (!gameData.containsKey('meta') ||
        !gameData.containsKey('content') ||
        !gameData.containsKey('ui')) {
      throw Exception('Geçersiz oyun şeması: meta, content, ui gerekli');
    }

    // Meta doğrulaması
    final meta = gameData['meta'] as Map<String, dynamic>?;
    if (meta == null ||
        !meta.containsKey('gameType') ||
        !meta.containsKey('difficulty')) {
      throw Exception('Meta eksik: gameType ve difficulty gerekli');
    }

    print('✅ Şema doğrulandı');
  }

  // ============ NORMALIZATION ============

  Map<String, dynamic> _normalizeGameData(
    Map<String, dynamic> gameData,
    GameType gameType,
    String difficulty,
    int ageGroup,
  ) {
    return {
      'meta': {
        'gameType': gameType.name,
        'difficulty': difficulty,
        'ageGroup': ageGroup,
        'title': gameData['meta']?['title'] ?? '${gameType.displayName} Oyunu',
        'emoji': gameType.emoji,
        'createdAt': DateTime.now().toIso8601String(),
      },
      'content': gameData['content'] ?? {},
      'ui': {
        'hints': (gameData['ui']?['hints'] as List?)?.cast<String>() ?? [],
        'encouragements':
            (gameData['ui']?['encouragements'] as List?)?.cast<String>() ?? [],
        'colors': (gameData['ui']?['colors'] as List?)?.cast<String>() ?? [],
      },
    };
  }

  // ============ UTILITIES ============

  /// 🔌 API Bağlantısını test et
  Future<bool> testConnection() async {
    try {
      final res = await _model
          .generateContent([Content.text('Sadece "OK" yaz')])
          .timeout(const Duration(seconds: 10));
      return res.text?.contains('OK') ?? false;
    } catch (e) {
      print('❌ Bağlantı testi başarısız: $e');
      return false;
    }
  }

  /// 📊 Oyun istatistiklerini al (debug)
  Map<String, dynamic> getGameStats(Map<String, dynamic> gameData) {
    final content = gameData['content'] as Map<String, dynamic>? ?? {};
    return {
      'type': gameData['meta']?['gameType'] ?? 'unknown',
      'difficulty': gameData['meta']?['difficulty'] ?? 'unknown',
      'contentKeys': content.keys.toList(),
      'hintCount': (gameData['ui']?['hints'] as List?)?.length ?? 0,
    };
  }
}
