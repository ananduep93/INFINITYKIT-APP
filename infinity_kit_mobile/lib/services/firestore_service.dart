import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Paths
  DocumentReference get userDoc => _db.collection('users').doc(_auth.currentUser?.uid);
  CollectionReference get favoritesColl => userDoc.collection('favorites');
  CollectionReference get historyColl => userDoc.collection('history');
  DocumentReference get profileDoc => userDoc.collection('profile').doc('info');

  // Initialize/Sync User Data
  Future<void> syncUserData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final doc = await userDoc.get();
    if (!doc.exists) {
      // Create initial user document
      await userDoc.set({
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'photoURL': user.photoURL,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
      });
      
      // Create initial profile
      await profileDoc.set({
        'name': user.displayName ?? '',
        'email': user.email ?? '',
        'bio': '',
        'joinedAt': FieldValue.serverTimestamp(),
      });
    } else {
      // Update last login
      await userDoc.update({
        'lastLogin': FieldValue.serverTimestamp(),
      });
    }
  }

  // Favorites
  Future<void> saveFavorite(String toolId, bool isFavorite) async {
    if (_auth.currentUser == null) return;
    if (isFavorite) {
      await favoritesColl.doc(toolId).set({
        'toolId': toolId,
        'savedAt': FieldValue.serverTimestamp(),
      });
    } else {
      await favoritesColl.doc(toolId).delete();
    }
  }

  Future<List<String>> getFavorites() async {
    if (_auth.currentUser == null) return [];
    final snapshot = await favoritesColl.get();
    return snapshot.docs.map((doc) => doc.id).toList();
  }

  // History
  Future<void> addToHistory(String toolId) async {
    if (_auth.currentUser == null) return;
    await historyColl.doc(toolId).set({
      'toolId': toolId,
      'lastAccessed': FieldValue.serverTimestamp(),
    });
  }

  Future<List<String>> getHistory() async {
    if (_auth.currentUser == null) return [];
    final snapshot = await historyColl.orderBy('lastAccessed', descending: true).limit(20).get();
    return snapshot.docs.map((doc) => doc.id).toList();
  }

  // Profile
  Future<Map<String, dynamic>?> getProfile() async {
    if (_auth.currentUser == null) return null;
    final doc = await profileDoc.get();
    return doc.data() as Map<String, dynamic>?;
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    if (_auth.currentUser == null) return;
    await profileDoc.set(data, SetOptions(merge: true));
  }
}
