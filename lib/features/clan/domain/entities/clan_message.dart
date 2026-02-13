// 💬 KLAN SOHBET - Domain Entity

import 'package:cloud_firestore/cloud_firestore.dart';

class ClanMessage {
  final String id;
  final String clanId;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final String? userAvatarEmoji;
  final String message;
  final DateTime timestamp;
  final List<String> reactions; // 👍, ❤️, 😂, vs.

  const ClanMessage({
    required this.id,
    required this.clanId,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    this.userAvatarEmoji,
    required this.message,
    required this.timestamp,
    this.reactions = const [],
  });

  factory ClanMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ClanMessage(
      id: doc.id,
      clanId: data['clanId'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Kullanıcı',
      userPhotoUrl: data['userPhotoUrl'],
      userAvatarEmoji: data['userAvatarEmoji'],
      message: data['message'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      reactions: List<String>.from(data['reactions'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'clanId': clanId,
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'userAvatarEmoji': userAvatarEmoji,
      'message': message,
      'timestamp': Timestamp.fromDate(timestamp),
      'reactions': reactions,
    };
  }

  ClanMessage copyWith({
    String? id,
    String? clanId,
    String? userId,
    String? userName,
    String? userPhotoUrl,
    String? userAvatarEmoji,
    String? message,
    DateTime? timestamp,
    List<String>? reactions,
  }) {
    return ClanMessage(
      id: id ?? this.id,
      clanId: clanId ?? this.clanId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      userAvatarEmoji: userAvatarEmoji ?? this.userAvatarEmoji,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      reactions: reactions ?? this.reactions,
    );
  }
}
