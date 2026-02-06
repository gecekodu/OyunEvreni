# 🎮 OYUN OLUSTUR - Eğitici Oyun Platformu

> AI ile eğitici oyunlar oluşturan, mobil-first, community-driven platform

## 📋 Proje Özeti

**Oyun Olustur**, öğretmenlerin ve eğitim uzmanlarının **Gemini AI** yardımıyla eğitici mini oyunlar oluşturabildikleri ve bu oyunların komunite tarafından oynanıp puanlandığı bir mobile uygulamasıdır.

### 🎯 Temel Özellikler

- ✅ **AI ile Oyun Üretimi**: Ders/konu/sınıf/zorluk bilgisiyle Gemini AI, HTML tabanlı oyun oluşturur
- ✅ **HTML Oyun Motoru**: Canvas-based, WebView ile Flutter'a entegre
- ✅ **Firestore Veritabanı**: Oyun tanımları, oyun sonuçları ve puanlamalar
- ✅ **Firebase Auth**: Email + Google girişi
- ✅ **Community Features**: Oyun paylaşma, puanlama, yorum
- ✅ **Responsive Design**: Android + iOS desteği

---

## 🏗️ Mimari & Teknoloji Stack

```
┌─────────────────────────────────────────┐
│ Flutter Mobile App (Android + iOS)      │
├─────────────────────────────────────────┤
│ Clean Architecture / MVVM Pattern        │
├─────────────────────────────────────────┤
│  ┌──────────┐  ┌──────────┐  ┌────────┐ │
│  │ Firebase │  │ Gemini   │  │WebView │ │
│  │ (Auth,   │  │ API      │  │(HTML   │ │
│  │Firestore)│  │(AI Game) │  │Games)  │ │
│  └──────────┘  └──────────┘  └────────┘ │
└─────────────────────────────────────────┘
```

### Teknolojiler
- **Frontend**: Flutter 3.x
- **State Management**: Provider
- **Database**: Firestore (Cloud)
- **Authentication**: Firebase Auth
- **AI**: Gemini Pro API
- **Games**: HTML5 + Canvas + JavaScript
- **Hosting**: Firebase (optional)

---

## 📁 Dizin Yapısı

```
lib/
├── config/
│   ├── app_routes.dart         # Navigation routes
│   ├── app_theme.dart          # UI Theme
│   └── firebase_options.dart   # Firebase config
│
├── core/
│   ├── constants/
│   │   └── firestore_structure.dart
│   ├── errors/
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   ├── network/
│   ├── services/
│   │   ├── firebase_service.dart
│   │   ├── gemini_service.dart
│   │   └── webview_service.dart
│   └── utils/
│
├── features/
│   ├── auth/                   # Kimlik doğrulama
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── pages/
│   │       └── widgets/
│   │
│   ├── games/                  # Oyun yönetimi
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── ai/                     # Gemini entegrasyonu
│   │   ├── data/
│   │   └── domain/
│   │
│   └── webview/                # HTML oyun çerçevesi
│       └── presentation/
│
├── main.dart                   # Entry point
└── ...

assets/
└── html_games/
    └── game_engine/
        └── game_engine.html    # Oyun motoru template
```

---

## 🚀 Kurulum & Başlama

### Gereksinimler
- Flutter SDK >= 3.0
- Dart >= 3.0
- Firebase Project
- Gemini API Key

### Adımlar

1. **Klonla**
```bash
git clone <repo-url>
cd oyun-olustur
```

2. **Bağımlılıkları yükle**
```bash
flutter pub get
```

3. **Firebase konfigüre et**
   - Firebase Console'dan `google-services.json` (Android) ve `GoogleService-Info.plist` (iOS) indir
   - İlgili klasörlere yerleştir
   - `lib/config/firebase_options.dart` güncelle

4. **Gemini API Key ekle**
   - https://ai.google.dev/tutorials/setup adresinden API key al
   - `lib/main.dart` içindeki `YOUR_GEMINI_API_KEY_HERE` yerine ekle

5. **Çalıştır**
```bash
flutter run
```

---

## 🤖 Oyun JSON Şeması

Gemini tarafından üretilen oyun tanımı örneği:

```json
{
  "gameType": "mirror_reflection",
  "title": "Işığın Yansıması",
  "description": "Işını hedefe yönlendirerek yansıma kanununu öğren",
  "level": "medium",
  "goal": "Işığı hedefe ulaştır",
  "objects": [
    {
      "type": "light",
      "x": 50,
      "y": 150,
      "angle": 30
    },
    {
      "type": "mirror",
      "x": 300,
      "y": 150,
      "angle": 45
    },
    {
      "type": "target",
      "x": 450,
      "y": 250
    }
  ],
  "rules": [
    "Gelme açısı = Yansıma açısı",
    "Aynayı döndürebilirsin"
  ],
  "successCriteria": {
    "hitTarget": true
  }
}
```

---

## 🔄 Kullanıcı Akışı

```
┌─────────────┐
│ Giriş / Kayıt│
└──────┬──────┘
       │
       ▼
┌──────────────────┐
│ Oyunları Keşfet │
│ (Browse/Search) │
└──────┬───────────┘
       │
       ├─────────────────┬──────────────┐
       │                 │              │
       ▼                 ▼              ▼
   ▶️ Oyna      ⭐ Puanla    ➕ Oluştur
       │                 │              │
       └──────┬──────────┴──────────────┘
              │
              ▼
        📊 Sonuç & Geri Bildirim
```

---

## 📚 Firestore Koleksiyonları

### `users`
```json
{
  "uid": "string",
  "email": "string",
  "displayName": "string",
  "createdAt": "timestamp",
  "totalGamesCreated": 5,
  "totalGamesPlayed": 12
}
```

### `games`
```json
{
  "gameId": "string",
  "creatorUserId": "string",
  "title": "string",
  "jsonDefinition": { },
  "rating": 4.5,
  "playCount": 45,
  "createdAt": "timestamp"
}
```

### `gameResults`
```json
{
  "gameId": "string",
  "userId": "string",
  "score": 85,
  "completed": true,
  "timeSpent": 120,
  "playedAt": "timestamp"
}
```

### `ratings`
```json
{
  "gameId": "string",
  "userId": "string",
  "rating": 5,
  "comment": "Çok eğlenceli!",
  "createdAt": "timestamp"
}
```

---

## 🤖 Gemini API Prompt Yapısı

Oyun üretimde kullanılan prompt template:

```
DERS: Fen Bilimleri
KONU: Işığın Yansıması
SINIF: 5. Sınıf
ZORLUK: Orta
ÖĞRENİM HEDEFİ: Yansıma kanununu anla ve uygula

[Oyun JSON şemasını döndür]
```

---

## 🔐 Firestore Security Rules

```javascript
match /databases/{database}/documents {
  match /users/{userId} {
    allow read: if request.auth.uid == userId;
    allow write: if request.auth.uid == userId;
  }
  
  match /games/{gameId} {
    allow read: if true;
    allow create: if request.auth != null;
    allow update, delete: if request.auth.uid == resource.data.creatorUserId;
  }
  
  match /gameResults/{document=**} {
    allow read: if request.auth.uid == resource.data.userId;
    allow create: if request.auth != null;
  }
}
```

---

## 📱 Responsive Design Breakpoints

- **Mobile**: < 600px
- **Tablet**: 600px - 1200px
- **Desktop**: > 1200px

---

## 🐛 Debugging & Development

### Hot Reload
```bash
flutter run -v
```

### Firestore Emulator (Geliştirme)
```bash
firebase emulators:start
```

### Tests
```bash
flutter test
```

---

## 📦 Deployment

### Android
```bash
flutter build apk
# veya
flutter build appbundle
```

### iOS
```bash
flutter build ios
```

### Web (Future)
```bash
flutter build web
```

---

## 🤝 Contribution

1. Fork et
2. Branch oluştur (`git checkout -b feature/Xyz`)
3. Commit et (`git commit -am 'Add feature'`)
4. Push et (`git push origin feature/Xyz`)
5. Pull Request aç

---

## 📄 License

MIT License

---

**Enjoy creating educational games! 🎮✨**
