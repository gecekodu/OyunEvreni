# 🧪 Puan Sistemi - MANUEL TEST KLAVUZU

## 📋 Test Öncesi Hazırlık

### Requirement Check
- [x] 5 HTML oyun oluşturuldu (Besin Ninja, Lazer Fizik, Matematik Okcusu, Araba Sürütünme, Gezegen Bul)
- [x] postMessage implementasyonu tüm oyunlara eklendi
- [x] LeaderboardService oluşturuldu (300+ satır)
- [x] WebView score capture sistemi kuruldu
- [x] Firebase Auth entegrasyonu yapıldı
- [x] SocialFeedService HTML oyunlar metodları eklendi
- [x] Web build başarıyla tamamlandı ✅

---

## 🎮 TEST 1: HTML Oyun Oynama & Puan Gönderimi

### Senaryo: Besin Ninja Oyna

**Adımlar:**
```
1. App'i aç
2. "Oyunlar" veya "Örnekleri Keşfet" bölümüne git
3. "🥗 Besin Ninja" oyununu seç
4. Oyunu başlat
5. 3 round tamamla (her zaman doğru seç)
6. Oyun bittiğinde "Puan Kaydedildi" mesajı bekle
```

**Beklenen Sonuç:**
```
✅ Oyun UI açılır
✅ Soruları gör (örn: "Hangi gıda grubu?")
✅ Sürükleme mekanikleri çalışır
✅ Oyun biter ve puan gösterilir
✅ SnackBar: "✅ Puan kaydedildi: 85 | Kullanıcı: [kullanıcı adı]"
✅ WebView kapanır
```

**Başarısızlık Senaryoları:**
```
❌ Oyun UI açılmadıysa → HTML asset yolu yanlış
❌ SnackBar görülmeyince → postMessage gönderilemedi
❌ Hata konsolu → Firebase yazma izni yok
```

---

## 📱 TEST 2: Firebase Console'da Veri Kontrol

**Adımlar:**
```
1. Firebase Console aç → firebase.google.com
2. Proje seç
3. Firestore Database bölümü
4. "game_scores" koleksiyonuna git
5. Son eklenen dökümanları kontrol et
```

**Beklenen Sonuç:**
```
✅ game_scores koleksiyonunda yeni dokümalar
✅ Döküman yapısı:
   {
     "gameId": "besin-ninja-001",
     "userId": "[firebase-uuid]",
     "userName": "[kullanıcı-adı]",
     "score": 85,
     "completedAt": Timestamp,
     "userAvatar": "https://ui-avatars.com/..."
   }
✅ Timestamp otomatik ayarlanmış
✅ userId Firebase Auth UID'si (guest-xxx değil)
```

**İleri İnceleme:**
```
1. Birden fazla oyun oyna (5'in hepsini)
2. Firestore'da 5+ dokümanlı game_scores bulunmalı
3. Farklı gameId'ler: besin_ninja, lazer_fizik vb.
4. Score alanı numara (string değil)
```

---

## 🏆 TEST 3: Leaderboard Sayfası

**Adımlar:**
```
1. App ana menüsüne dön
2. "Sıralamalar" veya "Leaderboard" sayfasını aç
3. "Global Tab"'a bak
4. Oyuncu adınızı arayın
```

**Beklenen Sonuç:**
```
✅ Leaderboard sayfası açılır
✅ Global tab'de oyuncular listelenir
✅ Sıralama puanlara göre azalan düzende
✅ Sayfamız listelenmişse:
   📊 Rank: #1, 2, 3... (ya da sıradaki konumu)
   👤 Name: [Kullanıcı Adı]
   ⭐ Score: [Toplam Puan]
```

**Hata Bulma:**
```
❌ Leaderboard boş gözüküyor
   → Firestore'da gerçekten veri var mı kontrol et
   → userId'ler eşleşiyor mu?

❌ Sıralama yanlış
   → Top puan real time update ediliyor mu?
   → getGlobalLeaderboard() doğru sıralıyor mu?

❌ Veriler liveBinding değişmiyor
   → StreamBuilder çalışıyor mu?
   → Listen yapılıyor mu?
```

---

## 🔥 TEST 4: Trending Oyunlar

**Adımlar:**
```
1. LeaderboardPage'de
2. "🔥 Trending" tabına tıkla
3. Ayın en çok oynanan oyunlarını gör
4. En üstte en çok oynanan oyun olmalı
```

**Beklenen Sonuç:**
```
✅ Trending tab açılır
✅ Oyunlar listelenir:
   Örn:
   1. 🥗 Besin Ninja - Oynanma: 5 kez
   2. 🔦 Lazer Fizik - Oynanma: 3 kez
   3. 🏹 Matematik Okcusu - Oynanma: 2 kez

✅ Son 30 günün verileri gösterilir
✅ Ortalama skor gösterilir (isteğe bağlı)
```

---

## 🎯 TEST 5: Sosyal Akış - HTML Oyunlar

**Adımlar:**
```
1. "Sosyal Akış" veya "Feed" sayfasını aç
2. Sayfayı scroll yap
3. 5 HTML oyunun tamamı görülmeli
```

**Beklenen Sonuç:**
```
✅ Feed yükleniri
✅ HTML oyunlar kartları:
   - 🥗 Besin Ninja
   - 🔦 Lazer Fizik
   - 🏹 Matematik Okcusu
   - 🚗 Sürütünme Yarışı
   - 🪐 Gezegen Bul

✅ Her oyunun:
   - İkonu ✅
   - Başlığı ✅
   - Açıklaması ✅
   - Kategori etiketi ✅
   - Zorluk seviyesi ✅
```

---

## 📊 TEST 6: Tüm 5 Oyunun Puanı

**Test Matrix:**

| Oyun | Puanlama | Başarı | Firestore | Leaderboard |
|------|----------|--------|-----------|------------|
| 🥗 Besin Ninja | 0-100 | ? | ? | ? |
| 🔦 Lazer Fizik | 0-100 | ? | ? | ? |
| 🏹 Matematik Okcusu | 0-100 | ? | ? | ? |
| 🚗 Sürütünme Yarışı | 0-100 | ? | ? | ? |
| 🪐 Gezegen Bul | 0-100 | ? | ? | ? |

**Test Prosedürü:**
```
For each game:
  1. Oyununu oyna
  2. Oyun bitir (herhangi bir skor)
  3. SnackBar beklemelidir: "✅ Puan kaydedildi"
  4. Firebase'e git, game_scores kontrol et
  5. Leaderboard'a git, puanını gör
  6. Matrix'de ✅ işaretle
```

**Test Tamamlama Kriteri:**
```
✅ Tüm 5 oyun için postMessage çalışıyor
✅ Tüm 5 oyun için Firestore'a yazılıyor
✅ Tüm 5 oyun Leaderboard'da görülüyor
✅ Puanlar doğru ve 0-100 aralığında
```

---

## 🔐 TEST 7: Firebase Auth Entegrasyonu

**Kontrol Listesi:**
```
[ ] Oyuncuya login istedi mi?
[ ] Giriş yapılmadığında "guest-xxx" ID'si kullanılıyor mu?
[ ] Giriş yapıldığında Firebase UID gösterildi mi?
[ ] DisplayName doğru kaydediliyor mu?
[ ] Avatar (photoURL) gösteriliyorme?
```

**Test:**
```
1. App başlat (login'siz)
2. Oyun oyna
3. Firestore'da userId: "guest-..." olmalı
4. Firebase Auth'a giriş yap
5. Tekrar oyun oyna
6. Firestore'da userId: [firebase-uuid] olmalı
```

---

## 🚨 Bilinen Sorunlar & Çözümler

### Problem 1: Firestore Yazma Başarısız
```
❌ Fehlermeldung: "Missing or insufficient permissions"

✅ Çözüm:
1. Firebase Console → Firestore
2. Rules sekmesi → Edit Rules
3. Aşağıdaki kodu ekle:

rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /game_scores/{document=**} {
      allow read: if true;
      allow create: if request.auth != null;
      allow update: if request.auth.uid == resource.data.userId;
      allow delete: if request.auth.uid == resource.data.userId;
    }
    match /users/{document=**} {
      allow read: if true;
      allow write: if request.auth.uid == document;
    }
  }
}
```

### Problem 2: postMessage Yakalanmıyor
```
❌ Oyun bittiğinde SnackBar görmüyorum

✅ Debug:
1. Chrome DevTools aç (Web)
2. Console'a bak, hata var mı?
3. "_handleGameScore" methoduna breakpoint koy
4. Oyun oyna ve gözlemle

Olası Sebepler:
- WebView başlatılmamış
- JavaScriptChannel kaydedilmemş
- HTML'de window.parent.postMessage hatalı
```

### Problem 3: Leaderboard Boş
```
❌ Global tab'de oyuncu yok

✅ Debug:
1. Firebase'de gerçekten veri var mı?
2. SearchStream çalışıyor mı? (debug: print ekle)
3. where/orderBy cümlecikleri doğru mu?

Test Query:
- Firebase Console'da direkt query çalıştır:
  db.collection('game_scores').orderBy('score', 'desc').limit(50)
```

### Problem 4: Puan Yanlış
```
❌ Firestore'da puan = 50, ama oyunda 85 gösterildi

✅ Debug:
1. HTML'deki hesaplama doğru mu?
2. Window.parent.postMessage'de score değeri doğru mu gönderiliyor?
3. _handleGameScore'de score parse edilişi doğru mu?
4. saveGameScore'e iletilen değer doğru mu?
```

---

## 📱 Platformlara Özel Notlar

### Web
```
✅ Tam destekleniyor
✅ postMessage: window.parent.postMessage
✅ JavaScript Channel: Çalışıyor
⚠️ CORS policies dikkatli olun
```

### Android
```
⚠️ WebView test edilmedi
ℹ️ JavaScriptInterface kullan
ℹ️ addJavaScriptInterface method'u ekle
```

### iOS
```
⚠️ WKWebView test edilmedi
ℹ️ WKScriptMessageHandler implement et
ℹ️ addScriptMessageHandler method'u ekle
```

---

## ✅ Test Tamamlama Kontrol Listesi

```
SAYFA 1: OYUNLAR
[ ] 🥗 Besin Ninja açılıyor
[ ] 🔦 Lazer Fizik açılıyor
[ ] 🏹 Matematik Okcusu açılıyor
[ ] 🚗 Sürütünme Yarışı açılıyor
[ ] 🪐 Gezegen Bul açılıyor

SAYFA 2: PUAN KAYDEDILME
[ ] Besin Ninja: Puan kaydedildi (SnackBar)
[ ] Lazer Fizik: Puan kaydedildi (SnackBar)
[ ] Matematik Okcusu: Puan kaydedildi (SnackBar)
[ ] Sürütünme Yarışı: Puan kaydedildi (SnackBar)
[ ] Gezegen Bul: Puan kaydedildi (SnackBar)

SAYFA 3: FIRESTORE VERİSİ
[ ] game_scores koleksiyonunda veriler var
[ ] Her oyun için en az 1 döküman var
[ ] gameId'ler doğru
[ ] userId'ler Firebase UID
[ ] Score alanları sayısal
[ ] completedAt timestamp var

SAYFA 4: LEADERBOARD
[ ] Global tab açılıyor
[ ] Oyuncular sıralanmış
[ ] Puanlar doğru
[ ] Trend tab açılıyor
[ ] Oyunlar oynanma sayısına göre sıralı

SAYFA 5: SOSYAL AKIŞ
[ ] 5 HTML oyun görülüyor
[ ] Her oyunun kartı tam
[ ] İkonlar doğru
[ ] Linkler çalışıyor

SONUÇ
[ ] TÜM TESTLER GEÇTİ ✅
```

---

## 🎯 Başarı Kriterleri

**BAŞARILI Sistem = Tüm bunlar çalışıyor:**

1. ✅ Oyunlar açılıyor ve çalışıyor
2. ✅ postMessage gönderiliyor (HTML → Dart)
3. ✅ Puan Firestore'da kaydediliyor
4. ✅ Leaderboard verileri getiriyor ve gösteriyor
5. ✅ 5 oyunun tamamından veri toplanıyor
6. ✅ Firebase Auth entegrasyonu çalışıyor
7. ✅ Sosyal akışta oyunlar görülüyor
8. ✅ Veri çekilebiliyor ve analiz ediliyor

---

## 📋 Raporlama

**Test Başarılı olursa:**
```
✅ Sistem HAZIR
   - Puan sistemi: ÇALIŞIYOR
   - Leaderboard: ÇALIŞIYOR
   - Veri çekimi: BAŞARILI
   - 5 oyun: EKLENDİ VE ÇALIŞIYOR

Yapılması Gerekenler (Gelecek Aşamalar):
   1. Analytics entegrasyonu (opsiyonel)
   2. Push notifications (opsiyonel)
   3. Social sharing (opsiyonel)
   4. Offline leaderboard caching
```

**Test Başarısız olursa:**
```
❌ Sorun Nedir:
   [Buraya yazın]

❌ Hata Mesajı:
   [Full error stack]

❌ Olası Çözüm:
   [Try...]
```

---

**Hazırlandı:** 11 Şubat 2026
**Durum:** HAZIR TEST İÇİN ✅
**Beklenen Sonuç:** TÜMSELER BAŞARILI
