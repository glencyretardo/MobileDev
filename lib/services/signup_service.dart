import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:habify_3/screens/loginPage.dart'; // Import LoginPage for redirection

class SignupService {
  static Future<void> signUp({
    required String email,
    required String password,
    required String username, // Keep the username
    required String birthday, // Keep the birthday
    required BuildContext context,
  }) async {
    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Password must be at least 6 characters long')),
      );
      return;
    }

    try {
      // Create user with Firebase Auth
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Sign-up successful! Redirecting to login...')),
      );

      // Redirect to login after a short delay
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      });
    } on FirebaseAuthException catch (e) {
      // Handle FirebaseAuth-specific errors
      String errorMessage;
      if (e.code == 'email-already-in-use') {
        errorMessage = 'This email is already in use.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Invalid email address.';
      } else {
        errorMessage = 'Sign-up failed. Please try again.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      // Handle general errors
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('An unexpected error occurred. Please try again.')),
      );
    }
  }
}
