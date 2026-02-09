// 🤖 GEMİNİ AI SERVICE - Oyun İçeriği Üretimi

import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:convert';

class GeminiGameService {
  late GenerativeModel _model;
  final String apiKey;

  GeminiGameService({required this.apiKey}) {
    // 🤖 Gemini 2.5 Flash Lite - Lightweight model (hızlı, az token tüket, daha az rate limit)
    // Rate limit dolursa: gemini-1.5-flash'e fallback
    _model = GenerativeModel(
      model: 'gemini-2.5-flash-lite',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.6,
        topK: 40,
        topP: 0.9,
        maxOutputTokens: 4000, // Lite için daha uygun
      ),
    );
  }

  /// 🔄 Fallback Model (rate limit hatası durumunda)
  GenerativeModel _getFallbackModel() {
    return GenerativeModel(
      model: 'gemini-1.5-flash', // Eski ama stabil model
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.5,
        maxOutputTokens: 3000,
      ),
    );
  }

  /// 🎮 Matematik Oyunu İçeriği Oluştur
  Future<Map<String, dynamic>> generateMathGameContent({
    required String topic, // addition, subtraction, multiplication, division
    required String difficulty, // easy, medium, hard
    String? customDescription, // Kullanıcının özel açıklaması
    String? userPrompt, // 🤖 Kullanıcının oyun istemi
    int questionCount = 10,
    int ageGroup = 8, // 6-8, 8-10, 10-12
  }) async {
    try {
      // ⭐ USER PROMPT'TA TEMA KONTROLÜ - İnteraktif oyun talebi varsa uyar
      bool isThemeRequest = userPrompt != null && 
          (userPrompt.contains('araba') || 
           userPrompt.contains('yarış') ||
           userPrompt.contains('oyun') ||
           userPrompt.contains('interaktif') ||
           userPrompt.contains('deneyim') ||
           userPrompt.contains('hikaye'));
      
      final gameFormat = isThemeRequest 
          ? '''ÖZEL: Bu oyun TEMATİK/İNTERAKTİF bir oyun olmalı! Sadece soru sormak yerine, 
          ortam/senaryoya dayalı bir deneyim yarat. Örneğin "araba yarışı" ise, yarışa katılma 
          simülasyonu, puan sistemi, hız/engeller gibi dinamik öğeler ekle.'''
          : '';
      
      final prompt = '''
Türkçe olarak öğretici bir oyun için içerik oluştur.

Parametreler:
- Konu: $topic
- Zorluk: $difficulty
- Soru Sayısı: $questionCount
- Hedef Yaş: $ageGroup yaş
${customDescription != null ? '- Tema: $customDescription (Bu tema oyunun merkezinde olmalı!)' : ''}
${userPrompt != null && userPrompt.isNotEmpty ? '- 🎯 KULLANICI TALEBİ: "$userPrompt"\n🎯 ÇOK ÖNEMLİ: Bu talebi oyunun temel yapısına entegre et! Kullanıcı specific bir deneyim/tema istiyorsa, bunu prioritize et.' : ''}
$gameFormat

OYUN YAPISI KURALLARI:
${isThemeRequest ? '✅ TEMA-TABALI: Tema/senaryoya dayalı, interaktif, deneyim odaklı' : '✅ KLASIK: Soru-cevap bazlı'}
✅ Eğlenceli, öğretici ve yaş-uygun
✅ Dinamik ve katılımcı

JSON formatında şu yapıda cevap ver (başka bir şey yazma, sadece JSON):
{
  "title": "Oyun başlığı",
  "description": "Kısa açıklama",
  "questions": [
    {
      "question": "Soru metni",
      "answers": ["Cevap1", "Cevap2", "Cevap3", "Cevap4"],
      "correctIndex": 0,
      "explanation": "Açıklama"
    }
  ],
  "hints": ["İpucu1", "İpucu2"],
  "encouragements": ["Çok iyi!", "Harika!", "Mükemmel!"]
}
''';

      final response = await _model.generateContent([
        Content.text(prompt),
      ]);

      if (response.text == null) {
        throw Exception('Gemini API boş cevap döndü');
      }

      // JSON'ı parse et
      final jsonStr = response.text!;
      final cleanJson = _extractJson(jsonStr);
      final gameData = jsonDecode(cleanJson);

      return gameData;
    } catch (e) {
      throw Exception('Matematik oyunu içeriği oluşturulamadı: $e');
    }
  }

  /// 📝 Kelime Oyunu İçeriği Oluştur
  Future<Map<String, dynamic>> generateWordGameContent({
    required String difficulty, // easy, medium, hard
    String? userPrompt, // 🤖 Kullanıcının oyun istemi
    int wordCount = 10,
    int ageGroup = 8,
  }) async {
    try {
      final prompt = '''
Türkçe olarak bir kelime oyunu için içerik oluştur.

Parametreler:
- Zorluk: $difficulty
- Kelime Sayısı: $wordCount
- Hedef Yaş: $ageGroup yaş
${userPrompt != null && userPrompt.isNotEmpty ? '- 🎯 KULLANICI TALEBİ: "$userPrompt"\n🎯 ÖNEMLI: Kelime oyununu bu talebe uygun temada oluştur (örn. araba, spor, doğa vb.)' : ''}

OYUN KURALLARI:
✅ Sözcükleri yakala, tamamla veya eşleştir
✅ Tema-uyumlu kelimeler seç
✅ İnteraktif ve eğlenceli

JSON formatında cevap ver (başka şey yazma, sadece JSON):
{
  "title": "Kelime Oyunu",
  "description": "Açıklama",
  "words": [
    {
      "word": "Kelime",
      "hint": "İpucu",
      "letters": ["K", "e", "l", "i", "m", "e"],
      "scrambled": ["e", "m", "i", "l", "e", "K"]
    }
  ],
  "hints": ["Genel ipucu1", "Genel ipucu2"],
  "encouragements": ["Çok iyi!", "Harika!"]
}
''';

      final response = await _model.generateContent([
        Content.text(prompt),
      ]);

      if (response.text == null) {
        throw Exception('Gemini API boş cevap döndü');
      }

      final cleanJson = _extractJson(response.text!);
      return jsonDecode(cleanJson);
    } catch (e) {
      throw Exception('Kelime oyunu içeriği oluşturulamadı: $e');
    }
  }

  /// 🎨 Renk Oyunu İçeriği Oluştur
  Future<Map<String, dynamic>> generateColorGameContent({
    required String difficulty,
    String? userPrompt, // 🤖 Kullanıcının oyun istemi
    int colorCount = 8,
    int ageGroup = 8,
  }) async {
    try {
      final prompt = '''
Türkçe olarak bir renk eşleştirme/ayırt etme oyunu için içerik oluştur.

Parametreler:
- Zorluk: $difficulty
- Renk Sayısı: $colorCount
- Hedef Yaş: $ageGroup yaş
${userPrompt != null && userPrompt.isNotEmpty ? '- 🎯 KULLANICI TALEBİ: "$userPrompt"\n🎯 ÖNEMLI: Renk oyununu bu temaya uygun yap (örn. araba renkleri, hayvan renkleri vb.)' : ''}

OYUN KURALLARI:
✅ Renk tanıma, eşleştirme veya ayırt etme
✅ Tema-uyumlu öğeler ekle
✅ Interaktif ve görsel

JSON formatında cevap ver:
{
  "title": "Renk Oyunu",
  "description": "Açıklama",
  "colors": [
    {
      "name": "Kırmızı",
      "hex": "#FF0000",
      "rgb": "rgb(255, 0, 0)"
    }
  ],
  "challenges": [
    {
      "question": "Bu renk adı nedir?",
      "colorIndex": 0,
      "answers": ["Kırmızı", "Sarı", "Mavi", "Yeşil"],
      "correctIndex": 0
    }
  ],
  "encouragements": ["Çok iyi!", "Harika!"]
}
''';

      final response = await _model.generateContent([
        Content.text(prompt),
      ]);

      final cleanJson = _extractJson(response.text!);
      return jsonDecode(cleanJson);
    } catch (e) {
      throw Exception('Renk oyunu içeriği oluşturulamadı: $e');
    }
  }

  /// 🧩 Bulmaca Oyunu İçeriği Oluştur
  Future<Map<String, dynamic>> generatePuzzleGameContent({
    required String difficulty,
    String? userPrompt,
    int puzzleCount = 5,
    int ageGroup = 8,
  }) async {
    try {
      final userPromptSection = userPrompt != null && userPrompt.isNotEmpty
          ? '- Kullanici Talabi: "$userPrompt"\n- ONEMLI: Bulmacalari bu tema/konuya uygun yap'
          : '';

      final prompt = '''
Turkce olarak mantik/gorsel bulmaca oyunu icin icerik olustur.

Parametreler:
- Zorluk: $difficulty
- Bulmaca Sayisi: $puzzleCount
- Hedef Yas: $ageGroup yas
$userPromptSection

OYUN KURALLARI:
- Mantik, gorsel veya kombinasyon bulmacalari
- Tema-uyumlu bulmacalar
- Cozumu gerektiren, egenceli bulmacalar

JSON formatinda cevap ver (sadece JSON):
{
  "title": "Mantik Bulmacalari",
  "description": "Aciklama",
  "puzzles": [
    {
      "question": "Bulmaca sorusu",
      "image_description": "Resim aciklamasi",
      "options": ["Secenekl", "Secenek2", "Secenek3"],
      "correctIndex": 0,
      "explanation": "Aciklama"
    }
  ],
  "encouragements": ["Cok iyi!", "Harika!"]
}
''';

      final response = await _model.generateContent([
        Content.text(prompt),
      ]);

      final cleanJson = _extractJson(response.text!);
      return jsonDecode(cleanJson);
    } catch (e) {
      throw Exception('Bulmaca oyunu icerigi olusturulamadi: $e');
    }
  }

  Future<Map<String, dynamic>> generateMemoryGameContent({
    required String difficulty,
    String? userPrompt,
    int pairCount = 6,
    int ageGroup = 8,
  }) async {
    try {
      final userPromptSection = userPrompt != null && userPrompt.isNotEmpty
          ? '- Kullanici Talabi: "$userPrompt"\n- ONEMLI: Hafiza oyununu bu temali ogelelerle olustur'
          : '';

      final prompt = '''
Turkce olarak bir hafiza/eslesstirme oyunu icin icerik olustur.

Parametreler:
- Zorluk: $difficulty
- Kart Cifti Sayisi: $pairCount
- Hedef Yas: $ageGroup yas
$userPromptSection

OYUN KURALLARI:
- Kartlari aci ve eslestir
- Tema-uyumlu kart ciftleri
- Hafiza becerisini test et
- Emoji, resim aciklama veya kelimeler kullan

JSON formatinda cevap ver (sadece JSON):
{
  "title": "Hafiza Oyunu",
  "description": "Aciklama",
  "pairs": [
    {
      "id": 1,
      "text": "Muz",
      "emoji": "🍌",
      "pairId": 1
    },
    {
      "id": 2,
      "text": "Muz",
      "emoji": "🍌",
      "pairId": 1
    }
  ],
  "encouragements": ["Cok iyi!", "Harika!"]
}
''';

      final response = await _model.generateContent([
        Content.text(prompt),
      ]);

      final cleanJson = _extractJson(response.text!);
      return jsonDecode(cleanJson);
    } catch (e) {
      throw Exception('Hafiza oyunu icerigi olusturulamadi: $e');
    }
  }

  Future<String> generateUserRecommendation({
    required String userName,
    required int gamesCreated,
    required int totalPlays,
  }) async {
    try {
      final prompt = '''
Kisa (1-2 cumle) ve cesur bir yorum yaz. Kisi:
- Ad: $userName
- Olusturulan Oyun: $gamesCreated
- Toplam Oynama: $totalPlays

Ornek: "Matematik ustasi! 🏆"
''';

      final response = await _model.generateContent([
        Content.text(prompt),
      ]);

      return response.text ?? 'Harika oyun yapicisi!';
    } catch (e) {
      return 'Yetenekli oyun yapicisi!';
    }
  }

  /// JSON'ı metinden çıkar (başında/sonunda fazla text varsa)
  String _extractJson(String text) {
    final jsonRegex = RegExp(r'\{[\s\S]*\}', dotAll: true);
    final match = jsonRegex.firstMatch(text);
    if (match != null) {
      return match.group(0)!;
    }
    return text;
  }

  /// Gemini API'nin çalışıp çalışmadığını test et
  Future<bool> testConnection() async {
    try {
      final response = await _model.generateContent([
        Content.text('Merhaba! Bir kelime söyle.'),
      ]);
      return response.text != null && response.text!.isNotEmpty;
    } catch (e) {
      print('⚠️ Gemini bağlantı hatası: $e');
      return false;
    }
  }
}
