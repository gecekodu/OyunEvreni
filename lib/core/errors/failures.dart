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
    required super.message,
    super.code,
  });
}

class FirestoreFailure extends Failure {
  FirestoreFailure({
    required super.message,
    super.code,
  });
}

class GeminiFailure extends Failure {
  GeminiFailure({
    required super.message,
    super.code,
  });
}

class NetworkFailure extends Failure {
  NetworkFailure({
    required super.message,
    super.code,
  });
}

class GenericFailure extends Failure {
  GenericFailure({
    required super.message,
    super.code,
  });
}
