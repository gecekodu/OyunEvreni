// 🤖 GEMİNİ AI SERVICE - Oyun İçeriği Üretimi

import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:convert';

class GeminiGameService {
  late GenerativeModel _model;
  final String apiKey;

  GeminiGameService({required this.apiKey}) {
    // Gemini 2.5 Flash - En uygun model (hızlı, ucuz, yetenekli)
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 8000,
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
      final prompt = '''
Bir matematik oyunu için soru setini türkçe olarak oluştur. 

Parametreler:
- Konu: $topic
- Zorluk: $difficulty
- Soru Sayısı: $questionCount
- Hedef Yaş: $ageGroup yaş
${customDescription != null ? '- Tema/Açıklama: $customDescription (Bu temayı sorulara yansıt)' : ''}
${userPrompt != null && userPrompt.isNotEmpty ? '- ⭐ KULLANICI İSTEMİ: $userPrompt\n⭐ Lütfen bu istekleri dikkate al! Oyunu bu isteklere uygun şekilde özelleştir.' : ''}

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
Türkçe bir kelime oyunu için kelime setini oluştur.

Parametreler:
- Zorluk: $difficulty
- Kelime Sayısı: $wordCount
- Hedef Yaş: $ageGroup yaş
${userPrompt != null && userPrompt.isNotEmpty ? '- ⭐ KULLANICI İSTEMİ: $userPrompt\n⭐ Lütfen bu istekleri dikkate al!' : ''}

JSON formatında cevap ver (başka şey yazma):
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
Türkçe bir renk eşleştirme oyunu için içerik oluştur.

Parametreler:
- Zorluk: $difficulty
- Renk Sayısı: $colorCount
- Hedef Yaş: $ageGroup yaş
${userPrompt != null && userPrompt.isNotEmpty ? '- ⭐ KULLANICI İSTEMİ: $userPrompt\n⭐ Lütfen bu istekleri dikkate al!' : ''}

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
    String? userPrompt, // 🤖 Kullanıcının oyun istemi
    int puzzleCount = 5,
    int ageGroup = 8,
  }) async {
    try {
      final prompt = '''
Türkçe bir mantık bulmacası oyunu için içerik oluştur.

Parametreler:
- Zorluk: $difficulty
- Bulmaca Sayısı: $puzzleCount
- Hedef Yaş: $ageGroup yaş
${userPrompt != null && userPrompt.isNotEmpty ? '- ⭐ KULLANICI İSTEMİ: $userPrompt\n⭐ Lütfen bu istekleri dikkate al!' : ''}

JSON formatında (sadece JSON):
{
  "title": "Mantık Bulmacaları",
  "description": "Açıklama",
  "puzzles": [
    {
      "question": "Bulmaca sorusu",
      "image_description": "Resim açıklaması",
      "options": ["Seçenek1", "Seçenek2", "Seçenek3"],
      "correctIndex": 0,
      "explanation": "Açıklama"
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
      throw Exception('Bulmaca oyunu içeriği oluşturulamadı: $e');
    }
  }

  /// 🧠 Hafıza Oyunu İçeriği Oluştur
  Future<Map<String, dynamic>> generateMemoryGameContent({
    required String difficulty,
    String? userPrompt, // 🤖 Kullanıcının oyun istemi
    int pairCount = 6,
    int ageGroup = 8,
  }) async {
    try {
      final prompt = '''
Türkçe bir hafıza oyunu için kartları oluştur.

Parametreler:
- Zorluk: $difficulty
- Kart Çifti Sayısı: $pairCount
- Hedef Yaş: $ageGroup yaş
${userPrompt != null && userPrompt.isNotEmpty ? '- ⭐ KULLANICI İSTEMİ: $userPrompt\n⭐ Lütfen bu istekleri dikkate al!' : ''}

JSON formatında (sadece JSON):
{
  "title": "Hafıza Oyunu",
  "description": "Açıklama",
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
  "encouragements": ["Çok iyi!", "Harika!"]
}
''';

      final response = await _model.generateContent([
        Content.text(prompt),
      ]);

      final cleanJson = _extractJson(response.text!);
      return jsonDecode(cleanJson);
    } catch (e) {
      throw Exception('Hafıza oyunu içeriği oluşturulamadı: $e');
    }
  }

  /// Kullanıcı profili için AI tarafından yazılan açıklama oluştur
  Future<String> generateUserRecommendation({
    required String userName,
    required int gamesCreated,
    required int totalPlays,
  }) async {
    try {
      final prompt = '''
Kısa (1-2 cümle) ve cesur bir yorum yaz. Kişi:
- Ad: $userName
- Oluşturduğu Oyun: $gamesCreated
- Toplam Oynama: $totalPlays

Örnek: "Matematik ustası! 🏆"
''';

      final response = await _model.generateContent([
        Content.text(prompt),
      ]);

      return response.text ?? 'Harika oyun yapıcısı!';
    } catch (e) {
      return 'Yetenekli oyun yapıcısı!';
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
