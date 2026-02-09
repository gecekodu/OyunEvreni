// 🎮 AI GAME SOCIAL SERVICE
// AI oyunlarını Firestore'a kaydetme ve sosyal akışta gösterme

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../features/ai_game_engine/domain/entities/game_template.dart';

class AIGameSocialService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'ai_games';

  /// Oyunu Firestore'a kaydet ve paylaş
  Future<String> shareGame({
    required AIGameConfig gameConfig,
    required String userId,
    required String userName,
  }) async {
    try {
      final docRef = await _firestore.collection(_collection).add({
        'gameId': gameConfig.gameId,
        'title': gameConfig.title,
        'description': gameConfig.description,
        'template': gameConfig.template.name,
        'difficulty': gameConfig.difficulty,
        'targetAge': gameConfig.targetAge,
        'subject': gameConfig.educationalContent?.subject ?? 'Genel',
        'questionCount': gameConfig.educationalContent?.questions.length ?? 0,
        'gameConfig': gameConfig.toJson(), // Tam config kaydet
        'createdBy': userId,
        'createdByName': userName,
        'createdAt': FieldValue.serverTimestamp(),
        'playCount': 0,
        'likeCount': 0,
        'likes': [], // User ID'leri
        'isPublic': true,
      });

      return docRef.id;
    } catch (e) {
      throw Exception('Oyun paylaşılamadı: $e');
    }
  }

  /// HTML 3D oyununu Firestore'a kaydet ve paylaş
  Future<String> shareGameHtml({
    required String htmlCode,
    required String title,
    required String description,
    required String userId,
    required String userName,
    required String difficulty,
    required int targetAge,
  }) async {
    try {
      final gameId = 'html_${DateTime.now().millisecondsSinceEpoch}';
      final docRef = await _firestore.collection(_collection).add({
        'gameId': gameId,
        'title': title,
        'description': description,
        'template': 'html3d',
        'difficulty': difficulty,
        'targetAge': targetAge,
        'subject': 'Genel',
        'questionCount': 0,
        'htmlGame': htmlCode,
        'isHtmlGame': true,
        'gameType': 'html3d',
        'createdBy': userId,
        'createdByName': userName,
        'createdAt': FieldValue.serverTimestamp(),
        'playCount': 0,
        'likeCount': 0,
        'likes': [],
        'isPublic': true,
      });

      return docRef.id;
    } catch (e) {
      throw Exception('HTML oyun paylaşılamadı: $e');
    }
  }

  /// Sosyal akıştaki tüm oyunları getir (en yeniler)
  Stream<List<SharedAIGame>> getGameFeed({int limit = 20}) {
    return _firestore
        .collection(_collection)
        .where('isPublic', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return SharedAIGame.fromFirestore(doc);
      }).toList();
    });
  }

  /// Kullanıcının kendi oyunlarını getir
  Stream<List<SharedAIGame>> getUserGames(String userId) {
    return _firestore
        .collection(_collection)
        .where('createdBy', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return SharedAIGame.fromFirestore(doc);
      }).toList();
    });
  }

  /// Oyunu beğen/beğeniyi kaldır
  Future<void> toggleLike(String gameDocId, String userId) async {
    final docRef = _firestore.collection(_collection).doc(gameDocId);
    final doc = await docRef.get();

    if (!doc.exists) return;

    final likes = List<String>.from(doc.data()?['likes'] ?? []);
    final isLiked = likes.contains(userId);

    if (isLiked) {
      // Beğeniyi kaldır
      await docRef.update({
        'likes': FieldValue.arrayRemove([userId]),
        'likeCount': FieldValue.increment(-1),
      });
    } else {
      // Beğen
      await docRef.update({
        'likes': FieldValue.arrayUnion([userId]),
        'likeCount': FieldValue.increment(1),
      });
    }
  }

  /// Oyun oynanma sayısını artır
  Future<void> incrementPlayCount(String gameDocId) async {
    await _firestore.collection(_collection).doc(gameDocId).update({
      'playCount': FieldValue.increment(1),
    });
  }

  /// Belirli bir oyunu getir
  Future<SharedAIGame?> getGame(String gameDocId) async {
    final doc = await _firestore.collection(_collection).doc(gameDocId).get();
    if (!doc.exists) return null;
    return SharedAIGame.fromFirestore(doc);
  }

  /// Oyunu sil (sadece sahibi silebilir)
  Future<void> deleteGame(String gameDocId, String userId) async {
    final doc = await _firestore.collection(_collection).doc(gameDocId).get();
    if (!doc.exists) return;

    final createdBy = doc.data()?['createdBy'];
    if (createdBy != userId) {
      throw Exception('Bu oyunu silme yetkiniz yok');
    }

    await _firestore.collection(_collection).doc(gameDocId).delete();
  }

  /// Template'e göre oyunları getir
  Stream<List<SharedAIGame>> getGamesByTemplate(String template) {
    return _firestore
        .collection(_collection)
        .where('isPublic', isEqualTo: true)
        .where('template', isEqualTo: template)
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return SharedAIGame.fromFirestore(doc);
      }).toList();
    });
  }

  /// Popüler oyunları getir (en çok oynanan)
  Stream<List<SharedAIGame>> getPopularGames({int limit = 10}) {
    return _firestore
        .collection(_collection)
        .where('isPublic', isEqualTo: true)
        .orderBy('playCount', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return SharedAIGame.fromFirestore(doc);
      }).toList();
    });
  }
}

/// Paylaşılan AI oyun modeli
class SharedAIGame {
  final String docId;
  final String gameId;
  final String title;
  final String description;
  final String template;
  final String difficulty;
  final int targetAge;
  final String subject;
  final int questionCount;
  final AIGameConfig? gameConfig;
  final String? htmlCode;
  final bool isHtmlGame;
  final String createdBy;
  final String createdByName;
  final DateTime? createdAt;
  final int playCount;
  final int likeCount;
  final List<String> likes;
  final bool isPublic;

  SharedAIGame({
    required this.docId,
    required this.gameId,
    required this.title,
    required this.description,
    required this.template,
    required this.difficulty,
    required this.targetAge,
    required this.subject,
    required this.questionCount,
    required this.gameConfig,
    required this.htmlCode,
    required this.isHtmlGame,
    required this.createdBy,
    required this.createdByName,
    this.createdAt,
    required this.playCount,
    required this.likeCount,
    required this.likes,
    required this.isPublic,
    });

  factory SharedAIGame.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final hasGameConfig = data['gameConfig'] != null;
    return SharedAIGame(
      docId: doc.id,
      gameId: data['gameId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      template: data['template'] ?? '',
      difficulty: data['difficulty'] ?? '',
      targetAge: data['targetAge'] ?? 7,
      subject: data['subject'] ?? '',
      questionCount: data['questionCount'] ?? 0,
      gameConfig: hasGameConfig ? AIGameConfig.fromJson(data['gameConfig']) : null,
      htmlCode: data['htmlGame'],
      isHtmlGame: data['isHtmlGame'] ?? false,
      createdBy: data['createdBy'] ?? '',
      createdByName: data['createdByName'] ?? 'Anonim',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      playCount: data['playCount'] ?? 0,
      likeCount: data['likeCount'] ?? 0,
      likes: List<String>.from(data['likes'] ?? []),
      isPublic: data['isPublic'] ?? true,
    );
  }

  bool isLikedBy(String userId) => likes.contains(userId);
}
