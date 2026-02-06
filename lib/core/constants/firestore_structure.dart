// 🗃️ Firestore Veritabanı Yapısı Belgesi
// 
// Bu dosya Firestore'da oluşturulması gereken koleksiyonlar ve 
// belgelerin yapısını tanımlar.
// 
// Firebase Console'dan manuel olarak oluşturabilir veya
// Security Rules'de otomatik oluşturmayı izin verebilirsiniz.

/*

📋 KOLEKSİYONLAR VE YAPILARI:

1️⃣ users KOLEKSIYONU
   ├─ Belge ID: {userId} (Firebase Auth UID)
   └─ Alanlar:
       {
         "uid": "string",
         "email": "string",
         "displayName": "string",
         "photoUrl": "string (opsiyonel)",
         "createdAt": "timestamp",
         "lastLogin": "timestamp",
         "totalGamesCreated": "integer",
         "totalGamesPlayed": "integer",
         "averageRating": "number (0-5)"
       }

2️⃣ games KOLEKSIYONU
   ├─ Belge ID: {gameId} (otomatik generate)
   └─ Alanlar:
       {
         "gameId": "string",
         "creatorUserId": "string (users.uid'ye referans)",
         "creatorName": "string",
         "lesson": "string (Matematik, Fen, Türkçe, vb.)",
         "topic": "string (Işığın yansıması, vb.)",
         "grade": "string (5. Sınıf, 6. Sınıf, vb.)",
         "difficulty": "string (easy, medium, hard)",
         "title": "string",
         "description": "string",
         "jsonDefinition": "map (oyun konfigürasyonu)",
         "rating": "number (0-5, ortalama)",
         "playCount": "integer",
         "ratingCount": "integer",
         "createdAt": "timestamp",
         "updatedAt": "timestamp (opsiyonel)"
       }

3️⃣ gameResults KOLEKSIYONU
   ├─ Belge ID: {otomatik generate}
   └─ Alanlar:
       {
         "gameId": "string (games.gameId'ye referans)",
         "userId": "string (users.uid'ye referans)",
         "score": "integer",
         "completed": "boolean",
         "timeSpent": "integer (saniye)",
         "playedAt": "timestamp"
       }

4️⃣ ratings KOLEKSIYONU
   ├─ Belge ID: "{gameId}-{userId}"
   └─ Alanlar:
       {
         "gameId": "string (games.gameId'ye referans)",
         "userId": "string (users.uid'ye referans)",
         "rating": "number (1-5)",
         "comment": "string (opsiyonel)",
         "createdAt": "timestamp"
       }

📊 İNDEKSLER (Sorgulamayı hızlandırır):
   - games koleksiyonunda: (lesson, createdAt)
   - games koleksiyonunda: (difficulty, rating)
   - gameResults koleksiyonunda: (userId, playedAt)
   - ratings koleksiyonunda: (gameId, rating)

🔒 FIRESTORE SECURİTY RULES (başlangıç):

match /databases/{database}/documents {
  // Kullanıcılar sadece kendi verisini görebilir
  match /users/{userId} {
    allow read: if request.auth.uid == userId;
    allow write: if request.auth.uid == userId;
  }

  // Oyunlar herkes tarafından okunabilir
  match /games/{gameId} {
    allow read: if true;
    allow create: if request.auth != null;
    allow update, delete: if request.auth.uid == resource.data.creatorUserId;
  }

  // Oyun sonuçları gizli
  match /gameResults/{document=**} {
    allow read: if request.auth.uid == resource.data.userId;
    allow create: if request.auth != null && request.auth.uid == request.resource.data.userId;
  }

  // Puanlar
  match /ratings/{ratingId} {
    allow read: if true;
    allow create: if request.auth != null;
    allow update, delete: if request.auth.uid == resource.data.userId;
  }
}

*/

// Dart'ta Firestore koleksiyonlarını referans olarak kullan:

class FirestoreCollections {
  static const String users = 'users';
  static const String games = 'games';
  static const String gameResults = 'gameResults';
  static const String ratings = 'ratings';
}

// Örnek kullanım:
// _firestore.collection(FirestoreCollections.games).get();
