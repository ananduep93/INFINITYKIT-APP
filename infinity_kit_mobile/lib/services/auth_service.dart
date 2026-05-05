import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  User? _user;
  User? get user => _user;
  bool _initialized = false;
  bool get initialized => _initialized;

  AuthService() {
    _initialize();
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      _initialized = true;
      notifyListeners();
    });
  }

  Future<void> _initialize() async {
    await _googleSignIn.initialize();
  }

  // Google Sign In
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.authenticate();
      
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        // In 2026, accessToken is obtained via authorizationClient if needed, 
        // but for Firebase Auth idToken is usually sufficient.
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
      return null;
    }
  }

  // Email & Password Sign In
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      debugPrint('Email Sign-In Error: $e');
      rethrow;
    }
  }

  // Email & Password Sign Up
  Future<UserCredential?> signUpWithEmail(String email, String password, String name) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      await credential.user?.updateDisplayName(name);
      return credential;
    } catch (e) {
      debugPrint('Email Sign-Up Error: $e');
      rethrow;
    }
  }

  // Password Reset
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      debugPrint('Password Reset Error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
