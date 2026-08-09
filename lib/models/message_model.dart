import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String requestId;
  final String senderId;
  final String senderName;
  final String senderRole;
  final String content;
  final DateTime createdAt;
  final List<String> attachments;

  MessageModel({
    required this.id,
    required this.requestId,
    required this.senderId,
    required this.senderName,
    this.senderRole = 'client',
    required this.content,
    DateTime? createdAt,
    this.attachments = const [],
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'requestId': requestId,
      'senderId': senderId,
      'senderName': senderName,
      'senderRole': senderRole,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      'attachments': attachments,
    };
  }

  factory MessageModel.fromMap(String id, Map<String, dynamic> map) {
    return MessageModel(
      id: id,
      requestId: map['requestId'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      senderRole: map['senderRole'] ?? 'client',
      content: map['content'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      attachments: List<String>.from(map['attachments'] ?? []),
    );
  }
}
