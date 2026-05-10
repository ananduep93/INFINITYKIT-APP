import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'firestore_service.dart';
import 'tool_data_service.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final FirestoreService _firestore = FirestoreService();

  User? _user;
  User? get user => _user;
  bool _initialized = false;
  bool get initialized => _initialized;

  AuthService() {
    _initialize();
    _auth.authStateChanges().listen((User? user) async {
      _user = user;
      if (user != null) {
        await _syncWithFirestore();
      }
      _initialized = true;
      notifyListeners();
    });
  }

  Future<void> _syncWithFirestore() async {
    try {
      await _firestore.syncUserData();
      
      // Sync centralized settings (favorites, recent tools)
      await ToolDataService.syncSettingsFromCloud();
      
      debugPrint('Firestore settings sync completed for ${user?.uid}');
    } catch (e) {
      debugPrint('Firestore sync error: $e');
    }
  }

  Future<void> _initialize() async {
    await _googleSignIn.initialize();
  }

  // Google Sign In
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.authenticate();
      
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final AuthCredential authCredential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        // In 2026, accessToken is obtained via authorizationClient if needed, 
        // but for Firebase Auth idToken is usually sufficient.
      );

      UserCredential userCredential = await _auth.signInWithCredential(authCredential);
      await _syncWithFirestore();
      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        debugPrint('Account exists with different credential. Consider linking.');
        // This is where you would prompt for password to link accounts
      }
      debugPrint('Google Sign-In Error: $e');
      return null;
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
      return null;
    }
  }

  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      await _syncWithFirestore();
      return credential;
    } catch (e) {
      debugPrint('Email Sign-In Error: $e');
      rethrow;
    }
  }

  Future<UserCredential?> signUpWithEmail(String email, String password, String name) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      await credential.user?.updateDisplayName(name);
      await _syncWithFirestore();
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
