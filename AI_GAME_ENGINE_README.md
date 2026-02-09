# 🤖 AI GAME ENGINE - GEMİNİ 2D OYUN ÜRETİCİ

## 🎯 Genel Bakış

**AI Game Engine**, Gemini yapay zekası kullanarak doğal dil açıklamalarından otomatik olarak 2D eğitim oyunları oluşturan devrim niteliğinde bir sistemdir. Flame engine üzerine kurulu bu sistem, kullanıcıların kodlama bilgisi olmadan sadece oyun fikirlerini tarif ederek tam işlevsel oyunlar oluşturmasına olanak tanır.

## ✨ Özellikler

### 🎮 Oyun Oluşturma Yöntemleri

1. **Doğal Dil Girişi**
   - Kullanıcı: "7 yaş için toplama öğreten platform oyunu yap"
   - AI: Tam işlevsel oyun config'i üretir

2. **Şablon Tabanlı**
   - Platform oyunu (Super Mario benzeri)
   - Koleksiyon oyunu (Pac-Man benzeri)
   - Puzzle oyunu (Sokoban, Tetris benzeri)
   - Eğitim oyunu (Soru-cevap odaklı)
   - Runner oyunu (Endless runner)
   - Shooter oyunu (Space shooter)

### 📚 Eğitim Entegrasyonu

- ✅ Otomatik soru oluşturma (Gemini AI)
- ✅ Yaş grubuna uygun içerik
- ✅ Gerçek zamanlı feedback
- ✅ İlerleme takibi
- ✅ Adaptif zorluk

### 🎨 Görsel Özelleştirme

- Otomatik renk paleti üretimi
- Yaş grubuna uygun tasarım
- Tema tabanlı görselleştirme

## 🏗️ Mimari

```
┌─────────────────────────────────────────────────────────────────┐
│                      KULLANICI ARAYÜZÜ                            │
│   (ai_game_creator_page.dart)                            │
└────────────────────┬────────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────────┐
│                  AI GAME GENERATOR SERVICE                        │
│   (ai_game_generator_service.dart)                       │
│   - generateGameFromDescription()                                │
│   - generateGameFromTemplate()                                   │
│   - regenerateGame()                                             │
└────────────────────┬────────────────────────────────────────────┘
                     │
                     ▼
        ┌────────────────────────┐
        │   GEMINI 2.0 FLASH     │
        │   (Prompt Engineering)  │
        └────────────┬───────────┘
                     │
                     ▼ (JSON Config)
┌─────────────────────────────────────────────────────────────────┐
│                     GAME TEMPLATE                                 │
│   (game_template.dart)                                   │
│   - AIGameConfig                                                 │
│   - GameMechanics                                                │
│   - EducationalContent                                           │
│   - VisualTheme                                                  │
│   - GameRules                                                    │
└────────────────────┬────────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────────┐
│                  DYNAMIC AI GAME ENGINE                           │
│   (dynamic_ai_game.dart)                                 │
│   - Flame Engine Runtime                                         │
│   - Dynamic Component Creation                                   │
│   - Physics System                                               │
│   - Collision Detection                                          │
│   - Educational Question Flow                                    │
└─────────────────────────────────────────────────────────────────┘
```

## 📁 Dosya Yapısı

```
lib/
└── features/
    └── ai_game_engine/
        ├── domain/
        │   └── entities/
        │       └── game_template.dart         # Oyun config veri modelleri
        ├── data/
        │   ├── services/
        │   │   └── ai_game_generator_service.dart  # AI servis
        │   └── game/
        │       └── dynamic_ai_game.dart       # Flame game engine
        └── presentation/
            └── pages/
                └── ai_game_creator_page.dart  # UI sayfası
```

## 🚀 Kullanım

### 1. Doğal Dil ile Oyun Oluşturma

```dart
final aiService = AIGameGeneratorService(apiKey: 'YOUR_GEMINI_API_KEY');

final config = await aiService.generateGameFromDescription(
  userDescription: '7 yaş için matematik toplama öğreten platform oyunu',
  difficulty: 'easy',
  targetAge: 7,
);

// Config'den oyun oluştur
final game = DynamicAIGame(config: config);
```

### 2. Şablon ile Oyun Oluşturma

```dart
final config = await aiService.generateGameFromTemplate(
  template: GameTemplate.platformer,
  subject: 'matematik',
  difficulty: 'medium',
  targetAge: 8,
  customTheme: 'uzay',
);
```

### 3. Flutter Widget'ı Kullanma

```dart
// main.dart
routes: {
  '/ai-game-creator': (context) => const AIGameCreatorPage(),
}

// Kullanım
Navigator.of(context).pushNamed('/ai-game-creator');
```

## 🎮 Oyun Config JSON Örneği

```json
{
  "gameId": "math-platformer-001",
  "title": "Matematik Maceraları",
  "description": "Toplama öğreten platform oyunu",
  "template": "platformer",
  "difficulty": "easy",
  "targetAge": 7,
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
        "explanation": "5 artı 3 eşittir 8",
        "imageDescription": "Beş elma artı üç elma"
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
    "styleDescription": "Renkli ve neşeli"
  },
  "rules": {
    "winConditionScore": 100,
    "maxLives": 3,
    "timeLimit": 0,
    "allowPause": true,
    "instructions": [
      "Ok tuşları ile hareket et",
      "Yıldızları topla",
      "Sorulara doğru cevap ver"
    ]
  }
}
```

## 🎯 Oyun Şablonları Detayı

### 1. Platform Oyunu (Platformer)
- **Mekanikler**: Yerçekimi, zıplama, engellerden kaçma
- **Eğitim**: Toplanabilir objeler soru içerir
- **Örnek**: Mario benzeri oyun

### 2. Koleksiyon Oyunu (Collector)
- **Mekanikler**: Hareket, obje toplama
- **Eğitim**: Her obje bir soru
- **Örnek**: Pac-Man benzeri

### 3. Puzzle Oyunu (Puzzle)
- **Mekanikler**: Strateji, problem çözme
- **Eğitim**: Bulmaca mantığında sorular
- **Örnek**: Sokoban, Tetris

### 4. Eğitim Oyunu (Educational)
- **Mekanikler**: Soru-cevap odaklı
- **Eğitim**: Direkt eğitim içeriği
- **Örnek**: Quiz oyunları

### 5. Runner Oyunu (Runner)
- **Mekanikler**: Otomatik koşma, engelden kaçma
- **Eğitim**: Ara soruları
- **Örnek**: Temple Run benzeri

### 6. Shooter Oyunu (Shooter)
- **Mekanikler**: Ateş etme, hedef vurma
- **Eğitim**: Hedeflerde sorular
- **Örnek**: Space Invaders

## 🧠 AI Prompt Engineering

### Doğal Dil Prompt Yapısı

```
Sen bir profesyonel eğitim oyunu tasarımcısısın. 
Aşağıdaki açıklamaya göre 2D eğitim oyunu oluştur:

KULLANICI: "{açıklama}"

PARAMETRELER:
- Zorluk: {difficulty}
- Yaş: {targetAge}

GÖREV:
1. Kullanıcının isteğini analiz et
2. En uygun şablonu seç
3. Oyun mekaniklerini belirle
4. Eğitim içeriği oluştur
5. Görsel tema tasarla
6. Oyun kurallarını belirle

JSON FORMAT: {...}
```

### Template Prompt Yapısı

```
ŞABLON: {template}
KONU: {subject}
ZORLUK: {difficulty}
YAŞ: {targetAge}

Konuya uygun sorular oluştur.
Oyun mekaniklerini ayarla.
Çocuk dostu estetik tema seç.
```

## 🎨 Dinamik Oyun Oluşturma Akışı

```
1. KULLANICI AÇIKLAMA GİRER
   ↓
2. AI SERVİS PROMPT OLUŞTURUR
   ↓
3. GEMİNİ JSON CONFİG ÜRETIR
   ↓
4. JSON PARSE EDİLİR → AIGameConfig
   ↓
5. DYNAMİC GAMEDOLUŞTURULURAMİC GAME OLUŞTURULUR
   ↓
6. FLAME ENGINE RENDER EDER
   ↓
7. KULLANICI OYNAR
```

## 🔧 Teknik Detaylar

### Flame Engine Komponları

```dart
// Player Component
class DynamicPlayer extends PositionComponent {
  - Fizik sistemi (gravity, jump)
  - Collision detection
  - Input handling (tap to jump)
}

// Collectible Component
class DynamicCollectible extends PositionComponent {
  - Soru içeren toplanabilir objeler
  - Collision callback
}

// Enemy Component
class DynamicEnemy extends PositionComponent {
  - Hareketli düşmanlar
  - Çarpışma hasar sistemi
}
```

### Oyun Döngüsü

```dart
@override
void update(double dt) {
  // 1. Spawn timer kontrolü
  // 2. Obje spawn (collectible, enemy)
  // 3. Zaman limit kontrolü
  // 4. Kazanma koşulu kontrolü
  // 5. Ekran dışı temizlik
}
```

## 📊 Performans Optimizasyonu

- ✅ Ekran dışı obje temizliği
- ✅ Spawn rate kontrolü
- ✅ Efficient collision detection
- ✅ Memory leak prevention

## 🎓 Eğitim Akışı

```
1. OYUNCU TOPLANABİLİR OBJEYİ TOPLAR
   ↓
2. OYUN DURAKLAR (pause state)
   ↓
3. SORU OVERLAY GÖSTERİLİR
   ↓
4. KULLANICI CEVAPLAR
   ↓ (Doğru)
5. +20 PUAN
   ↓ (Yanlış)
6. -1 CAN
   ↓
7. OYUN DEVAM EDER
```

## 🚀 Geliştirme Roadmap

### ✅ Tamamlanan
- AI game config oluşturma
- Dinamik Flame engine oyun sistemi
- Eğitim entegrasyonu
- 6 oyun şablonu
- UI/UX sayfaları

### 🔄 Devam Eden
- Ses efektleri
- Animasyonlar
- Sprite grafikleri

### 📋 Planlanan
- Multiplayer desteği
- Leaderboard sistemi
- Oyun paylaşımı
- Analytics entegrasyonu
- Daha fazla şablon

## 🐛 Bilinen Sorunlar ve Çözümler

### 1. Gemini API Rate Limit
**Sorun**: Çok fazla istek hatası  
**Çözüm**: Fallback model sistemi (gemini-pro)

### 2. JSON Parse Hatası
**Sorun**: Gemini bazen markdown ile JSON döner  
**Çözüm**: Regex ile JSON extraction

### 3. Oyun FPS Düşüklüğü
**Sorun**: Çok fazla obje spawn  
**Çözüm**: Spawn rate limiti + cleanup

## 📚 Referanslar

- [Flame Engine Docs](https://docs.flame-engine.org/)
- [Gemini AI API](https://ai.google.dev/)
- [Flutter Docs](https://docs.flutter.dev/)

## 👥 Katkıda Bulunma

Bu sistem açık kaynak mantığıyla geliştirilmiştir. Katkılarınızı bekliyoruz!

## 📄 Lisans

MIT License

---

**🎮 Hayal Gücünüzün Sınırını Zorlayın!**  
*AI ile Oyun Oluşturmanın Yeni Çağı*

