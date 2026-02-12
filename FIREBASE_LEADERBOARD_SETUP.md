# 🏆 Firebase Genel Sıralama Sistemi

## Veritabanı Yapısı

### 1. **Users Collection** (`/users/{userId}`)
Tüm kullanıcıların profil verilerini tutuyor:

```
/users/{userId}
  ├── username: string (Kullanıcı adı)
  ├── email: string (E-posta)
  ├── totalScore: number (Genel toplam puan) ← SIRALAMADA KULLANILIR
  ├── userAvatar: string (Avatar URL)
  ├── diamonds: number (Elmas sayısı)
  ├── lastUpdated: timestamp (Son güncelleme zamanı)
  └── ... diğer alanlar
```

### 2. **Scores Collection** (`/scores/{scoreId}`)
Her oyun oturumunun skorlarını tutuyor:

```
/scores/{scoreId}
  ├── gameId: string
  ├── userId: string
  ├── userName: string
  ├── score: number
  ├── completedAt: timestamp
  └── ... oyun detayları
```

---

## Sıralama Mantığı

### 🌍 Genel Sıralama Akışı:
1. Oyuncu bir oyun tamamlar
2. `Score` kaydedilir (`/scores` collection'u)
3. Oyuncunun `users/{userId}/totalScore` → Atomic Increment
4. Uygulama `users` collection'ından en yüksek puanları sırayı getir
5. **LeaderboardPage** bu sıralamayı gösterir

### 📊 Sıralama Sorgusu (Dart - ScoreService):
```dart
getGlobalUserLeaderboard() {
  return firestore
    .collection('users')
    .snapshots()  // Tüm kullanıcıları al
    .map((snapshot) {
      // İstemci tarafında totalScore'a göre sırala
      users.sort((a, b) => b['totalScore'].compareTo(a['totalScore']));
      return users;
    });
}
```

---

## Firebase Console'da Sıralamayı Görmek

### ✅ Adım 1: Users Collection'a Git
1. Firebase Console → Firestore Database
2. **collections** sekmesine tıkla
3. **users** collection'unu seç
4. Her dökümanın `totalScore` alanını gör

### ✅ Adım 2: En Yüksek Puanları Sıralamak
Firestore UI sınırlı filterlamalar yapabiliyor. Tam sıralamayı görmek için:
1. Bir sorgu yapabilirsin: `totalScore > 0` filter + `orderBy totalScore DESC`
2. Veya Flutter uygulamasında LeaderboardPage'a git

---

## İndeks Gereksinimleri

Firebase'nin optimal perfomans için aşağıdaki indeks gerekli:

```
Collection: users
Fields:
  - totalScore (Descending) ← SIRALAMADA KULLANILIR
  - createdAt (Ascending) ← SECONDARY SORT
```

**Firebase otomatik olarak öneribir, Composite Index oluştur.**

---

## Veri Güvenliği

### Security Rules:
```javascript
match /users/{userId} {
  allow read: if true;  // Herkes leaderboard görebilir
  allow write: if request.auth.uid == userId;  // Sadece kendi verisi yazabilir
}
```

---

## Performans Optimizasyonları

✅ **Atomic Increment** - Eşzamanlı yazmaları handles
✅ **Stream Real-time** - Leaderboard canlı güncellemeler
✅ **Limit 100** - Her sorguda ilk 100 kullanıcı
✅ **Client-side Sort** - Esneklik için istemcide sıralama

---

## Debugging

### Firebase Console'da Veri Kontrol:
1. **Firestore** → `users` collection
2. Her dokumentun `totalScore` alanını kontrol et
3. Değer 0'dan fazlaysa sıralamada görünecektir

### Flutter Loglarında Kontrol:
```
I/Compat: Global leaderboard bulundu: 25 kullanıcı
```

---

## Gelecek Geliştirmeler

- [ ] Cloud Function ile otomatik sıralama cache
- [ ] Haftalık/Aylık sıralamalar
- [ ] Rank badge sistemi
- [ ] Denormalize leaderboard collection

