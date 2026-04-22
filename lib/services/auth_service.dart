// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Current user
  User? get currentUser => _auth.currentUser;

  // Sign Up
  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      await credential.user?.updateDisplayName(displayName);

      final userModel = UserModel(
        uid: credential.user!.uid,
        email: email.trim(),
        displayName: displayName,
        createdAt: DateTime.now(),
        totalDistance: 0,
        streak: 1,
        totalWorkouts: 0,
        totalCalories: 0,
      );

      await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .set(userModel.toMap());

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseError(e.code);
    }
  }

  // Sign In
  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final doc = await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .get();

      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseError(e.code);
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get User Profile
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) return UserModel.fromMap(doc.data()!);
      return null;
    } catch (e) {
      return null;
    }
  }

  // Update User Profile
  Future<void> updateUserProfile(UserModel user) async {
    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .update(user.toMap());
    } catch (e) {
      throw 'Failed to update profile. Please try again.';
    }
  }

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
