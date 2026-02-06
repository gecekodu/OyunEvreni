// 🔧 Auth Repository Implementation (Data Layer)

import '../datasources/auth_remote_datasource.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/services/firebase_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final FirebaseService _firebaseService;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required FirebaseService firebaseService,
  })  : _remoteDataSource = remoteDataSource,
        _firebaseService = firebaseService;

  @override
  Future<User> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    return await _remoteDataSource.signUpWithEmail(
      email: email,
      password: password,
      displayName: displayName,
    );
  }

  @override
  Future<User> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _remoteDataSource.signInWithEmail(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> signOut() async {
    return await _remoteDataSource.signOut();
  }

  @override
  Future<User?> getCurrentUser() async {
    return await _remoteDataSource.getCurrentUser();
  }

  @override
  Future<void> resetPassword({required String email}) async {
    return await _remoteDataSource.resetPassword(email: email);
  }

  @override
  bool get isAuthenticated => _firebaseService.isAuthenticated;

  @override
  String? get userId => _firebaseService.userId;
}
