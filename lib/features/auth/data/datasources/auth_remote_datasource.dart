// 🔐 Firebase Auth Datasource (Remote)

import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../../../../core/services/firebase_service.dart';
import '../../../../core/errors/exceptions.dart';

class AuthRemoteDataSource {
  final FirebaseService _firebaseService;

  AuthRemoteDataSource({
    required FirebaseService firebaseService,
  }) : _firebaseService = firebaseService;

  // 📧 Email ile kaydol
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final userCredential = await _firebaseService.auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw AuthException(
          message: 'Kullanıcı oluşturulamadı',
          code: 'USER_CREATION_FAILED',
        );
      }

      // Update display name
      await firebaseUser.updateDisplayName(displayName);

      // Create user document in Firestore
      final userModel = UserModel(
        uid: firebaseUser.uid,
        email: firebaseUser.email!,
        displayName: displayName,
        photoUrl: firebaseUser.photoURL,
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
      );

      // Firestore'a yazarken totalScore ve username ekle
      final userData = userModel.toJson();
      userData['totalScore'] = 0; // 🏆 Başlangıç puanı
      userData['username'] = displayName; // 👤 Kullanıcı adı
      userData['userAvatar'] = ''; // Default avatar

      await _firebaseService.firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .set(userData);

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        message: _mapFirebaseError(e.code),
        code: e.code,
      );
    } catch (e) {
      throw AuthException(
        message: 'Kayıt sırasında hata: $e',
        code: 'SIGNUP_ERROR',
      );
    }
  }

  // 🔑 Email ile giriş
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseService.auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw AuthException(
          message: 'Giriş yapılamadı',
          code: 'SIGNIN_FAILED',
        );
      }

      // Get user from Firestore
      final userDoc = await _firebaseService.firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (!userDoc.exists) {
        throw AuthException(
          message: 'Kullanıcı profili bulunamadı',
          code: 'USER_NOT_FOUND',
        );
      }

      // Update lastLogin
      await _firebaseService.firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .update({'lastLogin': DateTime.now().toIso8601String()});

      return UserModel.fromFirestore(userDoc.data() as Map<String, dynamic>);
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        message: _mapFirebaseError(e.code),
        code: e.code,
      );
    } catch (e) {
      throw AuthException(
        message: 'Giriş sırasında hata: $e',
        code: 'SIGNIN_ERROR',
      );
    }
  }

  // 🚪 Çıkış
  Future<void> signOut() async {
    try {
      await _firebaseService.auth.signOut();
    } catch (e) {
      throw AuthException(
        message: 'Çıkış sırasında hata: $e',
        code: 'SIGNOUT_ERROR',
      );
    }
  }

  // 👤 Mevcut kullanıcıyı getir
  Future<UserModel?> getCurrentUser() async {
    try {
      final firebaseUser = _firebaseService.auth.currentUser;
      if (firebaseUser == null) return null;

      final userDoc = await _firebaseService.firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (!userDoc.exists) return null;

      return UserModel.fromFirestore(userDoc.data() as Map<String, dynamic>);
    } catch (e) {
      throw AuthException(
        message: 'Kullanıcı bilgisi alınamadı: $e',
        code: 'GET_USER_ERROR',
      );
    }
  }

  // 🔄 Şifre sıfırla
  Future<void> resetPassword({required String email}) async {
    try {
      await _firebaseService.auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        message: _mapFirebaseError(e.code),
        code: e.code,
      );
    } catch (e) {
      throw AuthException(
        message: 'Şifre sıfırlama sırasında hata: $e',
        code: 'RESET_PASSWORD_ERROR',
      );
    }
  }

  // 🗺️ Firebase error codes'u TR mesajlara çevir
  String _mapFirebaseError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Bu e-posta zaten kayıtlı';
      case 'weak-password':
        return 'Şifre çok zayıf (min. 6 karakter)';
      case 'invalid-email':
        return 'Geçersiz e-posta adresi';
      case 'user-not-found':
        return 'Kullanıcı bulunamadı';
      case 'wrong-password':
        return 'Hatalı şifre';
      case 'user-disabled':
        return 'Bu hesap devre dışı bırakılmış';
      case 'too-many-requests':
        return 'Çok fazla deneme. Daha sonra tekrar deneyin';
      default:
        return 'Bilinmeyen hata: $code';
    }
  }
}
