// 🎮 OYUN MODELİ - Firestore için

import 'package:cloud_firestore/cloud_firestore.dart';

class Game {
  final String id;
  final String title;
  final String description;
  final String creatorId;
  final String creatorName;
  final String gameType; // math, word, puzzle, color, memory
  final String difficulty; // easy, medium, hard
  final List<String> learningGoals;
  final String htmlContent; // Oyunun HTML kodu
  final String thumbnailUrl;
  final int playCount;
  final double averageRating;
  final int ratingCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPublished;
  final Map<String, dynamic>? metadata; // Ekstra bilgiler

  Game({
    required this.id,
    required this.title,
    required this.description,
    required this.creatorId,
    required this.creatorName,
    required this.gameType,
    required this.difficulty,
    required this.learningGoals,
    required this.htmlContent,
    this.thumbnailUrl = '',
    this.playCount = 0,
    this.averageRating = 0.0,
    this.ratingCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.isPublished = true,
    this.metadata,
  });

  // Firestore'dan oku
  factory Game.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Game(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      creatorId: data['creatorId'] ?? '',
      creatorName: data['creatorName'] ?? '',
      gameType: data['gameType'] ?? '',
      difficulty: data['difficulty'] ?? '',
      learningGoals: List<String>.from(data['learningGoals'] ?? []),
      htmlContent: data['htmlContent'] ?? '',
      thumbnailUrl: data['thumbnailUrl'] ?? '',
      playCount: data['playCount'] ?? 0,
      averageRating: (data['averageRating'] ?? 0.0).toDouble(),
      ratingCount: data['ratingCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      isPublished: data['isPublished'] ?? true,
      metadata: data['metadata'],
    );
  }

  // Firestore'a yaz
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'creatorId': creatorId,
      'creatorName': creatorName,
      'gameType': gameType,
      'difficulty': difficulty,
      'learningGoals': learningGoals,
      'htmlContent': htmlContent,
      'thumbnailUrl': thumbnailUrl,
      'playCount': playCount,
      'averageRating': averageRating,
      'ratingCount': ratingCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isPublished': isPublished,
      'metadata': metadata,
    };
  }

  // Kopyalama
  Game copyWith({
    String? title,
    String? description,
    String? gameType,
    String? difficulty,
    List<String>? learningGoals,
    String? htmlContent,
    String? thumbnailUrl,
    int? playCount,
    double? averageRating,
    int? ratingCount,
    DateTime? updatedAt,
    bool? isPublished,
    Map<String, dynamic>? metadata,
  }) {
    return Game(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      creatorId: creatorId,
      creatorName: creatorName,
      gameType: gameType ?? this.gameType,
      difficulty: difficulty ?? this.difficulty,
      learningGoals: learningGoals ?? this.learningGoals,
      htmlContent: htmlContent ?? this.htmlContent,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      playCount: playCount ?? this.playCount,
      averageRating: averageRating ?? this.averageRating,
      ratingCount: ratingCount ?? this.ratingCount,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPublished: isPublished ?? this.isPublished,
      metadata: metadata ?? this.metadata,
    );
  }
}

// 💬 YORUM MODELİ
class GameComment {
  final String id;
  final String gameId;
  final String userId;
  final String userName;
  final String userAvatar;
  final String comment;
  final DateTime createdAt;

  GameComment({
    required this.id,
    required this.gameId,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.comment,
    required this.createdAt,
  });

  factory GameComment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GameComment(
      id: doc.id,
      gameId: data['gameId'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userAvatar: data['userAvatar'] ?? '',
      comment: data['comment'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'gameId': gameId,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

// ⭐ OYUN PUANLAMA MODELİ
class GameRating {
  final String id;
  final String gameId;
  final String userId;
  final int rating; // 1-5
  final DateTime createdAt;

  GameRating({
    required this.id,
    required this.gameId,
    required this.userId,
    required this.rating,
    required this.createdAt,
  });

  factory GameRating.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GameRating(
      id: doc.id,
      gameId: data['gameId'] ?? '',
      userId: data['userId'] ?? '',
      rating: data['rating'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'gameId': gameId,
      'userId': userId,
      'rating': rating,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

// 📊 OYUN İSTATİSTİKLERİ (Her kullanıcının oyundaki performansı)
class GameScore {
  final String id;
  final String gameId;
  final String userId;
  final String userName;
  final int score;
  final int correctAnswers;
  final int totalQuestions;
  final int timeSpent; // saniye
  final DateTime playedAt;

  GameScore({
    required this.id,
    required this.gameId,
    required this.userId,
    required this.userName,
    required this.score,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.timeSpent,
    required this.playedAt,
  });

  factory GameScore.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GameScore(
      id: doc.id,
      gameId: data['gameId'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      score: data['score'] ?? 0,
      correctAnswers: data['correctAnswers'] ?? 0,
      totalQuestions: data['totalQuestions'] ?? 0,
      timeSpent: data['timeSpent'] ?? 0,
      playedAt: (data['playedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'gameId': gameId,
      'userId': userId,
      'userName': userName,
      'score': score,
      'correctAnswers': correctAnswers,
      'totalQuestions': totalQuestions,
      'timeSpent': timeSpent,
      'playedAt': Timestamp.fromDate(playedAt),
    };
  }

  // Başarı yüzdesi
  double get successRate =>
      totalQuestions > 0 ? (correctAnswers / totalQuestions) * 100 : 0;
}

// 🏆 KULLANICI ROZET MODELİ
class UserBadge {
  final String id;
  final String userId;
  final String badgeType; // first_game, game_creator, popular_creator, etc.
  final String title;
  final String description;
  final String icon;
  final DateTime earnedAt;

  UserBadge({
    required this.id,
    required this.userId,
    required this.badgeType,
    required this.title,
    required this.description,
    required this.icon,
    required this.earnedAt,
  });

  factory UserBadge.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserBadge(
      id: doc.id,
      userId: data['userId'] ?? '',
      badgeType: data['badgeType'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      icon: data['icon'] ?? '',
      earnedAt: (data['earnedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'badgeType': badgeType,
      'title': title,
      'description': description,
      'icon': icon,
      'earnedAt': Timestamp.fromDate(earnedAt),
    };
  }
}

// 👤 KULLANICI PROFİLİ EK BİLGİLERİ
class UserProfile {
  final String userId;
  final int totalGamesCreated;
  final int totalGamesPlayed;
  final int totalScore;
  final int level;
  final List<String> badges;
  final DateTime lastActive;

  UserProfile({
    required this.userId,
    this.totalGamesCreated = 0,
    this.totalGamesPlayed = 0,
    this.totalScore = 0,
    this.level = 1,
    this.badges = const [],
    required this.lastActive,
  });

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      userId: doc.id,
      totalGamesCreated: data['totalGamesCreated'] ?? 0,
      totalGamesPlayed: data['totalGamesPlayed'] ?? 0,
      totalScore: data['totalScore'] ?? 0,
      level: data['level'] ?? 1,
      badges: List<String>.from(data['badges'] ?? []),
      lastActive: (data['lastActive'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'totalGamesCreated': totalGamesCreated,
      'totalGamesPlayed': totalGamesPlayed,
      'totalScore': totalScore,
      'level': level,
      'badges': badges,
      'lastActive': Timestamp.fromDate(lastActive),
    };
  }

  // Seviye hesaplama (her 1000 puan = 1 seviye)
  static int calculateLevel(int totalScore) {
    return (totalScore / 1000).floor() + 1;
  }
}
