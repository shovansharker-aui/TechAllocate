import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// The app now uses Employee ID + PIN instead of email/password.
  /// Firebase Anonymous Auth is used only as the backend authentication layer.
  Future<void> ensureAnonymousSignIn() async {
    if (_auth.currentUser == null) {
      await _auth.signInAnonymously();
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
