// lib/services/auth/auth_google.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthGoogle {
  // Scopes: E-posta erişimi için gerekli izinler
  static final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  static Future<User?> signIn(FirebaseAuth auth) async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final UserCredential userCredential = await auth.signInWithCredential(
      credential,
    );
    return userCredential.user;
  }

  static Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}
