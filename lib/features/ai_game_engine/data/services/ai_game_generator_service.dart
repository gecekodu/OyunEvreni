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

  /// 🎮 HTML 3D OYUN OLUŞTUR (Three.js ile)
  Future<String> generateHTML3DGame({
    required String userDescription,
    required String difficulty,
    required int targetAge,
  }) async {
    print('🎮 HTML 3D oyun uretiliyor: "$userDescription"');

    final prompt = '''
Sen profesyonel bir HTML5/Three.js oyun geliştiricisisin. Asagidaki açıklamaya gore TAM ÖZELLIKLI, KAPSAMLI, PROFESYONEL bir 3D oyun oluştur.

🎮 OYUN ACIKLAMASI: "$userDescription"
📊 ZORLUK: $difficulty (easy, medium, hard)
👶 HEDEF YAS: $targetAge

═══════════════════════════════════════════════════════════════
🎯 OYUN GEREKSINIMLERI (EKSIK BIRAKMA!):
═══════════════════════════════════════════════════════════════

1. **TEMEL YAPI**:
   ✓ Complete HTML5 oyun - tek dosya, self-contained
   ✓ Three.js CDN: https://cdnjs.cloudflare.com/ajax/libs/three.js/r128/three.min.js
   ✓ Responsive design (mobile + desktop)
   ✓ MINIMUM 500 SATIR JavaScript kodu

2. **3D SAHNE ve KAMERA**:
   ✓ PerspectiveCamera optimal açıyla
   ✓ OrbitControls veya custom camera control
   ✓ Dinamik aydınlatma (AmbientLight + DirectionalLight + PointLight)
   ✓ Gölge sistemi (castShadow, receiveShadow)
   ✓ Skybox veya gradient background
   ✓ Fog effect (atmosfer için)

3. **OYUNCU KARAKTERI**:
   ✓ 3D model (basit geometrilerden oluşmuş karakter)
   ✓ Smooth hareket animasyonları
   ✓ Klavye (WASD/Ok tuşları) + touch kontrol
   ✓ Zıplama (jump) mekanigi
   ✓ Hız ve ivme fizik sistemi
   ✓ Karakter rotasyonu ve yön değiştirme

4. **OYUN DÜNYASI**:
   ✓ Minimum 20x20 birim 3D zemin
   ✓ Engeller, platformlar, toplanabilir objeler (minimum 15 adet)
   ✓ Çeşitli renk ve geometriler (küp, küre, silindir, koni vb.)
   ✓ Parçacık efektleri (collecting, win/lose)
   ✓ Rastgele oluşturulan objeler (procedural)
   ✓ Arka plan dekorasyon (ağaçlar, binalar, bulutlar)

5. **OYUN MEKANİKLERİ**:
   ✓ Puan sistemi (score) ekranda sürekli göster
   ✓ Can/sağlık sistemi (health bar)
   ✓ Süre sayacı (timer) - opsiyonel
   ✓ Seviye sistemi (3+ level)
   ✓ Zorluk artışı (difficulty progression)
   ✓ Power-ups veya bonus itemlar
   ✓ Düşman/engel AI (basit hareket pattern)
   ✓ Collision detection (çarpışma kontrolü)

6. **GÖRSEL EFEKTLER**:
   ✓ Parçacık patlamaları (collecting item)
   ✓ Glow effect önemli objeler için
   ✓ Smooth kamera geçişleri
   ✓ Screen shake (çarpışmada)
   ✓ Color transitions
   ✓ Trail effect (iz bırakma)

7. **SES ve MÜZİK** (opsiyonel ama önerilen):
   ✓ Web Audio API kullan
   ✓ Basit ses efektleri (beep, collect, jump)
   ✓ Arka plan müziği (synthesized)

8. **UI ve HUD**:
   ✓ Başlangıç ekranı (Start Game butonu)
   ✓ Oyun içi HUD (score, health, level)
   ✓ Pause menüsü
   ✓ Kazanma/kaybetme ekranı
   ✓ Restart butonu
   ✓ Kontrol açıklaması
   ✓ Tüm metinler TÜRKÇE

9. **PERFORMANS ve OPTIMIZASYON**:
   ✓ RequestAnimationFrame kullan
   ✓ Object pooling (obje yeniden kullanımı)
   ✓ Ekran dışı objeleri kaldır
   ✓ FPS göstergesi (debug için)

10. **KOD KALİTESI**:
    ✓ Clean code, yorumlarla açıklanmış
    ✓ Object-oriented yapı (class kullan)
    ✓ Error handling (try-catch)
    ✓ Console.log debug mesajları
    ✓ Değişken isimlerinde Türkçe karakterler YOK

═══════════════════════════════════════════════════════════════
📝 ZORLUĞa GÖRE AYARLAMALAR:
═══════════════════════════════════════════════════════════════
EASY: Yavaş hareket, az engel, büyük hedefler
MEDIUM: Normal hız, orta yoğunluk engeller
HARD: Hızlı tempo, çok engel, küçük hedefler, zaman limiti

═══════════════════════════════════════════════════════════════
🎨 ÖRNEK OYUN TÜRLERI:
═══════════════════════════════════════════════════════════════
- Matematik: Uçan sayıları yakala, doğru işlemleri seç
- Araba yarışı: 3D pist, sürtünmeli zemin, checkpointler
- Koleksiyonlama: Renkli küpleri topla, engelleri atla
- Platform: Yüksek platformlara zıpla, düşme
- Koşu: Sonsuz koşu, rastgele engeller

═══════════════════════════════════════════════════════════════
⚠️ KURALLARI KATI TAKIP ET:
═══════════════════════════════════════════════════════════════
1. DOCTYPE html ile başla
2. Tüm CSS <style> tagında
3. Tüm JavaScript <script> tagında
4. Harici dosya SADECE Three.js CDN
5. Mobil + desktop responsive
6. MINIMUM 500 satır JavaScript
7. Açıklama veya markdown YOK, sadece HTML kodu
8. Oyun TAM ÇALIŞIR DURUMDA dön

═══════════════════════════════════════════════════════════════
� TEMEL OYUN ŞABLONU (CUSTOMIZE ET):
═══════════════════════════════════════════════════════════════
$baseTemplate

═══════════════════════════════════════════════════════════════
🔧 SENIN GÖREVIN:
═══════════════════════════════════════════════════════════════
1. Yukarıdaki temel şablonu al
2. "$userDescription" açıklamasına uygun olarak ÖZELLEŞTİR:
   - Oyun adını ve açıklamasını değiştir
   - Player modelini tema ile uyumlu yap (araba, hayvan, karakter vb.)
   - Collectible objeleri temaya göre tasarla
   - Enemy objeleri temaya göre tasarla
   - Ek mekanikler ekle (zıplama, özel güçler, vb.)
   - Arka plan ve renkleri temaya uygun ayarla
   - Ses efektleri ekle (Web Audio API)
   - Parçacık efektleri ekle
   - Zorluk seviyesine göre ayarla ($difficulty)
   - Yaşa uygun görsellik ($targetAge)

3. EKLENMESI GEREKEN ÖZELLIKLER:
   ✓ Jump mekanigi (Space tuşu)
   ✓ Parçacık efektleri (collect, hit)
   ✓ Ses efektleri (beep sounds)
   ✓ Power-ups (hız, kalkan vb.)
   ✓ Daha karmaşık enemy AI
   ✓ Arka plan dekorasyonları
   ✓ Smooth animations
   ✓ Score multiplier
   ✓ Combo system

4. KOD UZUNLUĞU:
   ✓ MINIMUM 800 satır JavaScript
   ✓ Tüm özellikler eksiksiz implement edilmeli
   ✓ Yorumlar ve clean code

═══════════════════════════════════════════════════════════════
📤 ÇIKTI FORMATI:
═══════════════════════════════════════════════════════════════
SADECE ÖZELLEŞTİRİLMİŞ, TAM HTML5 kodunu döndür. 
Hiçbir açıklama, markdown, ```html tag veya ek metin ekleme.

Şimdi "$userDescription" için yukarıdaki şablonu özelleştir ve genişlet!
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
