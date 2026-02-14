// 🏰 KLAN SERVİSİ - Firestore ile Klan Yönetimi

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/clan.dart';

class ClanService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Koleksiyon referansları
  CollectionReference get _clansRef => _firestore.collection('clans');
  CollectionReference get _usersRef => _firestore.collection('users');

  /// Yeni klan oluştur
  Future<String> createClan({
    required String name,
    required String description,
    required String emoji,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Kullanıcı girişi gerekli');

    // Kullanıcı verilerini al
    final userDoc = await _usersRef.doc(user.uid).get();
    final userData = userDoc.data() as Map<String, dynamic>?;
    final userName = userData?['username'] ?? user.displayName ?? 'Kullanıcı';

    // Kullanıcının zaten bir klanı var mı kontrol et
    final existingClan = await getUserClan(user.uid);
    if (existingClan != null) {
      throw Exception('Zaten bir klana üyesiniz');
    }

    // Yeni klan oluştur
    final clan = Clan(
      id: '',
      name: name,
      description: description,
      emoji: emoji,
      leaderId: user.uid,
      leaderName: userName,
      memberIds: [user.uid],
      totalScore: 0,
      createdAt: DateTime.now(),
    );

    final docRef = await _clansRef.add(clan.toFirestore());

    // Kullanıcının klan ID'sini güncelle
    await _usersRef.doc(user.uid).update({
      'clanId': docRef.id,
      'clanRole': 'leader',
    });

    return docRef.id;
  }

  /// Klana katıl
  Future<void> joinClan(String clanId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Kullanıcı girişi gerekli');

    // Kullanıcının zaten bir klanı var mı kontrol et
    final existingClan = await getUserClan(user.uid);
    if (existingClan != null) {
      throw Exception('Zaten bir klana üyesiniz');
    }

    // Klan kontrolü
    final clanDoc = await _clansRef.doc(clanId).get();
    if (!clanDoc.exists) throw Exception('Klan bulunamadı');

    final clan = Clan.fromFirestore(clanDoc);
    if (clan.isFull) throw Exception('Klan dolu');

    // Kullanıcı verilerini al
    final userDoc = await _usersRef.doc(user.uid).get();
    final userData = userDoc.data() as Map<String, dynamic>?;
    final userName = userData?['username'] ?? user.displayName ?? 'Kullanıcı';

    // Klana üye ekle
    await _clansRef.doc(clanId).update({
      'memberIds': FieldValue.arrayUnion([user.uid]),
    });

    // Kullanıcının klan ID'sini güncelle
    await _usersRef.doc(user.uid).update({
      'clanId': clanId,
      'clanRole': 'member',
    });

    // 🏰 Klan puanı güncelle (yeni üyeyi ekle)
    await updateClanScore(clanId);
  }

  /// Klandan ayrıl
  Future<void> leaveClan(String clanId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Kullanıcı girişi gerekli');

    final clanDoc = await _clansRef.doc(clanId).get();
    if (!clanDoc.exists) throw Exception('Klan bulunamadı');

    final clan = Clan.fromFirestore(clanDoc);

    // Lider klanı terk edemez, önce liderliği devretmeli
    if (clan.leaderId == user.uid) {
      throw Exception('Lider klanı terk edemez. Önce liderliği devredin veya klanı silin.');
    }

    // Klannan üyeyi çıkar
    await _clansRef.doc(clanId).update({
      'memberIds': FieldValue.arrayRemove([user.uid]),
    });

    // Kullanıcının klan bilgilerini temizle
    await _usersRef.doc(user.uid).update({
      'clanId': FieldValue.delete(),
      'clanRole': FieldValue.delete(),
    });

    // 🏰 Klan puanı güncelle (üyeyi sil)
    await updateClanScore(clanId);
  }

  /// Klanı sil (sadece lider)
  Future<void> deleteClan(String clanId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Kullanıcı girişi gerekli');

    final clanDoc = await _clansRef.doc(clanId).get();
    if (!clanDoc.exists) throw Exception('Klan bulunamadı');

    final clan = Clan.fromFirestore(clanDoc);

    // Sadece lider silebilir
    if (clan.leaderId != user.uid) {
      throw Exception('Sadece lider klanı silebilir');
    }

    // Tüm üyelerin klan bilgilerini temizle
    for (final memberId in clan.memberIds) {
      await _usersRef.doc(memberId).update({
        'clanId': FieldValue.delete(),
        'clanRole': FieldValue.delete(),
      });
    }

    // Klanı sil
    await _clansRef.doc(clanId).delete();
  }

  /// Kullanıcının klanını getir
  Future<Clan?> getUserClan(String userId) async {
    final userDoc = await _usersRef.doc(userId).get();
    final userData = userDoc.data() as Map<String, dynamic>?;
    final clanId = userData?['clanId'] as String?;

    if (clanId == null) return null;

    final clanDoc = await _clansRef.doc(clanId).get();
    if (!clanDoc.exists) return null;

    return Clan.fromFirestore(clanDoc);
  }

  /// Tüm klanları getir (sıralama ile)
  Stream<List<Clan>> getAllClansStream({String orderBy = 'totalScore'}) {
    return _clansRef
        .orderBy(orderBy, descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Clan.fromFirestore(doc))
            .toList());
  }

  /// Klan araması
  Future<List<Clan>> searchClans(String query) async {
    if (query.isEmpty) {
      final snapshot = await _clansRef
          .orderBy('totalScore', descending: true)
          .limit(20)
          .get();
      return snapshot.docs.map((doc) => Clan.fromFirestore(doc)).toList();
    }

    // İsim araması
    final snapshot = await _clansRef
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThan: '${query}z')
        .limit(20)
        .get();

    return snapshot.docs.map((doc) => Clan.fromFirestore(doc)).toList();
  }

  /// Klan üyelerini getir
  Future<List<Map<String, dynamic>>> getClanMembers(String clanId) async {
    final clanDoc = await _clansRef.doc(clanId).get();
    if (!clanDoc.exists) return [];

    final clan = Clan.fromFirestore(clanDoc);
    final members = <Map<String, dynamic>>[];

    for (final memberId in clan.memberIds) {
      final userDoc = await _usersRef.doc(memberId).get();
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        members.add({
          'userId': memberId,
          'userName': userData['username'] ?? 'Kullanıcı',
          'photoUrl': userData['photoURL'],
          'score': userData['totalScore'] ?? 0,
          'isLeader': memberId == clan.leaderId,
        });
      }
    }

    // Puana göre sırala
    members.sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));

    return members;
  }

  /// Klan toplam puanını güncelle
  Future<void> updateClanScore(String clanId) async {
    final members = await getClanMembers(clanId);
    final totalScore = members.fold<int>(
      0,
      (sum, member) => sum + (member['score'] as int),
    );

    await _clansRef.doc(clanId).update({
      'totalScore': totalScore,
    });
  }

  /// Tüm klanların puanlarını yeniden hesapla (admin işlemi)
  Future<void> recalculateAllClanScores() async {
    try {
      final clansSnapshot = await _clansRef.get();
      
      for (final clanDoc in clansSnapshot.docs) {
        final clanId = clanDoc.id;
        final members = await getClanMembers(clanId);
        final totalScore = members.fold<int>(
          0,
          (sum, member) => sum + (member['score'] as int),
        );
        
        await _clansRef.doc(clanId).update({
          'totalScore': totalScore,
        });
        
        print('✅ Klan puanı yeniden hesaplandı: $clanId -> $totalScore puan');
      }
      
      print('✅ TÜM KLAN PUANLARI YENİDEN HESAPLANDI!');
    } catch (e) {
      print('❌ Klan puanları oluşturma hatası: $e');
      rethrow;
    }
  }

  /// Belirli bir klanı ID ile getir
  Future<Clan?> getClanById(String clanId) async {
    final doc = await _clansRef.doc(clanId).get();
    if (!doc.exists) return null;
    return Clan.fromFirestore(doc);
  }

  /// Klan bilgilerini güncelle (sadece lider)
  Future<void> updateClan({
    required String clanId,
    String? name,
    String? description,
    String? emoji,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Kullanıcı girişi gerekli');

    final clanDoc = await _clansRef.doc(clanId).get();
    if (!clanDoc.exists) throw Exception('Klan bulunamadı');

    final clan = Clan.fromFirestore(clanDoc);
    if (clan.leaderId != user.uid) {
      throw Exception('Sadece lider klan bilgilerini güncelleyebilir');
    }

    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (description != null) updates['description'] = description;
    if (emoji != null) updates['emoji'] = emoji;

    if (updates.isNotEmpty) {
      await _clansRef.doc(clanId).update(updates);
    }
  }
}
