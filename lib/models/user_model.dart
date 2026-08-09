import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String businessName;
  final String websiteUrl;
  final String role; // 'client' or 'admin'
  final DateTime createdAt;
  final bool requestUpdates;
  final bool studioUpdates;
  final String? photoUrl;
  final bool isWebsiteVerified;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.businessName = '',
    this.websiteUrl = '',
    this.role = 'client',
    DateTime? createdAt,
    this.requestUpdates = true,
    this.studioUpdates = true,
    this.photoUrl,
    this.isWebsiteVerified = false,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isAdmin => role == 'admin';

  String get initials {
    final parts = displayName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return 'U';
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'businessName': businessName,
      'websiteUrl': websiteUrl,
      'role': role,
      'createdAt': Timestamp.fromDate(createdAt),
      'requestUpdates': requestUpdates,
      'studioUpdates': studioUpdates,
      'photoUrl': photoUrl,
      'isWebsiteVerified': isWebsiteVerified,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      businessName: map['businessName'] ?? '',
      websiteUrl: map['websiteUrl'] ?? '',
      role: map['role'] ?? 'client',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      requestUpdates: map['requestUpdates'] ?? true,
      studioUpdates: map['studioUpdates'] ?? true,
      photoUrl: map['photoUrl'],
      isWebsiteVerified: map['isWebsiteVerified'] ?? false,
    );
  }

  UserModel copyWith({
    String? displayName,
    String? businessName,
    String? websiteUrl,
    String? role,
    bool? requestUpdates,
    bool? studioUpdates,
    String? photoUrl,
    bool? isWebsiteVerified,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      businessName: businessName ?? this.businessName,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      role: role ?? this.role,
      createdAt: createdAt,
      requestUpdates: requestUpdates ?? this.requestUpdates,
      studioUpdates: studioUpdates ?? this.studioUpdates,
      photoUrl: photoUrl ?? this.photoUrl,
      isWebsiteVerified: isWebsiteVerified ?? this.isWebsiteVerified,
    );
  }
}
