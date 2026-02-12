// 🎮 Game Model (Data Layer)

import '../../domain/entities/game.dart';

class GameModel extends Game {
  const GameModel({
    required super.gameId,
    required super.creatorUserId,
    required super.creatorName,
    required super.lesson,
    required super.topic,
    required super.grade,
    required super.difficulty,
    required super.title,
    required super.description,
    required super.jsonDefinition,
    super.rating,
    super.playCount,
    super.ratingCount,
    required super.createdAt,
    super.updatedAt,
  });

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
