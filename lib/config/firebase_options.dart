// 🔥 Firebase Konfigürasyonu
// ⚠️ ZORUNLU: Bu dosyayı Firebase Console'dan oluşturduğun google-services.json 
// ve GoogleService-Info.plist ile güncelle!

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return web;
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR_WEB_API_KEY', // Firebase Console'dan kopyala
    appId: 'YOUR_APP_ID', // Firebase Console'dan kopyala
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID', // Firebase Console'dan kopyala
    projectId: 'oyun-olustur-ai', // Firebase Console'dan kopyala
    authDomain: 'oyun-olustur-ai.firebaseapp.com', // Firebase Console'dan kopyala
    storageBucket: 'oyun-olustur-ai.appspot.com', // Firebase Console'dan kopyala
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_ANDROID_API_KEY', // google-services.json'dan
    appId: 'YOUR_APP_ID', // google-services.json'dan
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID', // google-services.json'dan
    projectId: 'oyun-olustur-ai', // google-services.json'dan
    storageBucket: 'oyun-olustur-ai.appspot.com', // google-services.json'dan
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY', // GoogleService-Info.plist'ten
    appId: 'YOUR_APP_ID', // GoogleService-Info.plist'ten
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID', // GoogleService-Info.plist'ten
    projectId: 'oyun-olustur-ai', // GoogleService-Info.plist'ten
    storageBucket: 'oyun-olustur-ai.appspot.com', // GoogleService-Info.plist'ten
    iosBundleId: 'com.oyunolustur.app', // GoogleService-Info.plist'ten
  );
}
