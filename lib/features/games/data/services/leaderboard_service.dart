// 🏆 LEADERBOARD SERVICE
// Oyun bazlı ve global leaderboard yönetimi

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/game_score.dart';

class LeaderboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 📊 Tüm oyunlardaki global leaderboard (tüm kullanıcıları sırala)
  Future<List<Map<String, dynamic>>> getGlobalLeaderboard({int limit = 50}) async {
    try {
      final snapshot = await _firestore
          .collection('game_scores')
          .orderBy('score', descending: true)
          .limit(limit)
          .get();

      // Kullanıcı bazında max puan
      final userMaxScores = <String, Map<String, dynamic>>{};
      
      for (var doc in snapshot.docs) {
        final score = GameScore.fromFirestore(doc);
        if (!userMaxScores.containsKey(score.userId) || 
            userMaxScores[score.userId]!['score'] < score.score) {
          userMaxScores[score.userId] = {
            'userId': score.userId,
            'userName': score.userName,
            'userAvatar': score.userAvatar,
            'score': score.score,
          };
        }
      }

      // Puanlarına göre sırala
      final ranked = userMaxScores.values.toList();
      ranked.sort((a, b) => b['score'].compareTo(a['score']));
      
      return ranked;
    } catch (e) {
      print('Global leaderboard hatası: $e');
      return [];
    }
  }

  /// 🎮 Oyun bazlı leaderboard (aynı oyunu oynayanları sırala)
  Future<List<Map<String, dynamic>>> getGameLeaderboard(String gameId, {int limit = 50}) async {
    try {
      final snapshot = await _firestore
          .collection('game_scores')
          .where('gameId', isEqualTo: gameId)
          .orderBy('score', descending: true)
          .limit(limit * 2) // Daha fazla al, sonra kullanıcı bazında filtrele
          .get();

      // Kullanıcı başına max puan
      final userMaxScores = <String, Map<String, dynamic>>{};
      
      for (var doc in snapshot.docs) {
        final score = GameScore.fromFirestore(doc);
        if (!userMaxScores.containsKey(score.userId) || 
            userMaxScores[score.userId]!['score'] < score.score) {
          userMaxScores[score.userId] = {
            'userId': score.userId,
            'userName': score.userName,
            'userAvatar': score.userAvatar,
            'score': score.score,
            'gameId': gameId,
            'completedAt': score.completedAt,
          };
        }
      }

      final ranked = userMaxScores.values.toList();
      ranked.sort((a, b) => b['score'].compareTo(a['score']));
      
      return ranked.take(limit).toList();
    } catch (e) {
      print('Oyun leaderboard hatası ($gameId): $e');
      return [];
    }
  }

  /// 👤 Kullanıcının tüm oyunlardaki toplam puanı
  Future<double> getUserTotalScore(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('game_scores')
          .where('userId', isEqualTo: userId)
          .get();

      double totalScore = 0;
      final userBestScores = <String, int>{};

      for (var doc in snapshot.docs) {
        final score = GameScore.fromFirestore(doc);
        if (!userBestScores.containsKey(score.gameId) || 
            userBestScores[score.gameId]! < score.score) {
          userBestScores[score.gameId] = score.score;
        }
      }

      totalScore = userBestScores.values.fold(0, (sum, val) => sum + val).toDouble();
      return totalScore;
    } catch (e) {
      print('Kullanıcı toplam puan hatası: $e');
      return 0;
    }
  }

  /// 🎯 Kullanıcının bir oyundaki en yüksek puanı
  Future<int> getUserGameHighScore(String userId, String gameId) async {
    try {
      final snapshot = await _firestore
          .collection('game_scores')
          .where('userId', isEqualTo: userId)
          .where('gameId', isEqualTo: gameId)
          .orderBy('score', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return 0;
      
      final score = GameScore.fromFirestore(snapshot.docs.first);
      return score.score;
    } catch (e) {
      print('Oyun yüksek puanı hatası: $e');
      return 0;
    }
  }

  /// 💾 Oyun skorunu Firestore'a kaydet
  Future<void> saveGameScore({
    required String gameId,
    required String userId,
    required String userName,
    required int score,
    required String userAvatar,
  }) async {
    try {
      await _firestore.collection('game_scores').add({
        'gameId': gameId,
        'userId': userId,
        'userName': userName,
        'userAvatar': userAvatar,
        'score': score,
        'completedAt': Timestamp.now(),
        'metadata': {
          'savedAt': Timestamp.now(),
        },
      });

      // Kullanıcı istatistiklerini güncelle
      await _updateUserStats(userId);
    } catch (e) {
      print('Skor kayıt hatası: $e');
    }
  }

  /// 👥 Kullanıcı istatistiklerini güncelle
  Future<void> _updateUserStats(String userId) async {
    try {
      final totalScore = await getUserTotalScore(userId);
      
      await _firestore.collection('users').doc(userId).update({
        'totalScore': totalScore,
        'lastGameTime': Timestamp.now(),
      });
    } catch (e) {
      print('İstatistik güncellenemedi: $e');
    }
  }

  /// 🏅 Kullanıcının global sıraması
  Future<int> getUserGlobalRank(String userId) async {
    try {
      final leaderboard = await getGlobalLeaderboard(limit: 10000);
      final rank = leaderboard.indexWhere((u) => u['userId'] == userId) + 1;
      return rank > 0 ? rank : -1; // -1 = Sıralamada yok
    } catch (e) {
      print('Global sıra hatası: $e');
      return -1;
    }
  }

  /// 💎 Elmas sıralaması (kullanıcılar koleksiyonu)
  Future<List<Map<String, dynamic>>> getDiamondsLeaderboard({int limit = 50}) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .orderBy('diamonds', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'userId': doc.id,
          'userName': data['displayName'] ?? data['userName'] ?? 'Anonim',
          'userAvatar': data['photoURL'] ?? '',
          'avatarEmoji': data['avatarEmoji'] ?? '',
          'diamonds': data['diamonds'] ?? 0,
        };
      }).toList();
    } catch (e) {
      print('Elmas leaderboard hatasi: $e');
      return [];
    }
  }

  /// 🏆 Kupa sıralaması (kullanıcılar koleksiyonu)
  Future<List<Map<String, dynamic>>> getTrophiesLeaderboard({int limit = 50}) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .orderBy('trophies', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'userId': doc.id,
          'userName': data['displayName'] ?? data['userName'] ?? 'Anonim',
          'userAvatar': data['photoURL'] ?? '',
          'avatarEmoji': data['avatarEmoji'] ?? '',
          'trophies': data['trophies'] ?? 0,
        };
      }).toList();
    } catch (e) {
      print('Kupa leaderboard hatasi: $e');
      return [];
    }
  }

  /// 🎮 Kullanıcının oyun bazlı sıraması
  Future<int> getUserGameRank(String userId, String gameId) async {
    try {
      final leaderboard = await getGameLeaderboard(gameId, limit: 10000);
      final rank = leaderboard.indexWhere((u) => u['userId'] == userId) + 1;
      return rank > 0 ? rank : -1;
    } catch (e) {
      print('Oyun sıra hatası: $e');
      return -1;
    }
  }

  /// 📈 Bu ay çıkmazları (trending games)
  Future<List<Map<String, dynamic>>> getTrendingThisMonth() async {
    try {
      final thirtyDaysAgo = DateTime.now().subtract(Duration(days: 30));
      
      final snapshot = await _firestore
          .collection('game_scores')
          .where('completedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(thirtyDaysAgo))
          .get();

      final gameStats = <String, Map<String, dynamic>>{};
      
      for (var doc in snapshot.docs) {
        final score = GameScore.fromFirestore(doc);
        if (!gameStats.containsKey(score.gameId)) {
          gameStats[score.gameId] = {
            'gameId': score.gameId,
            'playCount': 0,
            'totalScore': 0,
            'avgScore': 0.0,
          };
        }
        gameStats[score.gameId]!['playCount']++;
        gameStats[score.gameId]!['totalScore'] += score.score;
      }

      // Ortalamaları hesapla
      for (var stats in gameStats.values) {
        stats['avgScore'] = stats['totalScore'] / stats['playCount'];
      }

      final trending = gameStats.values.toList();
      trending.sort((a, b) => b['playCount'].compareTo(a['playCount']));
      
      return trending.take(10).toList();
    } catch (e) {
      print('Trending hatası: $e');
      return [];
    }
  }
}
