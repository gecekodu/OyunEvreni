// 🎮 Game Model (Data Layer)

import '../../domain/entities/game.dart';

class GameModel extends Game {
  const GameModel({
    required String gameId,
    required String creatorUserId,
    required String creatorName,
    required String lesson,
    required String topic,
    required String grade,
    required String difficulty,
    required String title,
    required String description,
    required Map<String, dynamic> jsonDefinition,
    double rating = 0.0,
    int playCount = 0,
    int ratingCount = 0,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) : super(
    gameId: gameId,
    creatorUserId: creatorUserId,
    creatorName: creatorName,
    lesson: lesson,
    topic: topic,
    grade: grade,
    difficulty: difficulty,
    title: title,
    description: description,
    jsonDefinition: jsonDefinition,
    rating: rating,
    playCount: playCount,
    ratingCount: ratingCount,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  // JSON'dan Model'e
  factory GameModel.fromJson(Map<String, dynamic> json) {
    return GameModel(
      gameId: json['gameId'] as String,
      creatorUserId: json['creatorUserId'] as String,
      creatorName: json['creatorName'] as String,
      lesson: json['lesson'] as String,
      topic: json['topic'] as String,
      grade: json['grade'] as String,
      difficulty: json['difficulty'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      jsonDefinition: json['jsonDefinition'] as Map<String, dynamic>,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      playCount: json['playCount'] as int? ?? 0,
      ratingCount: json['ratingCount'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  // Model'den JSON'a
  Map<String, dynamic> toJson() {
    return {
      'gameId': gameId,
      'creatorUserId': creatorUserId,
      'creatorName': creatorName,
      'lesson': lesson,
      'topic': topic,
      'grade': grade,
      'difficulty': difficulty,
      'title': title,
      'description': description,
      'jsonDefinition': jsonDefinition,
      'rating': rating,
      'playCount': playCount,
      'ratingCount': ratingCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Firestore document'ten
  factory GameModel.fromFirestore(Map<String, dynamic> doc) {
    return GameModel.fromJson(doc);
  }
}
