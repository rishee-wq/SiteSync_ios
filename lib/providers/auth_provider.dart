import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../config/constants.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  User? _firebaseUser;
  UserModel? _userModel;
  bool _isLoading = true;
  String? _error;
  Timer? _verificationTimer;

  bool _skipVerification = false;

  User? get firebaseUser => _firebaseUser;
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _firebaseUser != null;
  bool get isEmailVerified => (_firebaseUser?.emailVerified ?? false) || _skipVerification;
  bool get isAdmin => _userModel?.isAdmin ?? false;

  AuthProvider() {
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? user) async {
    try {
      _firebaseUser = user;
      if (user != null) {
        _userModel = await _authService.getUserModel(user.uid);
        // Seed demo data for new client users
        if (_userModel != null && !_userModel!.isAdmin && AppConstants.useDemoData) {
          await _firestoreService.seedDemoData(
            user.uid,
            user.email ?? '',
            _userModel!.displayName,
          );
        }
      } else {
        _userModel = null;
      }
    } catch (e) {
      debugPrint('Error in _onAuthStateChanged: $e');
      _error = 'Failed to load user profile. Please check your connection or Cloud Firestore settings.';
      _userModel = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
    String businessName = '',
    String websiteUrl = '',
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _authService.signUp(
        email: email,
        password: password,
        displayName: displayName,
        businessName: businessName,
        websiteUrl: websiteUrl,
      );
    } on FirebaseAuthException catch (e) {
      _error = _getErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      rethrow;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _authService.signIn(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      _error = _getErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      rethrow;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> sendEmailVerification() async {
    await _authService.sendEmailVerification();
  }

  Future<bool> checkEmailVerified() async {
    final verified = await _authService.isEmailVerified();
    if (verified) {
      _firebaseUser = _authService.currentUser;
      notifyListeners();
    }
    return verified;
  }

  void startVerificationCheck() {
    _verificationTimer?.cancel();
    _verificationTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => checkEmailVerified(),
    );
  }

  void stopVerificationCheck() {
    _verificationTimer?.cancel();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      _error = null;
      await _authService.sendPasswordResetEmail(email);
    } on FirebaseAuthException catch (e) {
      _error = _getErrorMessage(e.code);
      rethrow;
    }
  }

  Future<void> updateProfile({
    String? displayName,
    String? businessName,
    String? websiteUrl,
    bool? requestUpdates,
    bool? studioUpdates,
  }) async {
    if (_userModel == null) return;

    final updated = _userModel!.copyWith(
      displayName: displayName,
      businessName: businessName,
      websiteUrl: websiteUrl,
      requestUpdates: requestUpdates,
      studioUpdates: studioUpdates,
    );

    await _authService.updateUserProfile(updated);
    _userModel = updated;
    notifyListeners();
  }

  Future<void> signOut() async {
    stopVerificationCheck();
    await _authService.signOut();
    _userModel = null;
    _firebaseUser = null;
    notifyListeners();
  }

  void skipVerification() {
    _skipVerification = true;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak. Use at least 8 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'invalid-credential':
        return 'Invalid email or password. Please try again.';
      default:
        return 'An error occurred. Please try again.';
    }
  }

  @override
  void dispose() {
    _verificationTimer?.cancel();
    super.dispose();
  }
}
