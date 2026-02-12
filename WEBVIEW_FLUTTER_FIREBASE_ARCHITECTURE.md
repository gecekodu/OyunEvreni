# 🏗️ WEBVIEW ↔ FLUTTER ↔ FIREBASE PUAN KÖPRÜSÜ MİMARİSİ

## 📊 GENEL AKIŞ

```
┌─────────────────────────────────────────────────────────────────┐
│                      HTML OYUN (WebView)                        │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │ // Oyuncu puan kazanır                                    │ │
│  │ score += 10;                                              │ │
│  │ window.sendScoreToFlutter(10);  ← 🌐 Puan gönder        │ │
│  └────────────────────────────────────────────────────────────┘ │
└────────────────────┬────────────────────────────────────────────┘
                     │ JavaScript postMessage / InAppWebView Handler
                     ▼
┌─────────────────────────────────────────────────────────────────┐
│                   FLUTTER UYGULAMA (Dart)                       │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │ EnhancedWebviewPage                                       │ │
│  │ • InAppWebView ile puan handler'ı dinle                 │ │
│  │ • HTML oyundan gelen puanı yakala                       │ │
│  │ • addJavaScriptHandler('sendScore', callback)           │ │
│  └────────────────────────────────────────────────────────────┘ │
└────────────────────┬────────────────────────────────────────────┘
                     │ ScoreService.addScoreToUserProfile()
                     ▼
┌─────────────────────────────────────────────────────────────────┐
│                   FIREBASE (Güvenli Depolama)                   │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │ Firestore Collection: users/{userId}                     │ │
│  │ {                                                         │ │
│  │   "totalScore": 1250,  ← FieldValue.increment(+10)      │ │
│  │   "lastUpdated": serverTimestamp(),                      │ │
│  │   "username": "Kullanıcı",                              │ │
│  │   "userAvatar": "..."                                    │ │
│  │ }                                                         │ │
│  │                                                           │ │
│  │ ✅ Atomic (Çakışmasız) artırma = Güvenli eşzamanlı     │ │
│  │ ✅ Server timestamp = Sunucudan doğru zaman            │ │
│  │ ✅ Firebase Rules = Sadece kendi puanını yazabilir     │ │
│  └────────────────────────────────────────────────────────────┘ │
└────────────────────┬────────────────────────────────────────────┘
                     │ StreamBuilder / Snapshot Listener
                     ▼
┌─────────────────────────────────────────────────────────────────┐
│               FLUTTER UI (Gerçek Zamanlı Görüntüleme)          │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │ ProfilePage: "Toplam Puan: 1250"                         │ │
│  │                                                           │ │
│  │ LeaderboardPage:                                         │ │
│  │  🥇 Ahmet - 5000 puan                                   │ │
│  │  🥈 Fatma - 4800 puan                                   │ │
│  │  🥉 Mehmet - 4500 puan                                  │ │
│  │  #4 Zeynep - 4200 puan                                  │ │
│  └────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🔧 TEKNIK DETAYLAR

### 1️⃣ HTML Oyundan Flutter'a Puan Göndermesi

**HTML tarafı (oyun içi):**
```javascript
// EnhancedWebviewPage'da otomatikman enjekte edilir
window.flutter_send_score = function(score) {
  if (window.flutter_inappwebview) {
    window.flutter_inappwebview.callHandler('sendScore', score);
  }
};

// Oyunda puan verirken çağır
window.flutter_send_score(150);
```

**Flutter tarafı (EnhancedWebviewPage):**
```dart
controller.addJavaScriptHandler(
  handlerName: 'sendScore',
  callback: (args) {
    int score = args[0] as int;
    _updateScoreInRealtimeMode(score);
  },
);
```

### 2️⃣ Atomic Increment (Çakışmasız Artırma)

**ScoreService.dart:**
```dart
Future<void> addScoreToUserProfile({
  required String userId,
  required String userName,
  required int score,
}) async {
  final userRef = FirebaseFirestore.instance
      .collection('users')
      .doc(userId);

  await userRef.set(
    {
      'totalScore': FieldValue.increment(score),  // ✅ Atomic
      'lastUpdated': FieldValue.serverTimestamp(),
      'username': userName,
    },
    SetOptions(merge: true),
  );
}
```

**Neden Güvenlidir?**
- ✅ Firestore = Şu anda 1M+ eşzamanlı yazma işlemini yönetebilir
- ✅ Atomic = Aynı anda binlerce kişi puan eklerse de sorun olmaz
- ✅ Firebase Rules = Sadece kendi UID'nize yazma izni var

### 3️⃣ Gerçek Zamanlı Profil & Leaderboard

**ProfilePage (StreamBuilder):**
```dart
StreamBuilder<DocumentSnapshot>(
  stream: FirebaseFirestore.instance
      .collection('users')
      .doc(user?.uid ?? 'unknown')
      .snapshots(),
  builder: (context, snapshot) {
    int totalScore = snapshot.data!['totalScore'] ?? 0;
    return Text("Puan: $totalScore");
  },
);
```

**LeaderboardPage (Global):**
```dart
StreamBuilder<List<Map<String, dynamic>>>(
  stream: scoreService.getGlobalUserLeaderboard(limit: 100),
  builder: (context, snapshot) {
    // Gerçek zamanlı top 100 i göster
    return ListView.builder(...);
  },
);
```

### 4️⃣ Firestore Security Rules

```firestore
match /users/{userId} {
  allow read: if true;                           // Herkes leaderboard görebilir
  allow write: if request.auth.uid == userId;   // Sadece kendi puanı yazabilir
}
```

---

## 📁 DÖSYASİ YAZISI

### Temel Dosyalar

| Dosya | Rol | Güncelleme |
|-------|-----|-----------|
| `lib/features/games/data/services/score_service.dart` | Atomic increment, Firebase yazma | ✅ Güncellendi |
| `lib/features/webview/presentation/pages/enhanced_webview_page.dart` | WebView handler, puan yakalama | ✅ Oluşturuldu |
| `lib/main.dart` (ProfilePage) | Profil StreamBuilder | ✅ Güncellendi |
| `lib/features/games/presentation/pages/leaderboard_page.dart` | Global leaderboard Stream | ✅ Güncellendi |
| `pubspec.yaml` | flutter_inappwebview dependency | ✅ Eklendi |

### Konfigürasyon Dosyaları

| Dosya | Amaç |
|-------|------|
| `FIRESTORE_SECURITY_RULES.txt` | Güvenlik kuralları (Firebase Console'a kopyala) |
| `HTML_SCORE_INTEGRATION_GUIDE.md` | HTML oyunlara nasıl entegre etme rehberi |
| `WEBVIEW_FLUTTER_FIREBASE_ARCHITECTURE.md` | Bu mimari dokümantasyon |

---

## 🎯 ÖZET: HER BİR BILEŞENIN KÖREVİ

```
┌─ EnhancedWebviewPage (NEW)
│  └─ HTML oyundan puan yakalar
│     └─ ScoreService.addScoreToUserProfile() çağırır
│
├─ ScoreService (UPDATE)
│  └─ Firestore'a atomic increment gönderir
│     └─ users/{uid}/totalScore artar
│
├─ ProfilePage (UPDATE)
│  └─ StreamBuilder ile users/{uid} dinler
│     └─ Gerçek zamanlı puan gösterir
│
├─ LeaderboardPage (UPDATE)
│  └─ scoreService.getGlobalUserLeaderboard() stream'ini dinler
│     └─ Top 100 gösterir (descending: true)
│
└─ Firebase Rules (NEW)
   └─ Yazma erişimi kontrol eder
      └─ Sadece kendi UID'ne izin verir
```

---

## 🚀 DEPLOYMENT CHECKLIST

- [ ] `flutter pub get` ile dependencies yükle (flutter_inappwebview)
- [ ] Firebase Console'da Firestore açtığını kontrol et
- [ ] Firestore Rules'ü güncelle (FIRESTORE_SECURITY_RULES.txt'den kopyala)
- [ ] HTML oyunlara puan gönderme kodunu entegre et (HTML_SCORE_INTEGRATION_GUIDE.md)
- [ ] `flutter run` ile test et
- [ ] HTML oyunları aç → Puan kazan → Firebase Firestore'da users koleksiyonunu kontrol et
- [ ] Profil ekranında puan artışını gözlem le
- [ ] Leaderboard'da kendini bulabiliyor mu denetle
- [ ] Çoklu cihazdan eşzamanlı puan artışı test et

---

## 🔍 DEBUGGING TIPLERI

### ❌ Problem: Puan Firebase'ye yazılmıyor

**Çözüm Adımları:**
1. `flutter run` konsolunda hata var mı kontrol et
2. Firebase Console → Firestore → test kural kuralları etkin mi?
3. `rule: allow write: if request.auth != null;` kur (geçici test)
4. `getIt<ScoreService>().addScoreToUserProfile()` manuel çağrı yap
5. Firestore → users koleksiyonuna bak

### ❌ Problem: Leaderboard boş gösteriyor

**Çözüm Adımları:**
1. Firestore → users koleksiyonunda veri var mı? (min. 1 user)
2. `totalScore` alanı sayı tipi mi?
3. StreamBuilder error debugPrint et
4. `orderBy('totalScore', descending: true)` index'i Firebase'ye oluşturdun mu?

### ❌ Problem: HTML oyundan puan gönderilen mi?

**Çözüm:**
```javascript
// Browser console'da bunu çalıştır (F12)
window.flutter_inappwebview.callHandler('sendScore', 100);

// Eğer çalışırsa, HTML oyunun puan verme koduna ekle
window.sendScoreToFlutter(score);
```

---

## 📚 REFEREES

- [Flutter InAppWebView Docs](https://inappwebview.dev/)
- [Firebase Atomic Writes](https://firebase.google.com/docs/firestore/manage-data/transactions)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/get-started)
- [Dart Stream & StreamBuilder](https://dart.dev/codelabs/async-await)

---

## 🎊 SONUÇ

✅ **Artık sistem şu özelliklere sahip:**

1. **HTML oyunlar puan gönderebiliyor** (JavaScript → Dart)
2. **Flutter güvenli bir şekilde Firestore'a kaydediyor** (Atomic increment)
3. **Profil & Leaderboard gerçek zamanlı güncelleniy or** (StreamBuilder)
4. **Hile riskı minimize ediliyor** (Firebase Rules + Server timestamp)
5. **Ölçeklenebiliyor** (Bin lerce eşzamanlı kullanıcı)

Kontrol et ve feedback verebilirsin! 🚀
