// 🎮 OYUN KAYIT VE YÜKLEME SERVİSİ

import 'package:cloud_firestore/cloud_firestore.dart';
import 'game_html_generator.dart';

class GameService {
  final FirebaseFirestore firestore;

  GameService({required this.firestore});

  /// 🎮 Oyunu oluştur ve Firestore'a kaydet
  Future<String> createAndSaveGame({
    required String title,
    required String description,
    required String gameType,
    required String difficulty,
    required List<String> learningGoals,
    required Map<String, dynamic> geminiContent,
    required String userId,
    required String userName,
  }) async {
    try {
      // HTML'i oluştur
      String htmlContent = '';
      if (gameType == 'math') {
        htmlContent = GameHtmlGenerator.generateMathGameHtml(
          title: title,
          difficulty: difficulty,
          gameContent: geminiContent,
        );
      } else {
        htmlContent = GameHtmlGenerator.generateGenericGameHtml(
          title: title,
          gameType: gameType,
          gameContent: geminiContent,
        );
      }

      // Oyun metadata'sını hazırla
      final gameData = {
        'title': title,
        'description': description,
        'gameType': gameType,
        'difficulty': difficulty,
        'learningGoals': learningGoals,
        'creatorId': userId,
        'creatorName': userName,
        'htmlContent': htmlContent,
        'geminiContent': geminiContent,
        'playCount': 0,
        'rating': 0.0,
        'ratingCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isPublished': true,
      };

      // Firestore'a kaydet
      final docRef = await firestore.collection('games').add(gameData);
      
      print('✅ Oyun başarıyla kaydedildi: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Oyun kaydı hatası: $e');
      rethrow;
    }
  }

  /// 🎮 Oyunu ID'den yükle
  Future<Map<String, dynamic>?> getGameById(String gameId) async {
    try {
      final doc = await firestore.collection('games').doc(gameId).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('❌ Oyun yükleme hatası: $e');
      return null;
    }
  }

  /// 🎮 HTML içeriğini getir
  Future<String?> getGameHtml(String gameId) async {
    try {
      final game = await getGameById(gameId);
      return game?['htmlContent'] as String?;
    } catch (e) {
      print('❌ HTML yükleme hatası: $e');
      return null;
    }
  }

  /// 🎮 Kullanıcının oyunlarını listele
  Future<List<Map<String, dynamic>>> getUserGames(String userId) async {
    try {
      final snapshot = await firestore
          .collection('games')
          .where('creatorId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('❌ Oyunlar yükleme hatası: $e');
      return [];
    }
  }

  /// 🎮 Oyunun oynama sayısını artır
  Future<void> incrementPlayCount(String gameId) async {
    try {
      await firestore.collection('games').doc(gameId).update({
        'playCount': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('❌ Play count güncelleme hatası: $e');
    }
  }

  /// 🎮 Oyunu puanla
  Future<void> rateGame(
    String gameId,
    double rating,
    String userId,
  ) async {
    try {
      final ratingData = {
        'gameId': gameId,
        'userId': userId,
        'rating': rating,
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Oyuncunun rating'ini kaydet
      final ratingRef = firestore.collection('gameRatings');
      await ratingRef
          .where('gameId', isEqualTo: gameId)
          .where('userId', isEqualTo: userId)
          .get()
          .then((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          // Güncelle
          snapshot.docs.first.reference.update(ratingData);
        } else {
          // Ekle
          ratingRef.add(ratingData);
        }
      });

      // Oyunun ortalama rating'ini güncelle
      final ratingsSnapshot = await ratingRef
          .where('gameId', isEqualTo: gameId)
          .get();

      if (ratingsSnapshot.docs.isNotEmpty) {
        final ratings = ratingsSnapshot.docs
            .map((doc) => (doc.data()['rating'] as num).toDouble())
            .toList();

        final avgRating =
            ratings.fold(0.0, (a, b) => a + b) / ratings.length;

        await firestore.collection('games').doc(gameId).update({
          'rating': avgRating,
          'ratingCount': ratings.length,
        });
      }
    } catch (e) {
      print('❌ Rating hatası: $e');
    }
  }

  /// 🎮 Oyuna yorum ekle
  Future<void> addComment(
    String gameId,
    String userId,
    String userName,
    String comment,
  ) async {
    try {
      await firestore.collection('gameComments').add({
        'gameId': gameId,
        'userId': userId,
        'userName': userName,
        'comment': comment,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('❌ Yorum ekleme hatası: $e');
    }
  }

  /// 🎮 Oyunun yorumlarını getir
  Future<List<Map<String, dynamic>>> getGameComments(String gameId) async {
    try {
      final snapshot = await firestore
          .collection('gameComments')
          .where('gameId', isEqualTo: gameId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('❌ Yorumlar yükleme hatası: $e');
      return [];
    }
  }
}
