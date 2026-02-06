// 📦 Auth Repository Interface (Domain Layer)

import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  });

  Future<User> signInWithEmail({
    required String email,
    required String password,
  });

  Future<void> signOut();

  Future<User?> getCurrentUser();

  Future<void> resetPassword({required String email});

  bool get isAuthenticated;

  String? get userId;
}
