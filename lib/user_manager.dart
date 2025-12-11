import 'package:firebase_auth/firebase_auth.dart';

class UserManager {
  static String? get uid {
    final user = FirebaseAuth.instance.currentUser;
    return user?.uid;
  }
}
