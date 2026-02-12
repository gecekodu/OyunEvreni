// 🏆 SCORE SERVICE - Skor Yönetimi

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/services/firebase_service.dart';
import '../../domain/entities/game_score.dart';

class ScoreService {
  final FirebaseService _firebaseService;

  ScoreService({required FirebaseService firebaseService})
      : _firebaseService = firebaseService;

  /// 🎯 Skoru kaydet
  Future<GameScore> saveScore({
    required String gameId,
    required String userId,
    required String userName,
    String userAvatar = '',
    required int score,
    required int correctAnswers,
    required int totalQuestions,
    int timeTaken = 0,
    Map<String, dynamic> metadata = const {},
  }) async {
    try {
      final scoreId = _firebaseService.firestore.collection('scores').doc().id;
      
      final gameScore = GameScore(
        id: scoreId,
        gameId: gameId,
        userId: userId,
        userName: userName,
        userAvatar: userAvatar,
        score: score,
        correctAnswers: correctAnswers,
        totalQuestions: totalQuestions,
        timeTaken: timeTaken,
        completedAt: DateTime.now(),
        metadata: metadata,
      );

      await _firebaseService.firestore
          .collection('scores')
          .doc(scoreId)
          .set(gameScore.toFirestore());

      print('✅ Skor kaydedildi: $scoreId (Puan: $score)');
      
      // Oyunun toplam oynama sayısını artır
      await _updateGameStats(gameId);
      
      return gameScore;
    } catch (e) {
      print('❌ Skor kaydetme hatası: $e');
      rethrow;
    }
  }

  /// 📊 Oyun istatistiklerini güncelle
  Future<void> _updateGameStats(String gameId) async {
    try {
      await _firebaseService.firestore
          .collection('games')
          .doc(gameId)
          .update({
        'playCount': FieldValue.increment(1),
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      print('⚠️ Oyun istatistik güncellenemedi: $e');
    }
  }

  /// 🏆 Leaderboard - Oyuna özel sıralama
  Future<List<GameScore>> getLeaderboard({
    required String gameId,
    int limit = 10,
  }) async {
    try {
      final snapshot = await _firebaseService.firestore
          .collection('scores')
          .where('gameId', isEqualTo: gameId)
          .orderBy('score', descending: true)
          .orderBy('completedAt', descending: false) // Aynı skor için hız
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => GameScore.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('❌ Leaderboard getirme hatası: $e');
      return [];
    }
  }

  /// 👤 Kullanıcının skorları
  Future<List<GameScore>> getUserScores({
    required String userId,
    int limit = 20,
  }) async {
    try {
      final snapshot = await _firebaseService.firestore
          .collection('scores')
          .where('userId', isEqualTo: userId)
          .orderBy('completedAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => GameScore.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('❌ Kullanıcı skorları getirme hatası: $e');
      return [];
    }
  }

  /// 🎮 Kullanıcının oyundaki en iyi skoru
  Future<GameScore?> getUserBestScore({
    required String gameId,
    required String userId,
  }) async {
    try {
      final snapshot = await _firebaseService.firestore
          .collection('scores')
          .where('gameId', isEqualTo: gameId)
          .where('userId', isEqualTo: userId)
          .orderBy('score', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return GameScore.fromFirestore(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      print('❌ En iyi skor getirme hatası: $e');
      return null;
    }
  }

  /// 📈 Küresel leaderboard (tüm oyunlar)
  Future<List<GameScore>> getGlobalLeaderboard({int limit = 50}) async {
    try {
      final snapshot = await _firebaseService.firestore
          .collection('scores')
          .orderBy('score', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => GameScore.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('❌ Global leaderboard hatası: $e');
      return [];
    }
  }

  /// 🏅 HTML oyunlardan Puan Ekle (Atomic Increment)
  /// Firebase Rules sayesinde eşzamanlı erişim güvenlidir
  Future<void> addScoreToUserProfile({
    required String userId,
    required String userName,
    required int score,
    String userAvatar = '',
  }) async {
    try {
      final userRef = _firebaseService.firestore
          .collection('users')
          .doc(userId);

      await userRef.set(
        {
          'totalScore': FieldValue.increment(score),
          'lastUpdated': FieldValue.serverTimestamp(),
          'username': userName,
          'userAvatar': userAvatar,
        },
        SetOptions(merge: true),
      );

      print('✅ Profil puanı güncellendi: +$score puan (Kullanıcı: $userName)');
    } catch (e) {
      print('❌ Profil puan ekleme hatası: $e');
      rethrow;
    }
  }

  /// 👤 Kullanıcının Toplam Puanı Getir
  Future<int> getUserTotalScore(String userId) async {
    try {
      final doc = await _firebaseService.firestore
          .collection('users')
          .doc(userId)
          .get();

      if (doc.exists) {
        return doc['totalScore'] ?? 0;
      }
      return 0;
    } catch (e) {
      print('❌ Toplam puan getirme hatası: $e');
      return 0;
    }
  }

  /// 🏆 Global Leaderboard (Toplam Puanlara Göre)
  Stream<List<Map<String, dynamic>>> getGlobalUserLeaderboard({int limit = 100}) {
    try {
      return _firebaseService.firestore
          .collection('users')
          .orderBy('totalScore', descending: true)
          .limit(limit)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => {
                      'uid': doc.id,
                      'username': doc['username'] ?? 'Kullanıcı',
                      'totalScore': doc['totalScore'] ?? 0,
                      'userAvatar': doc['userAvatar'] ?? '',
                      'lastUpdated': doc['lastUpdated'],
                    })
                .toList();
          });
    } catch (e) {
      print('❌ Global leaderboard stream hatası: $e');
      return Stream.value([]);
    }
  }
}
