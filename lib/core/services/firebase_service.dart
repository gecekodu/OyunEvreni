// 🔥 Firebase Initialization Service

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  /// Email ve şifre ile giriş yap
  Future<User?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(
        message: _getAuthErrorMessage(e.code),
        code: e.code,
      );
    } catch (e) {
      throw FirebaseAuthException(
        message: 'Giriş başarısız: $e',
        code: 'SIGN_IN_ERROR',
      );
    }
  }

  /// Email ve şifre ile kayıt ol
  Future<User?> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(
        message: _getAuthErrorMessage(e.code),
        code: e.code,
      );
    } catch (e) {
      throw FirebaseAuthException(
        message: 'Kayıt başarısız: $e',
        code: 'SIGN_UP_ERROR',
      );
    }
  }

  /// Kullanıcı adını güncelle
  Future<void> updateDisplayName(String displayName) async {
    try {
      await _auth.currentUser?.updateDisplayName(displayName);
      await _auth.currentUser?.reload();
    } catch (e) {
      throw FirebaseAuthException(
        message: 'Kullanıcı adı güncellenemedi: $e',
        code: 'UPDATE_NAME_ERROR',
      );
    }
  }

  /// Çıkış yap
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw FirebaseAuthException(
        message: 'Çıkış yapılamadı: $e',
        code: 'SIGN_OUT_ERROR',
      );
    }
  }

  /// Firebase Auth hata mesajlarını Türkçe'ye çevir
  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Bu e-posta adresiyle kayıtlı kullanıcı bulunamadı';
      case 'wrong-password':
        return 'Şifre hatalı';
      case 'email-already-in-use':
        return 'Bu e-posta adresi zaten kullanımda';
      case 'invalid-email':
        return 'Geçersiz e-posta adresi';
      case 'weak-password':
        return 'Şifre çok zayıf (en az 6 karakter olmalı)';
      case 'user-disabled':
        return 'Bu kullanıcı hesabı devre dışı bırakılmış';
      case 'too-many-requests':
        return 'Çok fazla deneme. Lütfen daha sonra tekrar deneyin';
      case 'network-request-failed':
        return 'İnternet bağlantısı hatası';
      default:
        return 'Bir hata oluştu: $code';
    }
  }
}
