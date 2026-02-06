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

// Firebase Authentication Exceptions
class FirebaseAuthException extends AppException {
  FirebaseAuthException({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}

// Firestore Exceptions
class FirestoreException extends AppException {
  FirestoreException({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}

// Gemini API Exceptions
class GeminiException extends AppException {
  GeminiException({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}

// Network Exceptions
class NetworkException extends AppException {
  NetworkException({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}

// Generic App Exceptions
class GenericException extends AppException {
  GenericException({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}
