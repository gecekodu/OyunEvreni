// 💬 KLAN SOHBET SERVİSİ

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/clan_message.dart';

class ClanChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Koleksiyon referansları
  CollectionReference get _clansRef => _firestore.collection('clans');
  CollectionReference get _messagesRef => _firestore.collection('clan_messages');

  /// Mesaj gönder
  Future<void> sendMessage({
    required String clanId,
    required String message,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Kullanıcı girişi gerekli');

    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final userData = userDoc.data();

    final clanMessage = ClanMessage(
      id: '',
      clanId: clanId,
      userId: user.uid,
      userName: userData?['username'] ?? user.displayName ?? 'Kullanıcı',
      userPhotoUrl: userData?['photoURL'],
      message: message,
      timestamp: DateTime.now(),
    );

    await _messagesRef.add(clanMessage.toFirestore());
  }

  /// Klan mesajlarını stream olarak getir
  Stream<List<ClanMessage>> getClanMessagesStream(String clanId) {
    return _messagesRef
        .where('clanId', isEqualTo: clanId)
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
    final snapshot = await _messagesRef
        .where('clanId', isEqualTo: clanId)
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return ClanMessage.fromFirestore(snapshot.docs.first);
  }

  /// Mesajı sil (sadece kendi mesajını)
  Future<void> deleteMessage(String messageId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Kullanıcı girişi gerekli');

    final messageDoc = await _messagesRef.doc(messageId).get();
    if (!messageDoc.exists) throw Exception('Mesaj bulunamadı');

    final message = ClanMessage.fromFirestore(messageDoc);
    if (message.userId != user.uid) {
      throw Exception('Sadece kendi mesajını silebilirsin');
    }

    await _messagesRef.doc(messageId).delete();
  }

  /// Mesaja tepki ekle
  Future<void> addReaction(String messageId, String reaction) async {
    final messageDoc = await _messagesRef.doc(messageId).get();
    if (!messageDoc.exists) throw Exception('Mesaj bulunamadı');

    final message = ClanMessage.fromFirestore(messageDoc);
    final reactions = List<String>.from(message.reactions);

    if (reactions.contains(reaction)) {
      reactions.remove(reaction);
    } else {
      reactions.add(reaction);
    }

    await _messagesRef.doc(messageId).update({
      'reactions': reactions,
    });
  }

  /// Mesaj sayısını getir
  Future<int> getMessageCount(String clanId) async {
    final snapshot = await _messagesRef
        .where('clanId', isEqualTo: clanId)
        .count()
        .get();

    return snapshot.count ?? 0;
  }
}
