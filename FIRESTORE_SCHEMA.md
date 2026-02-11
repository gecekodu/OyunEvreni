# 🗄️ Firestore Veritabanı Şeması

## 📋 Koleksiyonlar (Collections)

### 1. **users** - Kullanıcı Genel Verileri
Kişisel kullanıcı istatistiklerine ve sıralamalarına sahiptir.

**Yol**: `/users/{userId}`

**Alanlar** (Fields):
| Alan | Tip | Açıklama |
|------|-----|----------|
| `uid` | String | Firebase Auth User ID (Otomatik - Document ID) |
| `email` | String | Kullanıcı e-posta adresi |
| `displayName` | String | Kullanıcı adı |
| `photoURL` | String | Profil resmi URL'si (isteğe bağlı) |
| `totalScore` | Number | Tüm oyunlardan toplam puan |
| `totalGamesPlayed` | Number | Oynanmış toplam oyun sayısı |
| `globalRank` | Number | Global sıralamadaki konumu |
| `lastGameTime` | Timestamp | Son oynanış zamanı |
| `createdAt` | Timestamp | Hesap oluşturulma tarihi |
| `updatedAt` | Timestamp | Son güncelleme zamanı |

**Örnek Veri**:
```json
{
  "uid": "user123abc",
  "email": "user@example.com",
  "displayName": "Ahmet",
  "photoURL": "https://...",
  "totalScore": 45830,
  "totalGamesPlayed": 127,
  "globalRank": 15,
  "lastGameTime": "2024-01-15T14:30:00Z",
  "createdAt": "2024-01-01T10:00:00Z",
  "updatedAt": "2024-01-15T14:30:00Z"
}
```

---

### 2. **game_scores** - Oyun Skorları (Detaylı)
Her oyun oturumunun skorunu kaydeder. Sıralamalar ve istatistikler için kullanılır.

**Yol**: `/game_scores/{scoreId}`

**Alanlar** (Fields):
| Alan | Tip | Açıklama |
|------|-----|----------|
| `scoreId` | String | Benzersiz skor ID'si (Document ID) |
| `userId` | String | Kullanıcı ID'si (users koleksiyonundan referans) |
| `userName` | String | Kullanıcı adı (hızlı okuma için) |
| `userAvatar` | String | Kullanıcı avatar URL'si (isteğe bağlı) |
| `gameId` | String | Oyun ID'si (örn: "besin-ninja-001") |
| `gameName` | String | Oyun adı (örn: "Besin Ninja") |
| `gameType` | String | Oyun tipi (örn: "besin_ninja") |
| `score` | Number | Oyundan elde edilen skor |
| `duration` | Number | Oyun süresi (saniye cinsinden) |
| `difficulty` | String | Zorluk seviyesi ("easy", "medium", "hard") |
| `completedAt` | Timestamp | Oyun tamamlanma zamanı |
| `device` | String | Oynan cihaz tipi ("web", "mobile", "tablet") |

**Fihristler (Indexes)**:
- `userId` + `completedAt` (DESC)
- `gameId` + `score` (DESC)
- `completedAt` (DESC)

**Örnek Veri**:
```json
{
  "scoreId": "score_abc123",
  "userId": "user123abc",
  "userName": "Ahmet",
  "userAvatar": "https://...",
  "gameId": "besin-ninja-001",
  "gameName": "Besin Ninja",
  "gameType": "besin_ninja",
  "score": 8750,
  "duration": 245,
  "difficulty": "hard",
  "completedAt": "2024-01-15T14:30:00Z",
  "device": "web"
}
```

---

### 3. **game_statistics** - Oyun İstatistikleri (Özet)
Her oyun için genel istatistikleri saklar (Yüksek skor, ortalama, vb).

**Yol**: `/game_statistics/{gameId}`

**Alanlar** (Fields):
| Alan | Tip | Açıklama |
|------|-----|----------|
| `gameId` | String | Oyun ID'si (Document ID) |
| `gameName` | String | Oyun adı |
| `totalPlays` | Number | Toplam oyun sayısı |
| `totalPlayers` | Number | Benzersiz oyuncu sayısı |
| `highestScore` | Number | En yüksek skor |
| `averageScore` | Number | Ortalama skor |
| `totalPlayTime` | Number | Toplam oyun süresi (saatler) |
| `lastUpdated` | Timestamp | Son güncelleme zamanı |

**Örnek Veri**:
```json
{
  "gameId": "besin-ninja-001",
  "gameName": "Besin Ninja",
  "totalPlays": 1245,
  "totalPlayers": 523,
  "highestScore": 15820,
  "averageScore": 4250,
  "totalPlayTime": 312.5,
  "lastUpdated": "2024-01-15T14:30:00Z"
}
```

---

### 4. **leaderboards** - Sıralamalar (Hızlı Erişim)
Sıralama sayfaları için hızlı erişim sağlayan veri. Şu an kullanılmayan bir koleksiyondur (game_scores'dan hesaplanabilir).

**Yol**: `/leaderboards/{period}/{gameId}`

**Alanlar** (Fields):
| Alan | Tip | Açıklama |
|------|-----|----------|
| `rank` | Number | Sıralama pozisyonu |
| `userId` | String | Kullanıcı ID'si |
| `userName` | String | Kullanıcı adı |
| `score` | Number | Skor |
| `timestamp` | Timestamp | Sıralama oluşturulma zamanı |

---

## 🔐 Firestore Güvenlik Kuralları

```firestore
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    
    // ✅ Kullanıcılar - Kendi verilerini okuyabilir, yönetici tarafından yazılabilir
    match /users/{userId} {
      allow read: if request.auth.uid == userId;
      allow write: if request.auth.uid == userId || isAdmin();
      allow create: if request.auth.uid == userId;
    }
    
    // ✅ Oyun Skorları - Tüm kullanıcılar okuyabilir (sıralama için), sadece kendi skorlarını yazabilir
    match /game_scores/{scoreId} {
      allow read: if request.auth != null;
      allow create: if request.auth.uid == request.resource.data.userId;
      allow update: if request.auth.uid == resource.data.userId && isAdmin();
      allow delete: if isAdmin();
    }
    
    // ✅ Oyun İstatistikleri - Herkese açık okuma, yalnızca backend yazabilir
    match /game_statistics/{gameId} {
      allow read: if request.auth != null;
      allow write: if isAdmin() || isBackendService();
    }
    
    // ✅ Sıralamalar - Herkese açık okuma
    match /leaderboards/{period}/{gameId} {
      allow read: if request.auth != null;
      allow write: if isAdmin() || isBackendService();
    }
    
    // Helper Functions
    function isAdmin() {
      return request.auth.token.admin == true;
    }
    
    function isBackendService() {
      return request.auth.uid == 'backend-service-uid';
    }
  }
}
```

---

## 📊 Veri Akışı Diyagramı

```
┌─────────────────┐
│  Oyuncu Başlat  │
│  Oyun Oyna      │
└────────┬────────┘
         │
         ▼
┌────────────────────────┐
│  HTML Oyun bitir       │
│  postMessage() gönder  │
│  {gameName, score}     │
└────────┬───────────────┘
         │
         ▼
┌────────────────────────────────┐
│  WebViewPage kaparla           │
│  LeaderboardService.addScore() │
│  Firestore'a yaz               │
└────────┬───────────────────────┘
         │
         ├──► game_scores koleksiyonuna ekle
         │
         ├──► users.totalScore güncelle
         │
         └──► game_statistics güncelle
              (Bulut İşlevi ile)
```

---

## 🔄 İmplementasyon Durumu

| Koleksiyon | Status | Not |
|-----------|--------|-----|
| **users** | ✅ Hazır | Firebase Auth ile otomatik oluşturulur |
| **game_scores** | ✅ Hazır | LeaderboardService tarafından yazılıyor |
| **game_statistics** | ⏳ İsteğe bağlı | Cloud Function ile otomatik güncellenir |
| **leaderboards** | ⚠️ Opsiyonel | Performans için olabilir |

---

## 📝 Kullanılan Kodlar

### LeaderboardService (game_scores yazma)
**Dosya**: `lib/features/games/data/services/leaderboard_service.dart`

```dart
Future<void> addScore({
  required String gameName,
  required int score,
  required String userId,
  required String userName,
}) async {
  await _firestore.collection('game_scores').add({
    'userId': userId,
    'userName': userName,
    'gameName': gameName,
    'score': score,
    'completedAt': FieldValue.serverTimestamp(),
  });
}
```

### ProfilePage (Firestore okuma)
**Dosya**: `lib/main.dart` (lines ~650-720)

```dart
Future<Map<String, dynamic>> _fetchUserStats() async {
  // Users koleksiyonundan oku
  final userDoc = await firestore.collection('users').doc(userId).get();
  
  // Game_scores'dan hesapla
  final scoresSnapshot = await firestore
      .collection('game_scores')
      .where('userId', isEqualTo: userId)
      .get();
  
  return {...};
}
```

---

## 🚀 Sonraki Adımlar

1. **Cloud Functions** oluşturarak `game_statistics` otomatik güncelle
2. **Firestore Indexes** oluştur (sıralama sorgularında performans için)
3. **Veri Yedekleme** planı düzenle (günlük yedek)
4. **Kullanıcı Silme** işlem ak (GDPR uyumluluğu)

---

**Son Güncelleme**: 15 Ocak 2024
**Sürüm**: 1.0
