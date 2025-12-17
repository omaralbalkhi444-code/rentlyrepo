
import 'package:firebase_auth/firebase_auth.dart';

class CreateAccountLogic {
  final FirebaseAuth _auth;

  CreateAccountLogic({FirebaseAuth? auth}) 
      : _auth = auth ?? FirebaseAuth.instance;

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Please enter your email";
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return "Invalid email address";
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Please enter your password";
    }
    if (value.length < 6) {
      return "Password must be at least 6 characters";
    }
    return null;
  }

  Future<String?> createUserWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userCred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return userCred.user?.uid; 
    } on FirebaseAuthException catch (e) {
     
      return _getFirebaseErrorMessage(e);
    } catch (e) {
      return "An unexpected error occurred";
    }
  }

  String _getFirebaseErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return "This email address has been used before.";
      case 'invalid-email':
        return "Invalid email address.";
      case 'weak-password':
        return "Password must be at least 6 characters long.";
      case 'operation-not-allowed':
        return "Email/password accounts are not enabled.";
      default:
        return e.message ?? "Registration failed";
    }
  }

  static String extractUsername(String email) {
    return email.split("@")[0];
  }

  static bool isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }
}
