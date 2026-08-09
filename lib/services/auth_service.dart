import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/constants.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String displayName,
    String businessName = '',
    String websiteUrl = '',
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await credential.user?.updateDisplayName(displayName);

    // Determine role based on email
    final role = email.toLowerCase() == AppConstants.adminEmail.toLowerCase()
        ? 'admin'
        : 'client';

    // Create user document in Firestore
    final userModel = UserModel(
      uid: credential.user!.uid,
      email: email,
      displayName: displayName,
      businessName: businessName,
      websiteUrl: websiteUrl,
      role: role,
      createdAt: DateTime.now(),
    );

    await _firestore
        .collection('users')
        .doc(credential.user!.uid)
        .set(userModel.toMap());

    // Send email verification
    await credential.user?.sendEmailVerification();

    return credential;
  }

  // Sign in with email and password
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Send email verification
  Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.sendEmailVerification();
        print('Verification email sent to ${user.email}');
      } else {
        print('No user logged in to send verification email');
      }
    } catch (e) {
      print('Error sending verification email: $e');
      rethrow;
    }
  }

  // Check if email is verified
  Future<bool> isEmailVerified() async {
    await _auth.currentUser?.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Get user model from Firestore
  Future<UserModel?> getUserModel(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!);
    }
    return null;
  }

  // Update user profile
  Future<void> updateUserProfile(UserModel user) async {
    await _firestore.collection('users').doc(user.uid).update(user.toMap());
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Delete account
  Future<void> deleteAccount() async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      await _firestore.collection('users').doc(uid).delete();
    }
    await _auth.currentUser?.delete();
  }
}
