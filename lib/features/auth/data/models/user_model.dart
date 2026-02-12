// 👤 User Model (Data Layer - JSON Serialization)

import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.uid,
    required super.email,
    super.displayName,
    super.photoUrl,
    required super.createdAt,
    super.lastLogin,
    super.totalGamesCreated,
    super.totalGamesPlayed,
    super.averageRating,
  });

  // ✨ JSON'dan Model'e
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLogin: json['lastLogin'] != null 
          ? DateTime.parse(json['lastLogin'] as String) 
          : null,
      totalGamesCreated: json['totalGamesCreated'] as int? ?? 0,
      totalGamesPlayed: json['totalGamesPlayed'] as int? ?? 0,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
    );
  }

  // Model'den JSON'a
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
      'totalGamesCreated': totalGamesCreated,
      'totalGamesPlayed': totalGamesPlayed,
      'averageRating': averageRating,
    };
  }

  // Firebase Document'ten Model'e
  factory UserModel.fromFirestore(Map<String, dynamic> doc) {
    return UserModel.fromJson(doc);
  }
}
