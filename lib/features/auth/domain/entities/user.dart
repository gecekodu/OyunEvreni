// 👤 User Entity (Domain Layer)

class User {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime? lastLogin;
  final int totalGamesCreated;
  final int totalGamesPlayed;
  final double averageRating;

  const User({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.createdAt,
    this.lastLogin,
    this.totalGamesCreated = 0,
    this.totalGamesPlayed = 0,
    this.averageRating = 0.0,
  });

  // CopyWith method
  User copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? lastLogin,
    int? totalGamesCreated,
    int? totalGamesPlayed,
    double? averageRating,
  }) {
    return User(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      totalGamesCreated: totalGamesCreated ?? this.totalGamesCreated,
      totalGamesPlayed: totalGamesPlayed ?? this.totalGamesPlayed,
      averageRating: averageRating ?? this.averageRating,
    );
  }

  @override
  String toString() => 'User(uid: $uid, email: $email, displayName: $displayName)';
}
