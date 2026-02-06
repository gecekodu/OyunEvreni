// 🎮 Game Entity (Domain Layer)

class Game {
  final String gameId;
  final String creatorUserId;
  final String creatorName;
  final String lesson; // Ders: Matematik, Fen, Türkçe vb.
  final String topic;  // Konu: Işığın yansıması vb.
  final String grade;  // Sınıf: 5. Sınıf vb.
  final String difficulty; // easy, medium, hard
  final String title;
  final String description;
  final Map<String, dynamic> jsonDefinition; // Oyun tanımı JSON
  final double rating; // 0-5
  final int playCount;
  final int ratingCount;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Game({
    required this.gameId,
    required this.creatorUserId,
    required this.creatorName,
    required this.lesson,
    required this.topic,
    required this.grade,
    required this.difficulty,
    required this.title,
    required this.description,
    required this.jsonDefinition,
    this.rating = 0.0,
    this.playCount = 0,
    this.ratingCount = 0,
    required this.createdAt,
    this.updatedAt,
  });

  Game copyWith({
    String? gameId,
    String? creatorUserId,
    String? creatorName,
    String? lesson,
    String? topic,
    String? grade,
    String? difficulty,
    String? title,
    String? description,
    Map<String, dynamic>? jsonDefinition,
    double? rating,
    int? playCount,
    int? ratingCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Game(
      gameId: gameId ?? this.gameId,
      creatorUserId: creatorUserId ?? this.creatorUserId,
      creatorName: creatorName ?? this.creatorName,
      lesson: lesson ?? this.lesson,
      topic: topic ?? this.topic,
      grade: grade ?? this.grade,
      difficulty: difficulty ?? this.difficulty,
      title: title ?? this.title,
      description: description ?? this.description,
      jsonDefinition: jsonDefinition ?? this.jsonDefinition,
      rating: rating ?? this.rating,
      playCount: playCount ?? this.playCount,
      ratingCount: ratingCount ?? this.ratingCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'Game(gameId: $gameId, title: $title)';
}
