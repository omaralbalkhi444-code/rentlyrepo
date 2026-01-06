import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class LoginLogic {
  final FirebaseAuth _auth;
  final FirebaseDatabase _database;

  LoginLogic({
    FirebaseAuth? auth,
    FirebaseDatabase? database,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _database = database ?? FirebaseDatabase.instance;

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Please enter your email";
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return "Enter a valid email";
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

  Future<void> loginUser({
    required String email,
    required String password,
    required Function(String) onSuccess,
    required Function(String) onError,
  }) async {
    try {
      // 🔹 1. Firebase Auth (الأساس)
      UserCredential userCred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      User? user = userCred.user;
      if (user == null) {
        onError("User not found");
        return;
      }

      // ✅ 2. نعتبر الدخول ناجح فورًا
      onSuccess(user.uid);

      // 🔹 3. Realtime Database (يعمل بالخلفية – بدون تعطيل)
      final userRef = _database.ref("users/${user.uid}");

      userRef.update({
        "name": user.email!.split("@")[0],
        "email": user.email,
        "status": "online",
        "lastSeen": ServerValue.timestamp,
      }).catchError((e) {
        print("Realtime DB update error: $e");
      });

      userRef.onDisconnect().update({
        "status": "offline",
        "lastSeen": ServerValue.timestamp,
      });

    } on FirebaseAuthException catch (e) {
      onError(e.message ?? "Login failed");
    } catch (e) {
      onError("An unexpected error occurred");
    }
  }

  static String extractUsername(String email) {
    return email.split("@")[0];
  }

  bool isUserLoggedIn() {
    return _auth.currentUser != null;
  }

  Future<void> logout() async {
    if (_auth.currentUser != null) {
      final userRef = _database.ref("users/${_auth.currentUser!.uid}");
      await userRef.update({
        "status": "offline",
        "lastSeen": ServerValue.timestamp,
      });
    }
    await _auth.signOut();
  }
}
