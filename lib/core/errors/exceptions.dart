// 🚨 Uygulama-çapında Exception türleri

abstract class AppException implements Exception {
  final String message;
  final String? code;

  AppException({
    required this.message,
    this.code,
  });

  @override
  String toString() => message;
}

// Authentication Exceptions
class AuthException extends AppException {
  AuthException({
    required super.message,
    super.code,
  });
}

// Firestore Exceptions
class FirestoreException extends AppException {
  FirestoreException({
    required super.message,
    super.code,
  });
}

// Gemini API Exceptions
class GeminiException extends AppException {
  GeminiException({
    required super.message,
    super.code,
  });
}

// Network Exceptions
class NetworkException extends AppException {
  NetworkException({
    required super.message,
    super.code,
  });
}

// Generic App Exceptions
class GenericException extends AppException {
  GenericException({
    required super.message,
    super.code,
  });
}
