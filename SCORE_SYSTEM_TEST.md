# 📊 Puan Sistemi Test Belgesi

## ✅ Tamamlanan Bileşenler

### 1️⃣ HTML Oyunlar - Puan Gönderimi
**Durum:** ✅ TAMAMLANDI

Tüm 5 oyun postMessage ile puan gönderiliyor:

```javascript
window.parent.postMessage({
    type: 'GAME_SCORE',
    gameName: 'oyun_adi',
    score: skoru,
    rank: 'Oyun Tamamlandı'
}, '*');
```

#### Oyunlar:
1. **🥗 Besin Ninja** (`besin_ninja.html`)
   - Puan: 0-100
   - Gönderimi: `endGame()` fonksiyonunda

2. **🔦 Lazer Fizik** (`lazer_fizik.html`)
   - Puan: 0-100 (10 level × max 10 puan)
   - Gönderimi: `endGame()` fonksiyonunda

3. **🏹 Matematik Okcusu** (`matematik_okcusu.html`)
   - Puan: 0-100 (10 level × max 10 puan)
   - Gönderimi: `showEndScreen()` fonksiyonunda

4. **🚗 Sürütünme Yarışı** (`araba_surtunme.html`)
   - Puan: 0-100 (hız bazlı)
   - Gönderimi: `showResult()` fonksiyonunda

5. **🪐 Gezegen Bul** (`gezegenibul.html`)
   - Puan: 0-100 (8 soru × 12.5 puan)
   - Gönderimi: `gameOver()` fonksiyonunda

---

### 2️⃣ WebView Score Capture - Dart Side
**Durum:** ✅ TAMAMLANDI
**Konum:** `lib/features/webview/presentation/pages/webview_page.dart`

```dart
// JavaScript Channel kurulumu
addJavaScriptChannel('GameScoreListener', 
  onMessageReceived: (msg) => _handleGameScore(msg.message)
);

// Puan işleme
void _handleGameScore(String jsonData) {
  try {
    final data = jsonDecode(jsonData);
    final gameName = data['gameName'];
    final score = data['score'] as int;
    
    // LeaderboardService'e gönder
    leaderboardService.saveGameScore(
      gameId: gameName,
      userId: 'test-user-123',
      score: score,
      userName: 'Test User'
    );
  } catch (e) {
    print('Hata - Puan işlenemedi: $e');
  }
}
```

**⚠️ TODO:** `userId` şu anda hardcoded ('test-user-123')
- Öneri: FirebaseAuth.instance.currentUser?.uid kullanılmalı

---

### 3️⃣ Firestore Veri Modeli
**Durum:** ✅ TAMAMLANDI

**Collection:** `game_scores`
```json
{
  "gameId": "string",
  "userId": "string",
  "userName": "string",
  "userAvatar": "string",
  "score": "number",
  "completedAt": "timestamp",
  "metadata": {
    "deviceType": "web|mobile",
    "sessionDuration": "number"
  }
}
```

---

### 4️⃣ LeaderboardService
**Durum:** ✅ TAMAMLANDI
**Konum:** `lib/features/games/data/services/leaderboard_service.dart`

#### Mevcut Metodlar:

1. **getGlobalLeaderboard()** 
   - Tüm kullanıcıları toplam puanlara göre sırala
   - Input: limit (default 50)
   - Output: Stream<List<LeaderboardEntry>>

2. **getGameLeaderboard(gameId)**
   - Oyun içinde en iyi skorlar
   - En yüksek tek puan alır
   - Input: gameId, limit
   - Output: List<LeaderboardEntry>

3. **saveGameScore()**
   - Oyundan gelen puanı kaydeder
   - Firestore'a yazar
   - User toplam puanını günceller

4. **getUserTotalScore(userId)**
   - Tüm oyunlarda en iyi skorların toplamı
   - Input: userId
   - Output: int (total score)

5. **getTrendingThisMonth()**
   - Son 30 günde en çok oynanan oyunlar
   - Input: limit
   - Output: List<GameTrend>

6. **getUserGameHighScore(userId, gameId)**
   - Belirli oyundaki en yüksek skor
   - Input: userId, gameId
   - Output: int (score)

7. **getUserGlobalRank(userId)**
   - Kullanıcının global sıralamadaki yeri
   - Input: userId
   - Output: int (rank)

---

### 5️⃣ SocialFeedService - HTML Oyunlar
**Durum:** ✅ TAMAMLANDI
**Konum:** `lib/features/games/data/services/social_feed_service.dart`

#### Yeni Metodlar:

1. **getHtmlGamesForFeed()**
   - 5 HTML oyunun metadatasını döndürür
   - Output: List<Map> ile oyun bilgileri

2. **getCombinedFeed()**
   - HTML + Firestore oyunlarını birleştirir
   - Output: Dinamik liste (tüm oyunlar)

---

### 6️⃣ LeaderboardPage UI
**Durum:** ✅ TAMAMLANDI
**Konum:** `lib/features/games/presentation/pages/leaderboard_page.dart`

#### Özellikler:
- 🏆 Global Leaderboard Tab
- 🔥 Trending Games Tab
- 📊 Kullanıcı sıralaması gösterimi

---

## 🧪 Test Senaryoları

### Senaryo 1: Oyun Oyna → Puan Kaydet
```
1. App açılır
2. Oyunlardan biri seçilir
3. Oyun tamamlanır (puan elde edilir)
4. postMessage gönderilir
5. WebView yakalanır
6. LeaderboardService.saveGameScore() çağrılır
7. Firestore'da game_scores collection'a yazılır
```

**Beklenen Sonuç:** Firestore'da yeni döküman görülmeli

---

### Senaryo 2: Global Leaderboard Görüntüle
```
1. Leaderboard sayfası açılır
2. getGlobalLeaderboard() çağrılır
3. Firestore'dan veriler çekilir
4. Kullanıcılar sıralanır
5. UI'da görüntülenir
```

**Beklenen Sonuç:** Top 50 kullanıcı isim ve puanlarıyla listelenir

---

### Senaryo 3: Oyun Bazında Sıralama
```
1. LeaderboardPage açılır
2. Oyun seçilir
3. getGameLeaderboard(gameId) çağrılır
4. O oyundaki en iyi skorlar getirilir
```

**Beklenen Sonuç:** Oyun içinde en yüksek puan alanlar gösterilir

---

### Senaryo 4: Trending Oyunlar
```
1. Leaderboard → Trending tab
2. getTrendingThisMonth() çağrılır
3. Son 30 günün istatistikleri çekilir
4. En çok oynanan oyunlar gösterilir
```

**Beklenant Sonuç:** Oyunlar oynama sayısına göre sıralanır

---

## 🔍 Veri Akışı (Data Flow)

```
HTML Game (postMessage)
    ↓
WebView JavaScriptChannel
    ↓
_handleGameScore()
    ↓
LeaderboardService.saveGameScore()
    ↓
Firestore (game_scores collection)
    ↓
LeaderboardService.getGlobalLeaderboard()
    ↓
LeaderboardPage UI
```

---

## ✅ Veri Çekilebilirliği Kontrol Listesi

- [x] HTML oyunlar puan gönderiyor
- [x] WebView postMessage yakalıyor
- [x] Firestore'a yazılıyor
- [x] LeaderboardService çekiliyor
- [x] Global sıralama gösteriliyor
- [x] Oyun bazında sıralama gösteriliyor
- [x] Trending verisi gösteriliyor
- [x] Sosyal akışta oyunlar görünüyor

---

## 🐛 Bilinen Sorunlar & Çözümler

### 1. Problem: userId hardcoded
**Çözüm:** FirebaseAuth kullanılmalı
```dart
final userId = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
```

### 2. Problem: Firestore Security Rules
**Çözüm:** Yazma izni olmalı
```
match /game_scores/{document=**} {
  allow read: if true;
  allow create: if request.auth != null;
}
```

### 3. Problem: Veri timestamp'ı
**Çözüm:** completedAt alanı otomatik set edilir
```dart
completedAt: Timestamp.now()
```

---

## 📈 Başarı Göstergeleri

✅ Sistemin başarılı olması için:
1. Firestore'da `game_scores` koleksiyonunda veri var
2. LeaderboardPage global sıralamayı gösteriyor
3. Oyun tamamlandıktan sonra skor Firestore'a yazılıyor
4. 5 HTML oyun da dökümanlar yaratıyor
5. Trending verisi doğru hesaplanıyor

---

## 🚀 Sonraki Adımlar

1. **Firestore Security Rules kurulumu**
   - game_scores koleksiyonu yazma izni
   - users koleksiyonu yazma izni

2. **Firebase Authentication**
   - Gerçek user ID kullanımı
   - Anonymous auth fallback

3. **Platform-specific Testing**
   - Web: ✅ Hazır
   - Android: WebView test
   - iOS: WKWebView test

4. **Analytics Integration**
   - Game play events
   - Score submission events
   - User retention tracking

---

**Son Güncelleme:** 11 Şubat 2026
**Durum:** Hazır Test için ✅
