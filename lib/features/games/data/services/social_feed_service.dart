// 📱 SOSYAL AKIŞ - Feed Servisi

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/game_models.dart';

class SocialFeedService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 📊 Günün oyunlarını getir
  Future<List<Game>> getTodaysGames() async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

      final snapshot = await _firestore
          .collection('games')
          .where('isPublished', isEqualTo: true)
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .orderBy('createdAt', descending: true)
          .limit(10)
          .get();

      return snapshot.docs
          .map((doc) => Game.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Hata - Günün oyunları getirilemedi: $e');
      return [];
    }
  }

  /// 🌟 En beğenilen oyunları getir (son 7 gün)
  Future<List<Game>> getMostLovedGames() async {
    try {
      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));

      final snapshot = await _firestore
          .collection('games')
          .where('isPublished', isEqualTo: true)
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(sevenDaysAgo))
          .orderBy('createdAt', descending: true)
          .orderBy('averageRating', descending: true)
          .orderBy('ratingCount', descending: true)
          .limit(10)
          .get();

      return snapshot.docs
          .map((doc) => Game.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Hata - En beğenilen oyunlar getirilemedi: $e');
      return [];
    }
  }

  /// 🔥 Trend oyunlar (En çok oynananlar)
  Future<List<Game>> getTrendingGames() async {
    try {
      final snapshot = await _firestore
          .collection('games')
          .where('isPublished', isEqualTo: true)
          .orderBy('playCount', descending: true)
          .limit(10)
          .get();

      return snapshot.docs
          .map((doc) => Game.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Hata - Trend oyunlar getirilemedi: $e');
      return [];
    }
  }

  /// 👑 Editörün seçimleri (Manuel olarak Firestore'da işaretlenmiş)
  Future<List<Game>> getEditorsChoice() async {
    try {
      final snapshot = await _firestore
          .collection('games')
          .where('isPublished', isEqualTo: true)
          .where('metadata.isEditorsChoice', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(10)
          .get();

      return snapshot.docs
          .map((doc) => Game.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Hata - Editörün seçimleri getirilemedi: $e');
      return [];
    }
  }

  /// 💬 Oyunun yorumlarını getir
  Future<List<GameComment>> getGameComments(String gameId, {int limit = 5}) async {
    try {
      final snapshot = await _firestore
          .collection('game_comments')
          .where('gameId', isEqualTo: gameId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => GameComment.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Hata - Yorumlar getirilemedi: $e');
      return [];
    }
  }

  /// ⭐ Oyunun puanlamasını getir
  Future<double> getGameAverageRating(String gameId) async {
    try {
      final snapshot = await _firestore
          .collection('game_ratings')
          .where('gameId', isEqualTo: gameId)
          .get();

      if (snapshot.docs.isEmpty) return 0.0;

      final average = snapshot.docs
          .map((doc) => doc['rating'] as int)
          .reduce((a, b) => a + b) /
          snapshot.docs.length;

      return average;
    } catch (e) {
      print('Hata - Puan getirilemedi: $e');
      return 0.0;
    }
  }

  /// 📈 Oyunun sıralamalarını getir (en yüksek skor)
  Future<List<GameScore>> getGameLeaderboard(String gameId, {int limit = 10}) async {
    try {
      final snapshot = await _firestore
          .collection('game_scores')
          .where('gameId', isEqualTo: gameId)
          .orderBy('score', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => GameScore.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Hata - Sıralama getirilemedi: $e');
      return [];
    }
  }

  /// 🎮 Kullanıcının oynadığı oyunları getir
  Future<List<Game>> getUserPlayedGames(String userId, {int limit = 10}) async {
    try {
      final scores = await _firestore
          .collection('game_scores')
          .where('userId', isEqualTo: userId)
          .orderBy('playedAt', descending: true)
          .limit(limit)
          .get();

      final gameIds = scores.docs.map((doc) => doc['gameId'] as String).toList();

      if (gameIds.isEmpty) return [];

      final games = <Game>[];
      for (final gameId in gameIds) {
        final gameDoc = await _firestore.collection('games').doc(gameId).get();
        if (gameDoc.exists) {
          games.add(Game.fromFirestore(gameDoc));
        }
      }

      return games;
    } catch (e) {
      print('Hata - Kullanıcı oyunları getirilemedi: $e');
      return [];
    }
  }

  /// 👨‍💻 Kullanıcının oluşturduğu oyunları getir
  Future<List<Game>> getUserCreatedGames(String userId, {int limit = 10}) async {
    try {
      final snapshot = await _firestore
          .collection('games')
          .where('creatorId', isEqualTo: userId)
          .where('isPublished', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => Game.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Hata - Kullanıcı oluşturduğu oyunlar getirilemedi: $e');
      return [];
    }
  }

  /// 💾 Yorum ekle
  Future<void> addComment({
    required String gameId,
    required String userId,
    required String userName,
    required String comment,
  }) async {
    try {
      await _firestore.collection('game_comments').add(
        GameComment(
          id: '',
          gameId: gameId,
          userId: userId,
          userName: userName,
          userAvatar: '',
          comment: comment,
          createdAt: DateTime.now(),
        ).toFirestore(),
      );
    } catch (e) {
      print('Hata - Yorum eklenemedi: $e');
    }
  }

  /// ⭐ Puan ekle
  Future<void> addRating({
    required String gameId,
    required String userId,
    required int rating,
  }) async {
    try {
      // Eğer kullanıcı daha önce puan verdiyse, onu güncelleyelim
      final existingRating = await _firestore
          .collection('game_ratings')
          .where('gameId', isEqualTo: gameId)
          .where('userId', isEqualTo: userId)
          .get();

      if (existingRating.docs.isNotEmpty) {
        // Mevcut puanı güncelle
        await existingRating.docs.first.reference.update({'rating': rating});
      } else {
        // Yeni puan ekle
        await _firestore.collection('game_ratings').add(
          GameRating(
            id: '',
            gameId: gameId,
            userId: userId,
            rating: rating,
            createdAt: DateTime.now(),
          ).toFirestore(),
        );
      }
    } catch (e) {
      print('Hata - Puan eklenemedi: $e');
    }
  }

  /// 📊 Oyun istatistiklerine küçük resim ekle (WebView'den sonra)
  Future<void> updateGameStats({
    required String gameId,
    required String userId,
    required String userName,
    required int score,
    required int correctAnswers,
    required int totalQuestions,
    required int timeSpent,
  }) async {
    try {
      // Skor kaydet
      await _firestore.collection('game_scores').add(
        GameScore(
          id: '',
          gameId: gameId,
          userId: userId,
          userName: userName,
          score: score,
          correctAnswers: correctAnswers,
          totalQuestions: totalQuestions,
          timeSpent: timeSpent,
          playedAt: DateTime.now(),
        ).toFirestore(),
      );

      // Oyunun oynama sayısını artır
      final gameDoc = await _firestore.collection('games').doc(gameId).get();
      if (gameDoc.exists) {
        final game = Game.fromFirestore(gameDoc);
        await _firestore.collection('games').doc(gameId).update({
          'playCount': game.playCount + 1,
        });
      }
    } catch (e) {
      print('Hata - Oyun istatistikleri güncellenemedi: $e');
    }
  }
}
