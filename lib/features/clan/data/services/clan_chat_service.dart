// 💬 KLAN SOHBET SERVİSİ

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/clan_message.dart';

class ClanChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Koleksiyon referansları
  CollectionReference get _clansRef => _firestore.collection('clans');
  CollectionReference<Map<String, dynamic>> _clanMessagesRef(String clanId) =>
      _clansRef.doc(clanId).collection('messages');

  /// Mesaj gönder
  Future<void> sendMessage({
    required String clanId,
    required String message,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      print('❌ Mesaj gönderme hatası: Kullanıcı girişi gerekli');
      throw Exception('Kullanıcı girişi gerekli');
    }

    try {
      print('📤 Mesaj gönderiliyor... User: ${user.uid}');
      
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userData = userDoc.data();

      print('👤 Kullanıcı verisi: ${userData?['username'] ?? 'Bilinmeyen'}');

      final clanMessage = ClanMessage(
        id: '',
        clanId: clanId,
        userId: user.uid,
        userName: userData?['username'] ?? user.displayName ?? 'Kullanıcı',
        userPhotoUrl: userData?['photoURL'] ?? '',
        userAvatarEmoji: userData?['avatarEmoji'] ?? '',
        message: message,
        timestamp: DateTime.now(),
      );

      print('💾 Firestore\'a yazılıyor: clanId=$clanId');

      // Mesajı gönder (klana ozel alt koleksiyon)
      final docRef = await _clanMessagesRef(clanId).add({
        ...clanMessage.toFirestore(),
        'clanId': clanId,
      });
      print('✅ Mesaj başarıyla gönderildi! ID: ${docRef.id}, Klan: $clanId');
      
    } catch (e) {
      print('❌ Mesaj gönderme hatası: $e');
      rethrow;
    }
  }

  /// Klan mesajlarını stream olarak getir
  Stream<List<ClanMessage>> getClanMessagesStream(String clanId) {
    return _clanMessagesRef(clanId)
      .orderBy('timestamp', descending: true)
      .limit(50)
      .snapshots()
      .map((snapshot) => snapshot.docs
        .map((doc) => ClanMessage.fromFirestore(doc))
        .toList()
        .reversed
        .toList());
  }

  /// Son mesajı getir
  Future<ClanMessage?> getLastMessage(String clanId) async {
    final snapshot = await _clanMessagesRef(clanId)
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return ClanMessage.fromFirestore(snapshot.docs.first);
  }

  /// Mesajı sil (sadece kendi mesajını)
  Future<void> deleteMessage(String clanId, String messageId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Kullanıcı girişi gerekli');

    final messageDoc = await _clanMessagesRef(clanId).doc(messageId).get();
    if (!messageDoc.exists) throw Exception('Mesaj bulunamadı');

    final message = ClanMessage.fromFirestore(messageDoc);
    if (message.userId != user.uid) {
      throw Exception('Sadece kendi mesajını silebilirsin');
    }

    await _clanMessagesRef(clanId).doc(messageId).delete();
  }

  /// Mesaja tepki ekle
  Future<void> addReaction(String clanId, String messageId, String reaction) async {
    final messageDoc = await _clanMessagesRef(clanId).doc(messageId).get();
    if (!messageDoc.exists) throw Exception('Mesaj bulunamadı');

    final message = ClanMessage.fromFirestore(messageDoc);
    final reactions = List<String>.from(message.reactions);

    if (reactions.contains(reaction)) {
      reactions.remove(reaction);
    } else {
      reactions.add(reaction);
    }

    await _clanMessagesRef(clanId).doc(messageId).update({
      'reactions': reactions,
    });
  }

  /// Mesaj sayısını getir
  Future<int> getMessageCount(String clanId) async {
    final snapshot = await _clanMessagesRef(clanId)
        .count()
        .get();

    return snapshot.count ?? 0;
  }
}
