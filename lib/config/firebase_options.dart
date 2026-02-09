// 🔥 Firebase Konfigürasyonu
// ⚠️ ZORUNLU: Bu dosyayı Firebase Console'dan oluşturduğun google-services.json 
// ve GoogleService-Info.plist ile güncelle!

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return android;
  }

  // 🤖 Gemini API Key
  static const String geminiApiKey = 'AIzaSyBFjZqUjXIbyLI-h4ieboHkJQM6qRvt3Qw';

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDduUTk0dJZgVNeyg8AV66qiIChgmoAC3s',
    appId: '1:319430039491:web:9f3c8f0a7b6c5d4e3f2a',
    messagingSenderId: '319430039491',
    projectId: 'oyunevreni-48a7a',
    authDomain: 'oyunevreni-48a7a.firebaseapp.com',
    storageBucket: 'oyunevreni-48a7a.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB6KhuzV-Pf_j4iGaIxj7cb1IloNWb-V38',
    appId: '1:319430039491:android:c35ddeec8d8f86e1188f76',
    messagingSenderId: '319430039491',
    projectId: 'oyunevreni-48a7a',
    storageBucket: 'oyunevreni-48a7a.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDjMzP5Entcf410O9phLwXzVRsL81wnocA',
    appId: '1:319430039491:ios:3a3ef0c0a3aebe16188f76',
    messagingSenderId: '319430039491',
    projectId: 'oyunevreni-48a7a',
    storageBucket: 'oyunevreni-48a7a.firebasestorage.app',
    iosBundleId: 'com.example.oyunOlustur',
  );
}
