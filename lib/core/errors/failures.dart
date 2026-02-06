// 📊 Uygulama-çapında Failure yapısı (Either pattern)

abstract class Failure {
  final String message;
  final String? code;

  Failure({
    required this.message,
    this.code,
  });
}

class FirebaseAuthFailure extends Failure {
  FirebaseAuthFailure({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}

class FirestoreFailure extends Failure {
  FirestoreFailure({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}

class GeminiFailure extends Failure {
  GeminiFailure({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}

class NetworkFailure extends Failure {
  NetworkFailure({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}

class GenericFailure extends Failure {
  GenericFailure({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}
