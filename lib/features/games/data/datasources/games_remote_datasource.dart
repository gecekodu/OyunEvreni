// 🎮 Games Remote Datasource (Firestore)

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/game_model.dart';
import '../../../../core/services/firebase_service.dart';
import '../../../../core/errors/exceptions.dart';

class GamesRemoteDataSource {
  final FirebaseService _firebaseService;

  GamesRemoteDataSource({
    required FirebaseService firebaseService,
  }) : _firebaseService = firebaseService;

  // ➕ Yeni oyun kaydet
  Future<String> saveGame({
    required String creatorUserId,
    required String creatorName,
    required String lesson,
    required String topic,
    required String grade,
    required String difficulty,
    required String title,
    required String description,
    required Map<String, dynamic> jsonDefinition,
  }) async {
    try {
      final docRef = _firebaseService.firestore.collection('games').doc();
      final gameId = docRef.id;

      final game = GameModel(
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
        createdAt: DateTime.now(),
      );

      await docRef.set(game.toJson());
      print('✅ Oyun kaydedildi: $gameId');
      return gameId;
    } catch (e) {
      throw FirestoreException(
        message: 'Oyun kaydedilirken hata: $e',
        code: 'SAVE_GAME_ERROR',
      );
    }
  }

  // 📥 Tüm oyunları getir (filtrelemeli)
  Future<List<GameModel>> getAllGames({
    String? lesson,
    String? topic,
    String? grade,
    String? difficulty,
    int limit = 20,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firebaseService.firestore.collection('games');

      // Filtreler
      if (lesson != null) query = query.where('lesson', isEqualTo: lesson);
      if (topic != null) query = query.where('topic', isEqualTo: topic);
      if (grade != null) query = query.where('grade', isEqualTo: grade);
      if (difficulty != null) query = query.where('difficulty', isEqualTo: difficulty);

      // En yeni oyunlar önce
      query = query.orderBy('createdAt', descending: true).limit(limit);

      final querySnapshot = await query.get();
      return querySnapshot.docs
          .map((doc) => GameModel.fromFirestore(doc.data()))
          .toList();
    } catch (e) {
      throw FirestoreException(
        message: 'Oyunlar getirilirken hata: $e',
        code: 'GET_GAMES_ERROR',
      );
    }
  }

  // 🔍 Oyun ID'ye göre getir
  Future<GameModel> getGameById(String gameId) async {
    try {
      final doc = await _firebaseService.firestore
          .collection('games')
          .doc(gameId)
          .get();

      if (!doc.exists) {
        throw FirestoreException(
          message: 'Oyun bulunamadı',
          code: 'GAME_NOT_FOUND',
        );
      }

      return GameModel.fromFirestore(doc.data() as Map<String, dynamic>);
    } catch (e) {
      if (e is FirestoreException) rethrow;
      throw FirestoreException(
        message: 'Oyun alınırken hata: $e',
        code: 'GET_GAME_ERROR',
      );
    }
  }

  // 👤 Kullanıcının oyunlarını getir
  Future<List<GameModel>> getUserGames(String userId) async {
    try {
      final querySnapshot = await _firebaseService.firestore
          .collection('games')
          .where('creatorUserId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => GameModel.fromFirestore(doc.data()))
          .toList();
    } catch (e) {
      throw FirestoreException(
        message: 'Kullanıcı oyunları getirilirken hata: $e',
        code: 'GET_USER_GAMES_ERROR',
      );
    }
  }

  // ⭐ Oyuna puan ve yorum ekle
  Future<void> rateGame({
    required String gameId,
    required String userId,
    required double rating,
    required String? comment,
  }) async {
    try {
      // Rating dökümanını kaydet
      final ratingId = '$gameId-$userId';
      await _firebaseService.firestore
          .collection('ratings')
          .doc(ratingId)
          .set({
        'gameId': gameId,
        'userId': userId,
        'rating': rating,
        'comment': comment,
        'createdAt': DateTime.now().toIso8601String(),
      });

      // Oyunun ortalama puanını güncelle
      await _updateGameRating(gameId);

      print('✅ Oyun puanlandı: $gameId');
    } catch (e) {
      throw FirestoreException(
        message: 'Puanlama sırasında hata: $e',
        code: 'RATE_GAME_ERROR',
      );
    }
  }

  // 🔢 Oyunun ortalama puanını güncelle
  Future<void> _updateGameRating(String gameId) async {
    try {
      final ratingsSnapshot = await _firebaseService.firestore
          .collection('ratings')
          .where('gameId', isEqualTo: gameId)
          .get();

      if (ratingsSnapshot.docs.isEmpty) return;

      final ratings = ratingsSnapshot.docs
          .map((doc) => (doc.data()['rating'] as num).toDouble())
          .toList();

      final averageRating = ratings.reduce((a, b) => a + b) / ratings.length;

      await _firebaseService.firestore
          .collection('games')
          .doc(gameId)
          .update({
        'rating': averageRating,
        'ratingCount': ratingsSnapshot.docs.length,
      });
    } catch (e) {
      print('❌ Rating güncelleme hatası: $e');
    }
  }

  // 📊 Oyun oynama kaydı kaydet
  Future<void> saveGameResult({
    required String gameId,
    required String userId,
    required int score,
    required bool completed,
    required int timeSpent,
  }) async {
    try {
      await _firebaseService.firestore
          .collection('gameResults')
          .add({
        'gameId': gameId,
        'userId': userId,
        'score': score,
        'completed': completed,
        'timeSpent': timeSpent,
        'playedAt': DateTime.now().toIso8601String(),
      });

      // Oyunun oynama sayısını artır
      await _firebaseService.firestore
          .collection('games')
          .doc(gameId)
          .update({
        'playCount': FieldValue.increment(1),
      });

      print('✅ Oyun sonucu kaydedildi');
    } catch (e) {
      throw FirestoreException(
        message: 'Oyun sonucu kaydedilirken hata: $e',
        code: 'SAVE_GAME_RESULT_ERROR',
      );
    }
  }

  // 🗑️ Oyunu sil
  Future<void> deleteGame(String gameId) async {
    try {
      await _firebaseService.firestore
          .collection('games')
          .doc(gameId)
          .delete();
      print('✅ Oyun silindi: $gameId');
    } catch (e) {
      throw FirestoreException(
        message: 'Oyun silinirken hata: $e',
        code: 'DELETE_GAME_ERROR',
      );
    }
  }

  // ✏️ Oyunu güncelle
  Future<void> updateGame({
    required String gameId,
    required String title,
    required String description,
    required String difficulty,
    required Map<String, dynamic> jsonDefinition,
  }) async {
    try {
      await _firebaseService.firestore
          .collection('games')
          .doc(gameId)
          .update({
        'title': title,
        'description': description,
        'difficulty': difficulty,
        'jsonDefinition': jsonDefinition,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      print('✅ Oyun güncellendi: $gameId');
    } catch (e) {
      throw FirestoreException(
        message: 'Oyun güncellenirken hata: $e',
        code: 'UPDATE_GAME_ERROR',
      );
    }
  }
}
