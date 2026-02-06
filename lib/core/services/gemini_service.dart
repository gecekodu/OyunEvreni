// 🤖 Gemini API Service - AI Oyun Üretimi

import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../errors/exceptions.dart';

class GeminiService {
  late GenerativeModel _model;
  final String apiKey;

  // ⚠️ ZORUNLU: Kendi Gemini API anahtarını ekle
  // https://ai.google.dev/tutorials/setup
  GeminiService({required this.apiKey}) {
    _model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: apiKey,
    );
  }

  /// 🎮 Oyun senaryosu üret
  /// Gemini, ders/konu/sınıf/zorluk bilgisine göre oyun JSON'u üretir
  Future<Map<String, dynamic>> generateGameJson({
    required String lesson,
    required String topic,
    required String grade,
    required String difficulty,
    required String learningObjective,
  }) async {
    try {
      final prompt = _buildGameGenerationPrompt(
        lesson: lesson,
        topic: topic,
        grade: grade,
        difficulty: difficulty,
        learningObjective: learningObjective,
      );

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      if (response.text == null || response.text!.isEmpty) {
        throw GeminiException(
          message: 'Gemini yanıt vermedi',
          code: 'EMPTY_RESPONSE',
        );
      }

      // JSON'u çıkart (```json ... ``` arasında)
      final jsonString = _extractJson(response.text!);
      final gameJson = _parseGameJson(jsonString);

      print('✅ Oyun JSON üretildi: ${gameJson['title']}');
      return gameJson;
    } catch (e) {
      if (e is GeminiException) rethrow;
      throw GeminiException(
        message: 'Oyun üretilirken hata: $e',
        code: 'GAME_GENERATION_ERROR',
      );
    }
  }

  /// 💡 Oyun için ipuçları üret
  Future<List<String>> generateHints({
    required String gameTitle,
    required String topic,
    required String difficulty,
  }) async {
    try {
      final prompt = '''
      Şu oyun için 3 adet kısa ve yardımcı ipucu üret:
      
      Oyun: $gameTitle
      Konu: $topic
      Zorluk: $difficulty
      
      Her ipucunu ayrı bir satırda ver.
      Cevap sadece ipuçları olsun, başka açıklama yapma.
      ''';

      final response = await _model.generateContent([Content.text(prompt)]);

      if (response.text == null || response.text!.isEmpty) {
        return [];
      }

      return response.text!
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .map((line) => line.replaceAll(RegExp(r'^[0-9]+\.\s*'), ''))
          .toList();
    } catch (e) {
      print('❌ İpucu üretilirken hata: $e');
      return [];
    }
  }

  /// 📊 Oyun sonucuna göre geri bildirim üret
  Future<String> generateFeedback({
    required String gameTitle,
    required int score,
    required bool completed,
    required int timeSpent,
  }) async {
    try {
      final statusText = completed ? 'başarıyla tamamladı' : 'tamamlayamadı';
      final prompt = '''
      Bir öğrenci "$gameTitle" adlı eğitici oyunu $statusText.
      Skoru: $score
      Harcadığı süre: $timeSpent saniye
      
      Öğrenciye kısa ve teşvik edici bir geri bildirim mesajı yaz.
      Mesaj Türkçe olsun ve çocuk-dostu bir ton kullan.
      En fazla 2 cümle olsun.
      ''';

      final response = await _model.generateContent([Content.text(prompt)]);

      return response.text ?? 'Oyun sonucu kaydedildi. Tekrar oynamak isterseniz davetim açık!';
    } catch (e) {
      print('❌ Geri bildirim üretilirken hata: $e');
      return 'Oyun tamamlandı!';
    }
  }

  /// 🔧 Oyun gelişim önerileri
  Future<List<String>> generateImprovementSuggestions({
    required String gameTitle,
    required double currentRating,
    required int playCount,
  }) async {
    try {
      final prompt = '''
      Şu oyunun kalitesini artırmak için 3 öneri yap:
      
      Oyun: $gameTitle
      Mevcut puan: $currentRating/5
      Oynama sayısı: $playCount
      
      Öneriler:
      1. Oyun mekaniklerini geliştir
      2. Öğrenme hedeflerini güçlendir
      3. Kullanıcı deneyimini iyileştir
      
      Her önerileri bir satırda ve kısa tut.
      ''';

      final response = await _model.generateContent([Content.text(prompt)]);

      if (response.text == null || response.text!.isEmpty) {
        return [];
      }

      return response.text!
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .map((line) => line.replaceAll(RegExp(r'^[0-9]+\.\s*'), ''))
          .toList();
    } catch (e) {
      print('❌ Öneriler üretilirken hata: $e');
      return [];
    }
  }

  // 🔨 Oyun JSON üretim promptu
  String _buildGameGenerationPrompt({
    required String lesson,
    required String topic,
    required String grade,
    required String difficulty,
    required String learningObjective,
  }) {
    return '''
Aşağıda açıklanan eğitici bir HTML oyunu için JSON tanımı üret.

DERS: $lesson
KONU: $topic
SINIF: $grade
ZORLUK: $difficulty
ÖĞRENİM HEDEFİ: $learningObjective

Bu JSON şemasına uygun bir oyun tanımı döndür:

{
  "gameType": "string (mirror_reflection, puzzle_match, drag_drop, quiz, vb.)",
  "title": "string (Türkçe oyun adı)",
  "description": "string (Türkçe açıklama)",
  "level": "$difficulty",
  "goal": "string (Türkçe oyun hedefi)",
  "objects": [
    {
      "type": "string (light, mirror, target, obstacle, vb.)",
      "x": "number",
      "y": "number",
      "angle": "number (optional)",
      "color": "string (optional)"
    }
  ],
  "rules": ["string (Türkçe kurallar)"],
  "successCriteria": {
    "hitTarget": "boolean",
    "minScore": "number (optional)"
  },
  "maxTime": "number (saniye, optional)"
}

UYARILARI:
- Oyun eğitici ve eğlenceli olmalı
- Hedef oyuncu yaşına uygun olmalı
- JSON geçerli olmalı
- Türkçe metinleri kullan
- Sadece JSON döndür, açıklama yapma

Üretilen JSON'u ```json ... ``` arasında döndür.
''';
  }

  // 🔍 JSON'u metinden çıkart
  String _extractJson(String text) {
    final regex = RegExp(r'```json\s*([\s\S]*?)\s*```', multiLine: true);
    final match = regex.firstMatch(text);
    if (match != null) {
      return match.group(1)!;
    }
    // Eğer ```json yoksa direkt JSON dönmüş olabilir
    return text;
  }

  // ✔️ JSON'u parse et ve doğrula
  Map<String, dynamic> _parseGameJson(String jsonString) {
    try {
      final json = jsonDecode(jsonString);
      
      // Gerekli alanları kontrol et
      if (!json.containsKey('gameType') ||
          !json.containsKey('title') ||
          !json.containsKey('objects')) {
        throw GeminiException(
          message: 'Oyun JSON\'u eksik alanlar içeriyor',
          code: 'INVALID_GAME_JSON',
        );
      }

      return json as Map<String, dynamic>;
    } catch (e) {
      throw GeminiException(
        message: 'JSON parse hatası: $e',
        code: 'JSON_PARSE_ERROR',
      );
    }
  }
}

// ℹ️ Gemini Model Seçenekleri (API Limitleri)
// - gemini-pro: Metin → Metin (Bu projede kullanılıyor)
// - gemini-pro-vision: Görüntü + Metin desteği (ileride eklenebilir)

// 🔑 API Key Yönetimi
// 1. https://ai.google.dev/tutorials/setup adresine git
// 2. "Get API Key" butonuna tıkla
// 3. Anahtarı main.dart'ta GeminiService initialize ederken kullan:
//    GeminiService(apiKey: 'YOUR_GEMINI_API_KEY')
