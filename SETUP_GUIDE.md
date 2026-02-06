// 🏗️ PROJE KURULUM VE KONFİGÜRASYON REHBERI

/*

══════════════════════════════════════════════════════════════════
🎮 OYUN OLUSTUR - Kurulum & Konfigürasyon (Setup Guide)
══════════════════════════════════════════════════════════════════

Bu dosya, Flutter projenizi yapılandırmak için gerekli tüm adımları içerir.

═══════════════════════════════════════════════════════════════════

📋 ADIM 1: FIREBASE KURULUMU
═══════════════════════════════════════════════════════════════════

1. Firebase Console'a git: https://console.firebase.google.com

2. Yeni proje oluştur:
   - Project name: "oyun-olustur-ai"
   - Google Analytics'i etkinleştir (opsiyonel)
   - Create Project

3. Android Uygulaması Ekle:
   - Package name: com.oyunolustur.app
   - SHA-1 fingerprint ekle (local development için)
   - google-services.json indir
   - android/app/src/main/ klasörüne yerleştir

4. iOS Uygulaması Ekle:
   - Bundle ID: com.oyunolustur.app
   - GoogleService-Info.plist indir
   - ios/Runner/GoogleService-Info.plist olarak yerleştir

5. Web (İsteğe bağlı):
   - Firebaseappconfig javaScript'i al
   - Web dağıtımında kullan

6. Firebase Credentials al:
   - Project Settings → Web API Key'i kopyala
   - lib/config/firebase_options.dart güncelle

═══════════════════════════════════════════════════════════════════

🔐 ADIM 2: FIREBASE AUTHENTICATION KURULUMU
═══════════════════════════════════════════════════════════════════

1. Firebase Console → Authentication → Sign-in Method

2. Email/Password Provider'ı etkinleştir:
   ✅ Email/Password authentication

3. Google Sign-In Provider'ı etkinleştir:
   ✅ Google provider
   - OAuth Consent Screen'i yapılandır
   - Test users ekle

4. Anonymous Auth (opsiyonel):
   ✅ Anonymous authentication (demo amaçlı)

═══════════════════════════════════════════════════════════════════

🗄️ ADIM 3: FIRESTORE DATABASE KURULUMU
═══════════════════════════════════════════════════════════════════

1. Firebase Console → Firestore Database → Create Database

2. Security Rules seç: "Start in production mode"

3. Region seç: eur1 (Avrupa) veya amer-central1 (Amerika)

4. Create Database

5. Security Rules güncelle:
   - Security Rules tab'ına git
   - Şu kuralları ekle:

   match /databases/{database}/documents {
     // Kimlik doğrulama yapılmışsa yazma izni
     match /users/{userId} {
       allow read: if request.auth.uid == userId;
       allow create: if request.auth.uid == userId;
       allow update, delete: if request.auth.uid == userId;
     }

     // Oyunlar herkese okunur
     match /games/{gameId} {
       allow read: if true;
       allow create: if request.auth != null;
       allow update, delete: if request.auth.uid == resource.data.creatorUserId;
     }

     // Game sonuçları sadece kullanıcısı görebilir
     match /gameResults/{document=**} {
       allow read: if request.auth.uid == resource.data.userId;
       allow create: if request.auth != null;
     }

     // Puanlamalar
     match /ratings/{ratingId} {
       allow read: if true;
       allow create: if request.auth != null;
       allow update, delete: if request.auth.uid == resource.data.userId;
     }
   }

6. Publish rules

═══════════════════════════════════════════════════════════════════

🤖 ADIM 4: GEMINI API KURULUMU
═══════════════════════════════════════════════════════════════════

1. Google AI Studio'ya git: https://ai.google.dev/

2. "Get API Key" butonuna tıkla

3. "Create API key in new Google Cloud project" seç

4. API Key'i kopyala (güvenli bir yerde saklı tut)

5. lib/main.dart güncelleçinde:

   const String geminiApiKey = 'YOUR_GENERATED_API_KEY_HERE';
                                    ↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑

6. Gemini API'nin limitlerini kontrol et:
   - Free tier: 60 requests/minute
   - Production'da Pro tier gerekli

═══════════════════════════════════════════════════════════════════

📦 ADIM 5: FLUTTER PROJECT KURULUMU
═══════════════════════════════════════════════════════════════════

1. Proje dizinine git:
   cd "c:\Oyun Evreni"

2. Bağımlılıkları indir:
   flutter pub get

3. Build runner çalıştır (gerekirse):
   flutter pub run build_runner build

4. Lint problemlerini kontrol et:
   dart analyze

5. iOS bağımlılıkları (macOS kullanıyorsanız):
   cd ios
   pod repo update
   pod install
   cd ..

═══════════════════════════════════════════════════════════════════

🚀 ADIM 6: PROJE AYARLARI
═══════════════════════════════════════════════════════════════════

1. lib/config/firebase_options.dart dosyasını aç

2. Firebase Console'dan aldığın değerleri gir:
   - apiKey (Web API Key)
   - appId (Firebase App ID)
   - messagingSenderId
   - projectId
   - authDomain
   - storageBucket

   Örnek (Android):
   static const FirebaseOptions android = FirebaseOptions(
     apiKey: 'AIzaSyDXXXXXXXXXXXXXXXXXXXXXXXXXX',
     appId: '1:123456789:android:abcdefghijk',
     messagingSenderId: '123456789',
     projectId: 'oyun-olustur-ai',
     storageBucket: 'oyun-olustur-ai.appspot.com',
   );

3. lib/main.dart açarak Gemini API Key'ini gir:
   const String geminiApiKey = 'YOUR_API_KEY_HERE';

═══════════════════════════════════════════════════════════════════

✅ ADIM 7: TEST & VERIFY
═══════════════════════════════════════════════════════════════════

1. Emülatör başlat:
   flutter emulators --launch android_emulator
   veya
   Xcode'dan iOS simulator'ü aç

2. Proje çalıştır:
   flutter run

3. Splash screen görmeli:
   "🎮 Oyun Olustur" yazısı ve loading indicator

4. Firebase bağlantısını kontrol et:
   - Console'da oyun verisi varsa oluştur
   - Test kullanıcısıyla login dene

═══════════════════════════════════════════════════════════════════

🐛 ADIM 8: DEBUGGING & TROUBLESHOOTING
═══════════════════════════════════════════════════════════════════

Firebase bağlantı hatası:
├─ firebase_options.dart'da API key'leri kontrol et
├─ Firebase Console'da proje seçilmiş mi kontrol et
└─ google-services.json dosyasının yüklü olduğunu kontrol et

Gemini API hatası:
├─ API Key'in doğru girildiğini kontrol et
├─ API'nin aktif olduğunu kontrol et (Google Cloud Console)
└─ Request limitlerine ulaşmadığını kontrol et

WebView HTML yüklenmiyor:
├─ game_engine.html dosyasının assets/'de olduğunu kontrol et
├─ pubspec.yaml'da assets konfigürasyonunu kontrol et
└─ Flutter clean & rebuild yap: flutter clean && flutter pub get

═══════════════════════════════════════════════════════════════════

📱 ANDROID SETUP DETAYLARI
═══════════════════════════════════════════════════════════════════

android/app/build.gradle'da:

android {
    compileSdk 34  // Minimum API 31
    
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 34
    }
}

google-services.json konumu:
android/app/src/main/google-services.json

═══════════════════════════════════════════════════════════════════

🍎 iOS SETUP DETAYLARI
═══════════════════════════════════════════════════════════════════

GoogleService-Info.plist konumu:
ios/Runner/GoogleService-Info.plist

ios/Runner.xcodeproj/project.pbxproj'de:
- GoogleService-Info.plist'i Runner'a ekle
- Code Sign Settings'i kontrol et
- Deployment Target: iOS 12.0+

Pod install (gerekirse):
cd ios
rm -rf Pods
rm Podfile.lock
pod repo update
pod install
cd ..

═══════════════════════════════════════════════════════════════════

🔑 ENVIRONMENT VARIABLES (İsteğe bağlı - Production için)
═══════════════════════════════════════════════════════════════════

Sensitive bilgiler için:
1. .env dosyası oluştur (root'ta)
2. flutter_dotenv paketi ekle
3. main.dart'ta load et:

await dotenv.load();
const String geminiApiKey = dotenv.env['GEMINI_API_KEY']!;

═══════════════════════════════════════════════════════════════════

🎓 SONRAKI ADIMLAR
═══════════════════════════════════════════════════════════════════

✅ Kurulum tamamlandı!

Şimdi yapılacaklar:

1. Login & Signup sayfalarını UI'sini yazın
2. Home sayfasında oyunlar listesi gösterin
3. Create Game sayfası ekleyin (Gemini entegrasyonu)
4. Play Game sayfası (WebView) ekleyin
5. Rating & Comments sistemini ekleyin
6. Tests yazın
7. Production'a yayınlayın

═══════════════════════════════════════════════════════════════════

💡 TIPS & BEST PRACTICES
═══════════════════════════════════════════════════════════════════

✨ Firestore:
  - Document başına 1 MB limit
  - İç içe koleksiyonlar kullan (ölçeklenebilirlik)
  - Offline persistence etkinleştir

✨ Gemini API:
  - Rate limiting'i yönet
  - Response'ı cache'le
  - Fallback prompts hazırla

✨ WebView:
  - XSS güvenliği kontrol et
  - JavaScript sandbox'ını kullan
  - Memory leaks için dispose et

✨ UI/UX:
  - Dark mode desteği ekle
  - A11y (Accessibility) düşün
  - Responsive design kullan

═══════════════════════════════════════════════════════════════════

🆘 SUPPORT & RESOURCES
═══════════════════════════════════════════════════════════════════

📚 Resmi Dokümantasyon:
  - Flutter: https://flutter.dev/docs
  - Firebase: https://firebase.google.com/docs
  - Gemini: https://ai.google.dev/

🎥 Tutorials:
  - Flutter Official: https://www.youtube.com/@FlutterDev
  - Firebase: https://www.youtube.com/firebasefirebase
  - Gemini: https://www.youtube.com/@GoogleDevelopers

🐛 Problemi Çöz:
  - Stack Overflow: [google-cloud-firestore] tag'i
  - GitHub Issues: Flutter & Firebase repos

═══════════════════════════════════════════════════════════════════

Başarılar! 🚀✨

*/
