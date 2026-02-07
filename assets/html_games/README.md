# 🎮 HTML Oyun Template Sistemi

## 📋 Genel Bakış

Bu sistem, kullanıcıların seçimleriyle birlikte Gemini AI'dan gelen içeriği kullanarak HTML tabanlı eğitici oyunlar oluşturur.

## 🏗️ Mimari

```
Kullanıcı Input (Tür, Hedef, Zorluk)
         ↓
Gemini AI API (İçerik Üretimi)
         ↓
JSON Response (Sorular, Hikaye, Parametreler)
         ↓
Template Engine (HTML/CSS/JS Şablon Seçimi)
         ↓
HTML Oyun Dosyası (Birleştirilmiş)
         ↓
Firebase Storage (Dosya Host)
         ↓
WebView (Oyun Oynanır) + Firestore (Metadata)
```

## 📁 Dizin Yapısı

```
assets/html_games/
├── templates/
│   ├── math_game.html          # Matematik oyunu şablonu
│   ├── word_game.html          # Kelime oyunu şablonu
│   ├── puzzle_game.html        # Bulmaca oyunu şablonu
│   ├── color_game.html         # Renk oyunu şablonu
│   └── memory_game.html        # Hafıza oyunu şablonu
├── shared/
│   ├── style.css               # Ortak CSS
│   ├── game_engine.js          # Oyun motoruçekirdek fonksiyonlar
│   └── particles.js            # Efekt kütüphanesi
└── README.md
```

## 🎯 Şablon Sistemi Nasıl Çalışır?

### 1. Şablonlar (Templates)
Her oyun türü için HTML/CSS/JS şablonu vardır. Şablonlar **placeholder**'lar içerir:

```html
<!-- math_game.html örneği -->
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>{{GAME_TITLE}}</title>
    <style>
        /* CSS styles */
    </style>
</head>
<body>
    <div id="game-container">
        <h1>{{GAME_TITLE}}</h1>
        <p>{{GAME_DESCRIPTION}}</p>
        <div id="question"></div>
        <div id="answers"></div>
        <div id="score">Puan: <span id="score-value">0</span></div>
    </div>
    
    <script>
        const questions = {{QUESTIONS_JSON}};
        const difficulty = "{{DIFFICULTY}}";
        const totalQuestions = {{TOTAL_QUESTIONS}};
        
        // Oyun mantığı...
    </script>
</body>
</html>
```

### 2. Gemini AI İçerik Üretimi

**Prompt Örneği:**
```
Bir matematik oyunu için içerik oluştur.
- Konu: Toplama İşlemi
- Zorluk: Kolay
- Soru Sayısı: 10
- Hedef Yaş: 6-8 yaş

JSON formatında şu verileri ver:
{
  "questions": [
    {
      "question": "5 + 3 = ?",
      "answers": [8, 6, 9, 7],
      "correctIndex": 0
    }
  ],
  "hints": ["İki sayıyı topluyoruz"],
  "encouragement": ["Harika!", "Süpersin!"]
}
```

**Gemini Response:**
```json
{
  "questions": [...],
  "hints": [...],
  "encouragement": [...]
}
```

### 3. Template Engine (Birleştirme)

```dart
class GameTemplateEngine {
  static String generateHTML({
    required String templateType,
    required Map<String, dynamic> geminiData,
    required String title,
    required String description,
    required String difficulty,
  }) {
    // 1. Şablonu yükle
    String template = await loadTemplate(templateType);
    
    // 2. Placeholder'ları değiştir
    template = template
        .replaceAll('{{GAME_TITLE}}', title)
        .replaceAll('{{GAME_DESCRIPTION}}', description)
        .replaceAll('{{DIFFICULTY}}', difficulty)
        .replaceAll('{{QUESTIONS_JSON}}', jsonEncode(geminiData['questions']))
        .replaceAll('{{TOTAL_QUESTIONS}}', geminiData['questions'].length.toString());
    
    return template;
  }
}
```

## 🎮 Oyun Türleri ve Şablonları

### 1. **Matematik Oyunu** (`math_game.html`)
- **Mekanik**: Çoktan seçmeli sorular
- **Özellikler**: Zaman sınırı, ipucu sistemi, puan hesaplama
- **Gemini girdi**: Matematiksel sorular ve çoktan seçmeli cevaplar

### 2. **Kelime Oyunu** (`word_game.html`)
- **Mekanik**: Harf sürükle-bırak, kelime bulma
- **Özellikler**: Harf bankası, kelime doğrulama
- **Gemini girdi**: Kelime listesi, ipuçları

### 3. **Bulmaca Oyunu** (`puzzle_game.html`)
- **Mekanik**: Resim parçalarını eşleştirme
- **Özellikler**: Drag & drop, parça kontrolü
- **Gemini girdi**: Resim URL'leri, parça sayısı

### 4. **Renk Oyunu** (`color_game.html`)
- **Mekanik**: Renk eşleştirme, renk adlandırma
- **Özellikler**: Renk paletleri, animasyonlar
- **Gemini girdi**: Renk kombinasyonları, zorluk seviyesi

### 5. **Hafıza Oyunu** (`memory_game.html`)
- **Mekanik**: Kartları çevir ve eşleştir
- **Özellikler**: Animasyonlu kartlar, hamle sayacı
- **Gemini girdi**: Kart içerikleri (emoji, resim, kelime)

## 🚀 Uygulama Akışı

### Kullanıcı Tarafı:
1. Oyun türü seçer (Matematik)
2. Öğrenme hedefi seçer (Toplama İşlemi)
3. Zorluk seviyesi seçer (Kolay)
4. Başlık ve açıklama yazar
5. "Oluştur" butonuna basar

### Sistem Tarafı:
```dart
// 1. Gemini'ye prompt gönder
final geminiPrompt = buildPrompt(
  gameType: 'math',
  learningGoals: ['math_addition'],
  difficulty: 'easy',
  questionCount: 10,
);

final geminiData = await geminiService.generateContent(geminiPrompt);

// 2. Şablon ile birleştir
final htmlContent = GameTemplateEngine.generateHTML(
  templateType: 'math_game',
  geminiData: geminiData,
  title: userTitle,
  description: userDescription,
  difficulty: 'easy',
);

// 3. Firebase Storage'a yükle
final htmlUrl = await uploadToStorage(htmlContent);

// 4. Firestore'a oyun metadata'sını kaydet
await saveGameToFirestore(
  title: userTitle,
  description: userDescription,
  htmlUrl: htmlUrl,
  gameType: 'math',
  difficulty: 'easy',
  creatorId: currentUserId,
);

// 5. Kullanıcıya göster
Navigator.push(context, PlayGamePage(gameId: newGameId));
```

## 📊 Veritabanı Yapısı

### Firestore Collections:

```
games/
  {gameId}/
    - title: string
    - description: string
    - gameType: string
    - difficulty: string
    - learningGoals: array
    - htmlContent: string (veya Storage URL)
    - creatorId: string
    - playCount: number
    - averageRating: number
    - createdAt: timestamp

game_scores/
  {scoreId}/
    - gameId: string
    - userId: string
    - score: number
    - correctAnswers: number
    - playedAt: timestamp

game_comments/
  {commentId}/
    - gameId: string
    - userId: string
    - comment: string
    - createdAt: timestamp

game_ratings/
  {ratingId}/
    - gameId: string
    - userId: string
    - rating: number (1-5)
```

## 🔧 Geliştirme Adımları

### Faz 1: Temel Şablonlar (Hemen)
1. ✅ 5 temel HTML şablonu oluştur
2. ✅ Placeholder sistemini kur
3. ✅ Template Engine'i yaz

### Faz 2: Gemini Entegrasyonu (Sonra)
1. Gemini API bağlantısı
2. Prompt engineering (her oyun türü için)
3. JSON parsing ve validasyon

### Faz 3: Firebase Entegrasyonu (Sonra)
4. Storage'a HTML upload
5. Firestore'a metadata kayıt
6. WebView ile oyun gösterimi

### Faz 4: Sosyal Özellikler (İleriki Adımlar)
7. Yorum sistemi
8. Puanlama sistemi
9. Sıralama tabloları

## ✨ İlk Adım: Basit Bir Örnek

Gemini olmadan da çalışabilen bir sistem:

```dart
// Statik içerik ile test
final staticQuestions = [
  {"question": "5 + 3 = ?", "answers": [8, 6, 9, 7], "correctIndex": 0},
  {"question": "10 - 4 = ?", "answers": [5, 6, 7, 8], "correctIndex": 1},
];

final htmlContent = GameTemplateEngine.generateHTML(
  templateType: 'math_game',
  geminiData: {'questions': staticQuestions},
  title: 'Toplama Oyunu',
  description: 'Basit toplama soruları',
  difficulty: 'easy',
);

// Bu HTML'i WebView'de göster
```

## 🎯 Sonuç

**Önerilen Yaklaşım: Template-Based + Gemini AI**

✅ **Avantajlar:**
- Güvenilir oyun mekanikleri (şablonlar test edilmiş)
- Sınırsız içerik çeşitliliği (Gemini üretir)
- Kolay bakım ve genişletme
- Offline modu desteklenebilir (cached şablonlar)

❌ **Dezavantajlar:**
- İlk kurulum biraz zaman alır
- Her yeni oyun türü için şablon gerekir

**Alternatif**: Gemini'nin doğrudan tüm HTML'i üretmesi → Güvenilirlik düşük, oyunlar çalışmayabilir.

---

**Şimdi yapılacak:** Basit bir matematik oyunu şablonu oluşturup test edelim!
