// 🔥 Firebase Initialization Service

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../errors/exceptions.dart';
import '../../config/firebase_options.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();

  factory FirebaseService() {
    return _instance;
  }

  FirebaseService._internal();

  // Lazy initialization
  late FirebaseAuth _auth;
  late FirebaseFirestore _firestore;

  FirebaseAuth get auth => _auth;
  FirebaseFirestore get firestore => _firestore;

  /// Firebase'i başlat
  /// 🚀 App startup'ında çağrılmalı
  Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      _auth = FirebaseAuth.instance;
      _firestore = FirebaseFirestore.instance;

      // Firestore settings
      _firestore.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );

      print('✅ Firebase başarıyla başlatıldı');
    } catch (e) {
      throw FirebaseAuthException(
        message: 'Firebase başlatılamadı: $e',
        code: 'FIREBASE_INIT_ERROR',
      );
    }
  }

  /// Mevcut kullanıcı
  User? get currentUser => _auth.currentUser;

  /// Kullanıcı kimliği doğrulanmış mı?
  bool get isAuthenticated => _auth.currentUser != null;

  /// Kullanıcı UID
  String? get userId => _auth.currentUser?.uid;
}
