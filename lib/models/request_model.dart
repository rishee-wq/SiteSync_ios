import 'package:cloud_firestore/cloud_firestore.dart';

class RequestModel {
  final String id;
  final String requestNumber;
  final String userId;
  final String userEmail;
  final String userName;
  final String title;
  final String description;
  final String category;
  final String priority;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> attachments;

  RequestModel({
    required this.id,
    required this.requestNumber,
    required this.userId,
    required this.userEmail,
    required this.userName,
    required this.title,
    required this.description,
    this.category = 'Other',
    this.priority = 'Normal',
    this.status = 'new',
    DateTime? createdAt,
    DateTime? updatedAt,
    this.attachments = const [],
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'requestNumber': requestNumber,
      'userId': userId,
      'userEmail': userEmail,
      'userName': userName,
      'title': title,
      'description': description,
      'category': category,
      'priority': priority,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'attachments': attachments,
    };
  }

  factory RequestModel.fromMap(String id, Map<String, dynamic> map) {
    return RequestModel(
      id: id,
      requestNumber: map['requestNumber'] ?? '',
      userId: map['userId'] ?? '',
      userEmail: map['userEmail'] ?? '',
      userName: map['userName'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? 'Other',
      priority: map['priority'] ?? 'Normal',
      status: map['status'] ?? 'new',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      attachments: List<String>.from(map['attachments'] ?? []),
    );
  }

  RequestModel copyWith({
    String? title,
    String? description,
    String? category,
    String? priority,
    String? status,
    DateTime? updatedAt,
    List<String>? attachments,
  }) {
    return RequestModel(
      id: id,
      requestNumber: requestNumber,
      userId: userId,
      userEmail: userEmail,
      userName: userName,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      attachments: attachments ?? this.attachments,
    );
  }
}
