import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Getter for the current logged-in user
  User? get currentUser => _firebaseAuth.currentUser;

  // Getter for the current user's UID
  String? get currentUserId => currentUser?.uid;

  AuthProvider() {
    // Listen to authentication state changes and notify listeners
    _firebaseAuth.authStateChanges().listen((User? user) {
      notifyListeners();
    });
  }

  // Method to handle user sign-up
  Future<void> signUp(String email, String password) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Automatically update the user state
      notifyListeners();
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  // Method to handle user sign-in
  Future<bool> signInWithEmailPassword(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Automatically update the user state
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Method to handle user sign-out
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      // Automatically update the user state
      notifyListeners();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }
}
