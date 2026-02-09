# 🧪 AI Game Engine - Test Senaryoları

## Test Stratejisi

Bu dokümanda AI Game Engine sistemini test etmek için detaylı senaryolar bulunmaktadır.

---

## 1. Unit Tests

### AIGameConfig Tests

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:oyun_olustur/features/ai_game_engine/domain/entities/game_template.dart';

void main() {
  group('AIGameConfig Tests', () {
    test('Should create config from JSON', () {
      final json = {
        'gameId': 'test-001',
        'title': 'Test Oyunu',
        'description': 'Test açıklaması',
        'template': 'platformer',
        'difficulty': 'easy',
        'targetAge': 7,
        'mechanics': {
          'hasGravity': true,
          'hasJump': true,
          'hasCollectibles': true,
          'hasEnemies': false,
          'hasTimeLimit': false,
          'hasLives': true,
          'playerSpeed': 200.0,
          'jumpHeight': 300.0,
        },
        'educationalContent': {
          'subject': 'matematik',
          'questions': [
            {
              'id': 'q1',
              'text': '2+2=?',
              'options': ['3', '4', '5', '6'],
              'correctIndex': 1,
              'explanation': 'Cevap 4',
              'imageDescription': null,
            }
          ],
          'showFeedback': true,
          'trackProgress': true,
        },
        'visualTheme': {
          'backgroundColor': 4287531723,
          'playerColor': 4283215696,
          'enemyColor': 4294934123,
          'collectibleColor': 4294956800,
          'uiColor': 4280391411,
          'styleDescription': 'Renkli',
        },
        'rules': {
          'winConditionScore': 100,
          'maxLives': 3,
          'timeLimit': 0,
          'allowPause': true,
          'instructions': ['Test talimat'],
        },
        'initialObjects': [],
      };

      final config = AIGameConfig.fromJson(json);

      expect(config.gameId, 'test-001');
      expect(config.title, 'Test Oyunu');
      expect(config.difficulty, 'easy');
      expect(config.targetAge, 7);
      expect(config.mechanics.hasGravity, true);
      expect(config.educationalContent.questions.length, 1);
    });

    test('Should convert config to JSON', () {
      final config = AIGameConfig(
        gameId: 'test-002',
        title: 'JSON Test',
        description: 'Test',
        template: 'collector',
        difficulty: 'medium',
        targetAge: 8,
        mechanics: GameMechanics(
          hasGravity: false,
          hasJump: false,
          hasCollectibles: true,
          hasEnemies: true,
          hasTimeLimit: true,
          hasLives: true,
          playerSpeed: 150.0,
          jumpHeight: 0.0,
        ),
        educationalContent: EducationalContent(
          subject: 'kelime',
          questions: [],
          showFeedback: true,
          trackProgress: false,
        ),
        visualTheme: VisualTheme(
          backgroundColor: 0xFF000000,
          playerColor: 0xFF0000FF,
          enemyColor: 0xFFFF0000,
          collectibleColor: 0xFFFFFF00,
          uiColor: 0xFFFFFFFF,
          styleDescription: 'Test',
        ),
        rules: GameRules(
          winConditionScore: 50,
          maxLives: 5,
          timeLimit: 60,
          allowPause: false,
          instructions: [],
        ),
        initialObjects: [],
      );

      final json = config.toJson();

      expect(json['gameId'], 'test-002');
      expect(json['title'], 'JSON Test');
      expect(json['template'], 'collector');
    });
  });
}
```

---

## 2. Integration Tests

### AI Service Tests

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:oyun_olustur/features/ai_game_engine/data/services/ai_game_generator_service.dart';

void main() {
  group('AIGameGeneratorService Tests', () {
    late AIGameGeneratorService service;

    setUp(() {
      service = AIGameGeneratorService(
        apiKey: 'TEST_API_KEY', // Test için mock API key
      );
    });

    test('Should generate game from description', () async {
      final config = await service.generateGameFromDescription(
        userDescription: '7 yaş için toplama öğreten platform oyunu',
        difficulty: 'easy',
        targetAge: 7,
      );

      expect(config, isNotNull);
      expect(config.targetAge, 7);
      expect(config.difficulty, 'easy');
      expect(config.educationalContent.questions.isNotEmpty, true);
    }, skip: 'API key gerektirir');

    test('Should generate game from template', () async {
      final config = await service.generateGameFromTemplate(
        template: 'platformer',
        subject: 'matematik',
        difficulty: 'medium',
        targetAge: 8,
      );

      expect(config, isNotNull);
      expect(config.template, 'platformer');
      expect(config.educationalContent.subject, 'matematik');
    }, skip: 'API key gerektirir');
  });
}
```

---

## 3. Widget Tests

### AIGameCreatorPage Tests

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oyun_olustur/features/ai_game_engine/presentation/pages/ai_game_creator_page.dart';

void main() {
  group('AIGameCreatorPage Widget Tests', () {
    testWidgets('Should display initial creator view', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AIGameCreatorPage(),
        ),
      );

      expect(find.text('🤖 AI Oyun Oluşturucu'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Oyun Oluştur'), findsOneWidget);
    });

    testWidgets('Should show loading indicator when generating', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AIGameCreatorPage(),
        ),
      );

      // Generate butonuna tıkla
      await tester.tap(find.text('Oyun Oluştur'));
      await tester.pump();

      // Loading indicator görünmeli
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
```

---

## 4. Manuel Test Senaryoları

### Senaryo 1: Basit Platform Oyunu

**Adımlar:**
1. Uygulamayı başlat: `flutter run`
2. Ana ekranda "🤖 AI Oyun Oluşturucu" butonuna tıkla
3. Açıklama gir: "7 yaş için toplama öğreten platform oyunu"
4. Zorluk: Easy seç
5. Yaş: 7 seç
6. "Oyun Oluştur" butonuna tıkla

**Beklenen Sonuç:**
- ✅ Loading göstergesi belirir
- ✅ 10-15 saniye içinde oyun oluşturulur
- ✅ Oyun önizleme kartı görünür
- ✅ Başlık, açıklama, şablon bilgisi görüntülenir
- ✅ Soru sayısı: 3-5 arası
- ✅ "Oyna!" butonu aktif

**Doğrulama:**
```
✓ Oyun başlığı Türkçe
✓ Açıklama mantıklı
✓ Yaş grubuna uygun
✓ Soru sayısı doğru
```

---

### Senaryo 2: Oyun Oynama

**Adımlar:**
1. Senaryo 1'i tamamla
2. "Oyna!" butonuna tıkla
3. Oyun ekranını gözlemle
4. Ekrana tıkla (zıpla)
5. Yıldıza çarp (collectible)
6. Soruyu cevapla

**Beklenen Sonuç:**
- ✅ Oyun ekranı yüklenir
- ✅ Player görünür (mavi kare)
- ✅ Collectible'lar spawn olur (sarı daireler)
- ✅ Skor: 0 görünür (üst sol)
- ✅ Canlar: ❤️❤️❤️ görünür (üst sağ)
- ✅ Player zıplayabilir
- ✅ Collectible toplandığında soru çıkar
- ✅ Doğru cevap: +20 puan
- ✅ Yanlış cevap: -1 can

**Doğrulama:**
```
✓ FPS: ~60
✓ Fizik mantıklı (gravity, jump)
✓ Collision detection çalışıyor
✓ UI overlay doğru konumda
```

---

### Senaryo 3: Eğitim Entegrasyonu

**Adımlar:**
1. Oyun oyna
2. Collectible topla
3. Soru modalını oku
4. Doğru cevabı seç
5. Yeni collectible topla
6. Yanlış cevap seç

**Beklenen Sonuç:**
- ✅ Oyun duraklar (pause)
- ✅ Soru modal açılır
- ✅ Soru metni Türkçe ve anlaşılır
- ✅ 4 seçenek var
- ✅ Seçenekler buton şeklinde
- ✅ Doğru cevap: Yeşil flash + +20 puan
- ✅ Yanlış cevap: Kırmızı flash + -1 can
- ✅ Modal kapanır
- ✅ Oyun devam eder

**Doğrulama:**
```
✓ Soru yaş grubuna uygun
✓ Seçenekler mantıklı
✓ Doğru cevap indexi doğru
✓ Explanation görünür
```

---

### Senaryo 4: Kazanma Durumu

**Adımlar:**
1. Oyun oyna
2. Doğru cevaplarla 100 puana ulaş
3. Kazanma dialogunu gözlemle

**Beklenen Sonuç:**
- ✅ 100 puana ulaşınca oyun durur
- ✅ "Kazandınız!" dialogu açılır
- ✅ Final skoru gösterilir
- ✅ "Ana Menü" butonu var
- ✅ "Tekrar Oyna" butonu var
- ✅ Ana menü: Creator view'a döner
- ✅ Tekrar oyna: Oyun resetlenir

---

### Senaryo 5: Kaybetme Durumu

**Adımlar:**
1. Oyun oyna
2. Düşmanlara çarp veya 3 yanlış cevap ver
3. Canlar sıfırlandığında durumu gözlemle

**Beklenen Sonuç:**
- ✅ Canlar biter (❤️❤️❤️ → ❤️❤️ → ❤️ → 💔)
- ✅ "Oyun Bitti!" dialogu açılır
- ✅ Final skoru gösterilir
- ✅ "Ana Menü" ve "Tekrar Oyna" butonları var

---

### Senaryo 6: Farklı Şablonlar

**Adımlar:**
1. Collector şablonu seç
2. Subject: "kelime" gir
3. Oyun oluştur ve oyna

**Beklenen Sonuç:**
- ✅ Farklı mekanikler (no gravity, no jump)
- ✅ Kelime soruları
- ✅ Farklı görsel stil

**Test edilecek şablonlar:**
- [ ] Platformer
- [ ] Collector
- [ ] Puzzle
- [ ] Educational
- [ ] Runner
- [ ] Shooter

---

### Senaryo 7: Hata Durumları

#### 7.1 İnternet Yok

**Adımlar:**
1. İnternet bağlantısını kes
2. Oyun oluşturmaya çalış

**Beklenen Sonuç:**
- ✅ Hata mesajı: "İnternet bağlantınızı kontrol edin"
- ✅ Loading indicator kaybolur

#### 7.2 Boş Açıklama

**Adımlar:**
1. Hiç açıklama girme
2. "Oyun Oluştur"a tıkla

**Beklenen Sonuç:**
- ✅ Uyarı: "Lütfen oyun açıklaması girin"

#### 7.3 API Rate Limit

**Adımlar:**
1. 10 kez ardarda oyun oluştur

**Beklenen Sonuç:**
- ✅ Rate limit hatası yakalanır
- ✅ Fallback model dener
- ✅ Kullanıcıya bilgi verilir

---

## 5. Performance Tests

### Load Test

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:oyun_olustur/features/ai_game_engine/data/game/dynamic_ai_game.dart';

void main() {
  test('Game should maintain 60 FPS with 50 objects', () async {
    final config = _createTestConfig();
    final game = DynamicAIGame(config: config);
    
    await game.onLoad();
    
    // Spawn 50 objects
    for (int i = 0; i < 50; i++) {
      game.spawnCollectible();
      game.spawnEnemy();
    }
    
    // Simulate 100 frames
    for (int i = 0; i < 100; i++) {
      final startTime = DateTime.now();
      game.update(1/60); // 60 FPS
      final frameTime = DateTime.now().difference(startTime);
      
      // Frame time should be < 16ms (60 FPS)
      expect(frameTime.inMilliseconds, lessThan(16));
    }
  });
}
```

---

## 6. Test Checklist

### ✅ Temel İşlevsellik
- [ ] Oyun oluşturma (natural language)
- [ ] Oyun oluşturma (template)
- [ ] Oyun oynama
- [ ] Soru gösterme
- [ ] Skor hesaplama
- [ ] Can sistemi
- [ ] Kazanma durumu
- [ ] Kaybetme durumu
- [ ] Restart

### ✅ UI/UX
- [ ] Loading states
- [ ] Error handling
- [ ] Responsive layout
- [ ] Button states
- [ ] Dialog görünümü
- [ ] Overlay pozisyonu
- [ ] Renk uyumu

### ✅ Performans
- [ ] 60 FPS
- [ ] Memory leaks yok
- [ ] Smooth animations
- [ ] Quick spawn/despawn

### ✅ Eğitim İçeriği
- [ ] Soru kalitesi
- [ ] Yaş uygunluğu
- [ ] Açıklama netliği
- [ ] Cevap doğruluğu

### ✅ AI Kalitesi
- [ ] İstek anlaşılabilirliği
- [ ] Config doğruluğu
- [ ] JSON formatı
- [ ] Hata yönetimi

---

## 7. Test Ortamları

### Development
```bash
flutter run --debug
```
- Hot reload aktif
- Performance overlay: `flutter run --profile`

### Testing
```bash
flutter test
flutter test --coverage
```

### Production
```bash
flutter run --release
flutter build apk --release
```

---

## 8. Bug Report Template

```markdown
### Bug Açıklaması
[Kısa açıklama]

### Adımlar
1. [Adım 1]
2. [Adım 2]
3. [Adım 3]

### Beklenen Davranış
[Ne olması gerekiyordu]

### Gerçekleşen Davranış
[Ne oldu]

### Ekran Görüntüleri
[Varsa ekle]

### Ortam Bilgileri
- Device: [Android/iOS]
- OS Version: [10, 14, etc.]
- App Version: [1.0.0]
- Flutter Version: [3.9.2]

### Log
```
[Hata mesajları]
```

### Önem Derecesi
[ ] Critical (App crash)
[ ] High (Feature broken)
[ ] Medium (UX issue)
[ ] Low (Minor bug)
```

---

## 9. Test Komutları

```bash
# Tüm testleri çalıştır
flutter test

# Belirli bir test dosyası
flutter test test/ai_game_engine_test.dart

# Code coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html

# Integration tests
flutter test integration_test/

# Widget tests
flutter test test/widget_test.dart

# Performance profiling
flutter run --profile

# Memory leaks
flutter run --debug
# DevTools > Memory > Take Snapshot
```

---

## 10. CI/CD Pipeline

### GitHub Actions Example

```yaml
name: AI Game Engine Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.9.2'
      - run: flutter pub get
      - run: flutter test
      - run: flutter test --coverage
      - uses: codecov/codecov-action@v3
```

---

**🧪 Happy Testing!**

*"Testing is not about finding bugs, it's about preventing them."*
