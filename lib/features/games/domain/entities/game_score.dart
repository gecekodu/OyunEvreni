// 🏆 GAME SCORE MODEL - Oyun Skorları

import 'package:cloud_firestore/cloud_firestore.dart';

class GameScore {
  final String id;
  final String gameId;
  final String userId;
  final String userName;
  final String userAvatar;
  final int score;
  final int correctAnswers;
  final int totalQuestions;
  final int timeTaken; // saniye
  final DateTime completedAt;
  final Map<String, dynamic> metadata;

  GameScore({
    required this.id,
    required this.gameId,
    required this.userId,
    required this.userName,
    this.userAvatar = '',
    required this.score,
    required this.correctAnswers,
    required this.totalQuestions,
    this.timeTaken = 0,
    required this.completedAt,
    this.metadata = const {},
  });

  // Firestore'dan oku
  factory GameScore.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GameScore(
      id: doc.id,
      gameId: data['gameId'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Anonim',
      userAvatar: data['userAvatar'] ?? '',
      score: data['score'] ?? 0,
      correctAnswers: data['correctAnswers'] ?? 0,
      totalQuestions: data['totalQuestions'] ?? 0,
      timeTaken: data['timeTaken'] ?? 0,
      completedAt: (data['completedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      metadata: data['metadata'] ?? {},
    );
  }

  // Firestore'a yaz
  Map<String, dynamic> toFirestore() {
    return {
      'gameId': gameId,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'score': score,
      'correctAnswers': correctAnswers,
      'totalQuestions': totalQuestions,
      'timeTaken': timeTaken,
      'completedAt': Timestamp.fromDate(completedAt),
      'metadata': metadata,
    };
  }

  // Başarı yüzdesi
  double get successRate => totalQuestions > 0 
      ? (correctAnswers / totalQuestions) * 100 
      : 0;

  // Yıldız puanı (1-5)
  int get starRating {
    if (successRate >= 90) return 5;
    if (successRate >= 75) return 4;
    if (successRate >= 60) return 3;
    if (successRate >= 40) return 2;
    return 1;
  }
}
