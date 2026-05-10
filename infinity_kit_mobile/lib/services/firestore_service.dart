import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Paths
  DocumentReference get userDoc => _db.collection('users').doc(_auth.currentUser?.uid);
  CollectionReference get favoritesColl => userDoc.collection('favorites');
  CollectionReference get historyColl => userDoc.collection('history');
  CollectionReference get toolsColl => userDoc.collection('tools');
  DocumentReference get profileDoc => userDoc.collection('profile').doc('info');

  // Generic Tool Data Sync (Matching Web structure)
  Future<void> saveToolData(String toolName, dynamic data) async {
    if (_auth.currentUser == null) return;
    await toolsColl.doc(toolName).set({
      'data': data,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<dynamic> getToolData(String toolName) async {
    if (_auth.currentUser == null) return null;
    final doc = await toolsColl.doc(toolName).get();
    if (!doc.exists) return null;
    final data = doc.data() as Map<String, dynamic>?;
    return data?['data'];
  }

  Stream<DocumentSnapshot> getToolDataStream(String toolName) {
    return toolsColl.doc(toolName).snapshots();
  }

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

  Future<List<String>> getHistory() async {
    if (_auth.currentUser == null) return [];
    final snapshot = await historyColl.orderBy('lastAccessed', descending: true).limit(20).get();
    return snapshot.docs.map((doc) => doc.id).toList();
  }

  // App Settings Sync (Matching Web's infinityKitSettings)
  Future<Map<String, dynamic>?> getSettings() async {
    final data = await getToolData('infinityKitSettings');
    return (data is Map) ? Map<String, dynamic>.from(data) : null;
  }

  Future<void> saveSettings(Map<String, dynamic> settings) async {
    await saveToolData('infinityKitSettings', settings);
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
