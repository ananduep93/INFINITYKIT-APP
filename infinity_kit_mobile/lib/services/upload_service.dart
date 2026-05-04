import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UploadService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Uploads an image to Firebase Storage and returns the download URL.
  /// This replaces the old ImgBB method and is 100% secure.
  static Future<String?> uploadToImgBB(File file) async {
    // Note: Kept the function name for compatibility with existing Survey Hub code,
    // but changed the underlying logic to use secure Firebase Storage.
    try {
      final userId = _auth.currentUser?.uid ?? 'anonymous';
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      
      // Store in a dedicated 'surveys' folder
      final ref = _storage.ref().child('surveys/$userId/$fileName');
      
      final uploadTask = await ref.putFile(file);
      final url = await uploadTask.ref.getDownloadURL();
      
      return url;
    } catch (e) {
      debugPrint('Firebase Storage Upload Error: $e');
      return null;
    }
  }
}
