// 📋 IMPLEMENTATION CHECKLIST - Geliştirme Adımları

/*

🎯 PHASE 1: TEMEL ALTYAPI (✅ TAMAMLANDI)
═══════════════════════════════════════════════════════

✅ Flutter proje yapısı
✅ Pubspec.yaml - Tüm bağımlılıklar
✅ Clean Architecture dizin yapısı
✅ Firebase Service (Auth + Firestore)
✅ Gemini Service (AI oyun üretimi)
✅ WebView Service (HTML oyun entegrasyonu)
✅ HTML Oyun Motoru (game_engine.html)
✅ Exception & Error handling
✅ Firestore koleksiyon tasarımı


🔥 PHASE 2: AUTHENTICATION (NEXT)
═══════════════════════════════════════════════════════

⏳ Yapılacaklar:
  ☐ Login sayfası UI
  ☐ Signup sayfası UI
  ☐ LoginProvider (State Management)
  ☐ Şifre sıfırlama
  ☐ Social login (Google)
  ☐ Session management
  ☐ Auth guards


🎮 PHASE 3: GAMES FEATURE (AFTER AUTH)
═════════════════════════════════════════════════════════

⏳ Yapılacaklar:
  ☐ GamesProvider (State Management)
  ☐ Home page - Oyun listesi
  ☐ Game detail sayfası
  ☐ Play game sayfası (WebView)
  ☐ Game results sayfası
  ☐ Search & filter
  ☐ Oyun caching


🤖 PHASE 4: GAME CREATION (AFTER GAMES)
═════════════════════════════════════════════════════════

⏳ Yapılacaklar:
  ☐ Create game sayfası
  ☐ Game form
  ☐ Gemini API integration
  ☐ Game preview
  ☐ Save to Firestore
  ☐ Loading states
  ☐ Error handling


⭐ PHASE 5: COMMUNITY FEATURES (AFTER CREATION)
═════════════════════════════════════════════════════════

⏳ Yapılacaklar:
  ☐ Rating system UI
  ☐ Comments feature
  ☐ User profiles
  ☐ User's games list
  ☐ Leaderboards
  ☐ Sharing (WhatsApp, etc.)


🧪 PHASE 6: TESTING & OPTIMIZATION
═════════════════════════════════════════════════════════

⏳ Yapılacaklar:
  ☐ Unit tests
  ☐ Widget tests
  ☐ Integration tests
  ☐ Performance optimization
  ☐ Firebase security rules
  ☐ Analytics


📱 PHASE 7: DEPLOYMENT
═════════════════════════════════════════════════════════

⏳ Yapılacaklar:
  ☐ Android APK build
  ☐ iOS IPA build
  ☐ Play Store submission
  ☐ App Store submission


═════════════════════════════════════════════════════════

👇 ÖNERİLEN SONRAKI ADIM:

PHASE 2: LOGIN & AUTHENTICATION SAYFALARINI YAZIN

Dosyalar:
  lib/features/auth/presentation/pages/login_page.dart
  lib/features/auth/presentation/pages/signup_page.dart
  lib/features/auth/presentation/widgets/auth_form.dart
  
Provider'ı oluştur:
  lib/features/auth/presentation/providers/auth_provider.dart

Şimdi VS Code AI ajan'ına geç,
login + signup sayfalarını oluşturmasını söyle.

*/

import 'package:flutter/material.dart';

// 🎨 Başlangıç Theme Renkler
class QuickStartColors {
  static const primaryGradient = [
    Color(0xFF667eea),
    Color(0xFF764ba2),
  ];
  static const successColor = Color(0xFF27ae60);
  static const errorColor = Color(0xFFe74c3c);
  static const warningColor = Color(0xFFf39c12);
}

// 📊 Gemini Prompt Örnekleri
class GeminiPromptExamples {
  static const mathGamePrompt = '''
  DERS: Matematik
  KONU: Kesirler
  SINIF: 5. Sınıf
  ZORLUK: Orta
  ÖĞRENİM HEDEFİ: Kesirleri karşılaştırmayı öğren
  
  Kullanıcı kesirler arasında doğru olanı seçmeli.
  ''';

  static const scienceGamePrompt = '''
  DERS: Fen Bilimleri
  KONU: Işığın Yansıması
  SINIF: 6. Sınıf
  ZORLUK: Zor
  ÖĞRENİM HEDEFİ: Yansıma kanununu anlama
  
  Kullanıcı aynayı döndürerek ışığı hedefte hita ettirmeli.
  ''';

  static const turkishGamePrompt = '''
  DERS: Türkçe
  KONU: Kelime Anlamları
  SINIF: 4. Sınıf
  ZORLUK: Kolay
  ÖĞRENİM HEDEFİ: Kelime hazinesini geliştir
  
  Kelime-anlam eşleştirme oyunu.
  ''';
}

// 📱 API Response Model Örnekleri
class ApiResponseExamples {
  // Gemini API Response örneği
  static const Map<String, dynamic> gameJsonExample = {
    'gameType': 'mirror_reflection',
    'title': 'Işığın Yansıması',
    'description': 'Işını hedefe yönlendir',
    'level': 'medium',
    'goal': 'Işığı hedefe ulaştır',
    'objects': [
      {'type': 'light', 'x': 50, 'y': 150, 'angle': 30},
      {'type': 'mirror', 'x': 300, 'y': 150, 'angle': 45},
      {'type': 'target', 'x': 450, 'y': 250},
    ],
    'rules': [
      'Gelme açısı = Yansıma açısı',
      'Aynayı döndürebilirsin',
    ],
    'successCriteria': {'hitTarget': true},
  };

  // Firestore User document örneği
  static const Map<String, dynamic> userDocExample = {
    'uid': 'user123',
    'email': 'user@example.com',
    'displayName': 'John Doe',
    'createdAt': '2024-02-06T00:00:00.000Z',
    'totalGamesCreated': 3,
    'totalGamesPlayed': 12,
    'averageRating': 4.2,
  };

  // Firestore Game document örneği
  static const Map<String, dynamic> gameDocExample = {
    'gameId': 'game123',
    'creatorUserId': 'user123',
    'creatorName': 'John Doe',
    'lesson': 'Fen Bilimleri',
    'topic': 'Işığın Yansıması',
    'grade': '6. Sınıf',
    'difficulty': 'medium',
    'title': 'Işığın Yansıması',
    'description': 'Işını hedefe yönlendir',
    'jsonDefinition': gameJsonExample,
    'rating': 4.5,
    'playCount': 25,
    'ratingCount': 8,
    'createdAt': '2024-02-06T00:00:00.000Z',
  };
}

// 🔐 Environment Constants
class AppConstants {
  // Firebase Project ID
  static const String firebaseProjectId = 'oyun-olustur-ai';

  // Gemini API Model
  static const String geminiModel = 'gemini-2.5-flash-lite';

  // Game limits
  static const int maxGameTitleLength = 100;
  static const int maxGameDescriptionLength = 500;
  static const int maxCommentLength = 500;
  static const int maxGamePlayTime = 3600; // 1 saat

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
}

// 🎯 Quick Start - Usage Examples
class QuickStartGuide {
  /*
  
  1️⃣ FIREBASE SERVICE KULLANMA:
  ══════════════════════════════
  
  final firebaseService = FirebaseService();
  await firebaseService.initialize();
  
  // Mevcut kullanıcı
  final user = firebaseService.currentUser;
  
  // Firestore referansı
  final db = firebaseService.firestore;
  
  
  2️⃣ GEMINI SERVICE KULLANMA:
  ════════════════════════════
  
  final geminiService = GeminiService(apiKey: 'YOUR_API_KEY');
  
  final gameJson = await geminiService.generateGameJson(
    lesson: 'Matematik',
    topic: 'Kesirler',
    grade: '5. Sınıf',
    difficulty: 'medium',
    learningObjective: 'Kesir karşılaştırmasını öğren',
  );
  
  
  3️⃣ WEBVIEW SERVICE KULLANMA:
  ═════════════════════════════
  
  final htmlEngine = await loadGameEngine();
  final webviewService = WebViewService();
  
  final controller = webviewService.initializeWebView(
    htmlPath: htmlEngine,
    onGameResult: (result) {
      print('Score: ${result.score}');
    },
  );
  
  await webviewService.startGame(gameJson);
  final result = await webviewService.getGameResult();
  
  
  4️⃣ AUTH REPOSITORY KULLANMA:
  ════════════════════════════
  
  final authRepo = getIt<AuthRepositoryImpl>();
  
  // Kayıt
  final user = await authRepo.signUpWithEmail(
    email: 'user@example.com',
    password: 'password123',
    displayName: 'John Doe',
  );
  
  // Giriş
  final user = await authRepo.signInWithEmail(
    email: 'user@example.com',
    password: 'password123',
  );
  
  // Çıkış
  await authRepo.signOut();
  
  
  5️⃣ GAMES DATASOURCE KULLANMA:
  ══════════════════════════════
  
  final gamesDs = getIt<GamesRemoteDataSource>();
  
  // Oyun kaydet
  final gameId = await gamesDs.saveGame(
    creatorUserId: userId,
    creatorName: userName,
    lesson: 'Fen',
    topic: 'Işığın Yansıması',
    grade: '6. Sınıf',
    difficulty: 'medium',
    title: 'Oyun Adı',
    description: 'Açıklama',
    jsonDefinition: gameJson,
  );
  
  // Oyunları getir
  final games = await gamesDs.getAllGames(
    lesson: 'Fen',
    difficulty: 'medium',
  );
  
  // Oyunu puanla
  await gamesDs.rateGame(
    gameId: gameId,
    userId: userId,
    rating: 5,
    comment: 'Müthiş oyun!',
  );
  
  
  6️⃣ STATE MANAGEMENT - PROVIDER ÖRNEĞI:
  ═══════════════════════════════════════
  
  // Tanımla
  class GameProvider extends ChangeNotifier {
    GameState _state = GameState.initial;
    List<GameModel> _games = [];
    
    GameState get state => _state;
    List<GameModel> get games => _games;
    
    Future<void> fetchGames() async {
      _state = GameState.loading;
      notifyListeners();
      
      try {
        _games = await datasource.getAllGames();
        _state = GameState.loaded;
      } catch (e) {
        _state = GameState.error;
      }
      notifyListeners();
    }
  }
  
  // Kullan
  Consumer<GameProvider>(
    builder: (context, provider, child) {
      if (provider.state == GameState.loading) {
        return const CircularProgressIndicator();
      }
      return ListView.builder(
        itemCount: provider.games.length,
        itemBuilder: (context, index) {
          return GameCard(game: provider.games[index]);
        },
      );
    },
  )
  
  */
}

// 📚 Firestore Query Örnekleri
class FirestoreQueryExamples {
  // Oyunları sınıfa göre filtrele
  static const String queryByGrade = '''
  db.collection('games')
    .where('grade', isEqualTo: '5. Sınıf')
    .orderBy('rating', descending: true)
    .limit(20)
    .get()
  ''';

  // Kullanıcının oyunlarını getir
  static const String queryUserGames = '''
  db.collection('games')
    .where('creatorUserId', isEqualTo: userId)
    .orderBy('createdAt', descending: true)
    .get()
  ''';

  // Oyun sonuçlarını getir
  static const String queryGameResults = '''
  db.collection('gameResults')
    .where('userId', isEqualTo: userId)
    .orderBy('playedAt', descending: true)
    .limit(50)
    .get()
  ''';

  // Puanlamaları getir
  static const String queryGameRatings = '''
  db.collection('ratings')
    .where('gameId', isEqualTo: gameId)
    .orderBy('createdAt', descending: true)
    .get()
  ''';
}

void main() {
  print('''
╔════════════════════════════════════════════════════════╗
║        🎮 OYUN OLUSTUR - Quick Start Guide            ║
╚════════════════════════════════════════════════════════╝

✅ TAMAMLANDI (6/10 Aşama):
  1. Flutter proje yapısı
  2. Pubspec.yaml bağımlılıkları
  3. Firebase konfigürasyonu
  4. Dizin yapısı
  5. Auth servisleri
  6. HTML oyun motoru

⏳ SONRAKI ADIMLAR:
  
  1. Firebase Console'dan API key'leri al
  2. lib/config/firebase_options.dart güncelle
  3. lib/main.dart'ta Gemini API key'ini gir
  4. flutter pub get çalıştır
  5. Login sayfası UI'sini oluştur (Phase 2)
  
📚 Kaynaklar:
  - README.md - Detaylı proje belgesi
  - firestore_structure.dart - DB yapısı
  - Quick Start Guide - Kullanım örnekleri
  
💡 İPUÇLARı:
  - Assets yüklü (HTML oyun motoru)
  - Firestore security rules ayarla
  - Cihazda test et (flutter run)
  
🤖 AI İLE İLERİ ADIMLAR:
  
  "Authentication sayfalarını (login + signup) oluştur.
   Material Design 3 kullan, modern UI, Türkçe dilinde."
   
  "Home sayfasında oyun listesini göster,
   search ve filtre ekle."
   
  "Create game sayfasında Gemini'ye oyun üret,
   preview'ı göster, Firestore'a kaydet."

═════════════════════════════════════════════════════════
Kod okunabilir, modüler ve ölçeklenebilir tutuldu ✨
═════════════════════════════════════════════════════════
  ''');
}
