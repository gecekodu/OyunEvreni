// 🏰 KLAN - Domain Entity

import 'package:cloud_firestore/cloud_firestore.dart';

class Clan {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final String leaderId;
  final String leaderName;
  final List<String> memberIds;
  final int totalScore;
  final DateTime createdAt;
  final String? imageUrl;
  final int maxMembers;

  const Clan({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.leaderId,
    required this.leaderName,
    required this.memberIds,
    required this.totalScore,
    required this.createdAt,
    this.imageUrl,
    this.maxMembers = 50,
  });

  int get memberCount => memberIds.length;
  
  bool get isFull => memberIds.length >= maxMembers;

  factory Clan.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Clan(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      emoji: data['emoji'] ?? '🏰',
      leaderId: data['leaderId'] ?? '',
      leaderName: data['leaderName'] ?? '',
      memberIds: List<String>.from(data['memberIds'] ?? []),
      totalScore: data['totalScore'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      imageUrl: data['imageUrl'],
      maxMembers: data['maxMembers'] ?? 50,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'emoji': emoji,
      'leaderId': leaderId,
      'leaderName': leaderName,
      'memberIds': memberIds,
      'totalScore': totalScore,
      'createdAt': Timestamp.fromDate(createdAt),
      'imageUrl': imageUrl,
      'maxMembers': maxMembers,
    };
  }

  Clan copyWith({
    String? id,
    String? name,
    String? description,
    String? emoji,
    String? leaderId,
    String? leaderName,
    List<String>? memberIds,
    int? totalScore,
    DateTime? createdAt,
    String? imageUrl,
    int? maxMembers,
  }) {
    return Clan(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      emoji: emoji ?? this.emoji,
      leaderId: leaderId ?? this.leaderId,
      leaderName: leaderName ?? this.leaderName,
      memberIds: memberIds ?? this.memberIds,
      totalScore: totalScore ?? this.totalScore,
      createdAt: createdAt ?? this.createdAt,
      imageUrl: imageUrl ?? this.imageUrl,
      maxMembers: maxMembers ?? this.maxMembers,
    );
  }
}

class ClanMember {
  final String userId;
  final String userName;
  final String? photoUrl;
  final int score;
  final DateTime joinedAt;
  final bool isLeader;

  const ClanMember({
    required this.userId,
    required this.userName,
    this.photoUrl,
    required this.score,
    required this.joinedAt,
    this.isLeader = false,
  });

  factory ClanMember.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ClanMember(
      userId: doc.id,
      userName: data['userName'] ?? '',
      photoUrl: data['photoUrl'],
      score: data['score'] ?? 0,
      joinedAt: (data['joinedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isLeader: data['isLeader'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userName': userName,
      'photoUrl': photoUrl,
      'score': score,
      'joinedAt': Timestamp.fromDate(joinedAt),
      'isLeader': isLeader,
    };
  }
}
