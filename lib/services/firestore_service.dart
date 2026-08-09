import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/request_model.dart';
import '../models/message_model.dart';
import '../models/user_model.dart';
import '../config/constants.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== REQUESTS ====================

  // Create a new request
  Future<RequestModel> createRequest({
    required String userId,
    required String userEmail,
    required String userName,
    required String title,
    required String description,
    required String category,
    required String priority,
    List<String> attachments = const [],
  }) async {
    // Generate request number
    final requestNumber = await _generateRequestNumber();

    final docRef = _firestore.collection('requests').doc();
    final request = RequestModel(
      id: docRef.id,
      requestNumber: requestNumber,
      userId: userId,
      userEmail: userEmail,
      userName: userName,
      title: title,
      description: description,
      category: category,
      priority: priority,
      status: 'new',
      attachments: attachments,
    );

    await docRef.set(request.toMap());
    return request;
  }

  // Generate unique request number
  Future<String> _generateRequestNumber() async {
    final snapshot = await _firestore
        .collection('requests')
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();

    int nextNumber = 1001;
    if (snapshot.docs.isNotEmpty) {
      final lastNumber = snapshot.docs.first.data()['requestNumber'] as String?;
      if (lastNumber != null && lastNumber.startsWith('${AppConstants.requestPrefix}-')) {
        final num = int.tryParse(lastNumber.split('-').last);
        if (num != null) nextNumber = num + 1;
      }
    }
    return '${AppConstants.requestPrefix}-$nextNumber';
  }

  // Get requests for a specific user (client)
  Stream<List<RequestModel>> getUserRequests(String userId) {
    return _firestore
        .collection('requests')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RequestModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  // Get all requests (admin)
  Stream<List<RequestModel>> getAllRequests() {
    return _firestore
        .collection('requests')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RequestModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  // Get single request
  Stream<RequestModel?> getRequest(String requestId) {
    return _firestore
        .collection('requests')
        .doc(requestId)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return RequestModel.fromMap(doc.id, doc.data()!);
      }
      return null;
    });
  }

  // Update request status
  Future<void> updateRequestStatus(String requestId, String status) async {
    await _firestore.collection('requests').doc(requestId).update({
      'status': status,
      'updatedAt': Timestamp.now(),
    });
  }

  // Update request priority
  Future<void> updateRequestPriority(String requestId, String priority) async {
    await _firestore.collection('requests').doc(requestId).update({
      'priority': priority,
      'updatedAt': Timestamp.now(),
    });
  }

  // Delete request
  Future<void> deleteRequest(String requestId) async {
    // Delete all messages for this request
    final messages = await _firestore
        .collection('messages')
        .where('requestId', isEqualTo: requestId)
        .get();
    for (var doc in messages.docs) {
      await doc.reference.delete();
    }
    await _firestore.collection('requests').doc(requestId).delete();
  }

  // ==================== MESSAGES ====================

  // Send a message
  Future<MessageModel> sendMessage({
    required String requestId,
    required String senderId,
    required String senderName,
    required String senderRole,
    required String content,
    List<String> attachments = const [],
  }) async {
    final docRef = _firestore.collection('messages').doc();
    final message = MessageModel(
      id: docRef.id,
      requestId: requestId,
      senderId: senderId,
      senderName: senderName,
      senderRole: senderRole,
      content: content,
      attachments: attachments,
    );

    await docRef.set(message.toMap());

    // Update request's updatedAt timestamp
    await _firestore.collection('requests').doc(requestId).update({
      'updatedAt': Timestamp.now(),
    });

    return message;
  }

  // Get messages for a request
  Stream<List<MessageModel>> getMessages(String requestId) {
    return _firestore
        .collection('messages')
        .where('requestId', isEqualTo: requestId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  // ==================== USERS (Admin) ====================

  // Get all clients
  Stream<List<UserModel>> getAllClients() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'client')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromMap(doc.data()))
            .toList());
  }

  // Get user by ID
  Future<UserModel?> getUser(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!);
    }
    return null;
  }

  // Update website verification status
  Future<void> updateWebsiteVerification(String userId, bool isVerified) async {
    await _firestore.collection('users').doc(userId).update({
      'isWebsiteVerified': isVerified,
    });
  }

  // Get request stats for a user
  Future<Map<String, int>> getUserRequestStats(String userId) async {
    final snapshot = await _firestore
        .collection('requests')
        .where('userId', isEqualTo: userId)
        .get();

    int total = snapshot.docs.length;
    int resolved = 0;
    int waitingOnClient = 0;
    int inProgress = 0;
    int newCount = 0;

    for (var doc in snapshot.docs) {
      final status = doc.data()['status'] as String?;
      switch (status) {
        case 'resolved':
          resolved++;
          break;
        case 'waiting_on_client':
          waitingOnClient++;
          break;
        case 'in_progress':
          inProgress++;
          break;
        case 'new':
          newCount++;
          break;
      }
    }

    return {
      'total': total,
      'resolved': resolved,
      'waiting_on_client': waitingOnClient,
      'in_progress': inProgress,
      'new': newCount,
    };
  }

  // Get all request stats (admin)
  Future<Map<String, int>> getAllRequestStats() async {
    final snapshot = await _firestore.collection('requests').get();

    int total = snapshot.docs.length;
    int resolved = 0;
    int waitingOnClient = 0;
    int inProgress = 0;
    int newCount = 0;

    for (var doc in snapshot.docs) {
      final status = doc.data()['status'] as String?;
      switch (status) {
        case 'resolved':
          resolved++;
          break;
        case 'waiting_on_client':
          waitingOnClient++;
          break;
        case 'in_progress':
          inProgress++;
          break;
        case 'new':
          newCount++;
          break;
      }
    }

    return {
      'total': total,
      'resolved': resolved,
      'waiting_on_client': waitingOnClient,
      'in_progress': inProgress,
      'new': newCount,
    };
  }

  // ==================== DEMO DATA ====================

  Future<void> seedDemoData(String userId, String userEmail, String userName) async {
    if (!AppConstants.useDemoData) return;

    // Check if demo data already exists
    final existing = await _firestore
        .collection('requests')
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) return;

    final random = Random();
    final now = DateTime.now();

    final demoRequests = [
      {
        'title': 'Refresh the homepage hero section',
        'description':
            'We would like the first impression of our site to feel more editorial. Please update the hero copy and add the new spring campaign image.',
        'category': 'UI update',
        'priority': 'High',
        'status': 'in_progress',
        'createdAt': now.subtract(const Duration(days: 2)),
      },
      {
        'title': 'Add RSVP flow for the studio open house',
        'description':
            'Create an event page with date, location, RSVP form, and an automatic confirmation message.',
        'category': 'Event setup',
        'priority': 'Normal',
        'status': 'waiting_on_client',
        'createdAt': now.subtract(const Duration(days: 4)),
      },
      {
        'title': 'Fix broken gallery images on mobile',
        'description':
            'A handful of project images are not loading on the mobile version of the portfolio page. Need to investigate and fix.',
        'category': 'Bug fix',
        'priority': 'Urgent',
        'status': 'resolved',
        'createdAt': now.subtract(const Duration(days: 10)),
      },
    ];

    for (int i = 0; i < demoRequests.length; i++) {
      final data = demoRequests[i];
      final docRef = _firestore.collection('requests').doc();
      final request = RequestModel(
        id: docRef.id,
        requestNumber: '${AppConstants.requestPrefix}-${1048 - i * 6}',
        userId: userId,
        userEmail: userEmail,
        userName: userName,
        title: data['title'] as String,
        description: data['description'] as String,
        category: data['category'] as String,
        priority: data['priority'] as String,
        status: data['status'] as String,
        createdAt: data['createdAt'] as DateTime,
        updatedAt: (data['createdAt'] as DateTime).add(Duration(days: random.nextInt(2) + 1)),
      );

      await docRef.set(request.toMap());

      // Add demo messages for the first request
      if (i == 0) {
        await sendMessage(
          requestId: docRef.id,
          senderId: 'demo_client',
          senderName: 'Maya Chen',
          senderRole: 'client',
          content:
              'The current hero feels a little dated next to our new brand direction.',
        );
        await Future.delayed(const Duration(milliseconds: 100));
        await sendMessage(
          requestId: docRef.id,
          senderId: 'demo_admin',
          senderName: 'Jordan Lee',
          senderRole: 'admin',
          content:
              'Got it. I have a first pass in progress and will share a preview tomorrow.',
        );
      }
    }
  }
}
