import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SurveyService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static CollectionReference get _surveysRef =>
      _db.collection('tools').doc('surveyHub').collection(_auth.currentUser?.uid ?? 'anonymous');

  static CollectionReference _responsesRef(String surveyId) =>
      _db.collection('tools').doc('surveyResponses').collection(surveyId);

  static Future<String> saveSurvey(Map<String, dynamic> surveyData, {String? id}) async {
    if (id != null) {
      await _surveysRef.doc(id).set(surveyData);
      return id;
    } else {
      final doc = await _surveysRef.add(surveyData);
      return doc.id;
    }
  }

  static Stream<QuerySnapshot> getMySurveys() {
    return _surveysRef.orderBy('createdAt', descending: true).snapshots();
  }

  static Future<void> deleteSurvey(String id) async {
    await _surveysRef.doc(id).delete();
  }

  static Future<DocumentSnapshot> getSurvey(String surveyId, String userId) async {
    return await _db.collection('tools').doc('surveyHub').collection(userId).doc(surveyId).get();
  }

  static Future<void> submitResponse(String surveyId, List<Map<String, dynamic>> answers) async {
    await _responsesRef(surveyId).add({
      'surveyId': surveyId,
      'answers': answers,
      'submittedAt': DateTime.now().toIso8601String(),
      'userId': _auth.currentUser?.uid ?? 'anonymous',
    });
  }

  static Stream<QuerySnapshot> getResponses(String surveyId) {
    return _responsesRef(surveyId).orderBy('submittedAt', descending: true).snapshots();
  }
}
