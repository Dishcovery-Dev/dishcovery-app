import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_preferences.dart';

class UserPreferencesService {
  final FirebaseFirestore _db;
  UserPreferencesService({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _db.collection('user_preferences');

  Future<void> savePreferences({
    required String uid,
    required UserPreferences prefs,
  }) async {
    await _collection.doc(uid).set(prefs.toMap(), SetOptions(merge: true));
  }

  Future<UserPreferences> getPreferences({required String uid}) async {
    final doc = await _collection.doc(uid).get();
    if (!doc.exists || doc.data() == null) return const UserPreferences();
    return UserPreferences.fromMap(doc.data()!);
  }

  Future<bool> hasCompletedOnboarding({required String uid}) async {
    try {
      final doc = await _collection.doc(uid).get();
      
      // If document doesn't exist, create initial document and return false
      if (!doc.exists || doc.data() == null) {
        await _createInitialDocument(uid);
        return false;
      }

      final data = doc.data()!;
      // Check if user has completed onboarding by checking if preferences document exists
      // and has been explicitly set (not just default empty values)
      return data.containsKey('onboardingCompleted') &&
          data['onboardingCompleted'] == true;
    } catch (e) {
      // If there's an error (like permission denied), assume onboarding not completed
      // This prevents infinite loading and allows the app to continue
      return false;
    }
  }

  /// Creates initial document for new users
  Future<void> _createInitialDocument(String uid) async {
    try {
      await _collection.doc(uid).set({
        'onboardingCompleted': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Silently fail if we can't create the document
      // This prevents blocking the user flow
    }
  }

  Future<void> markOnboardingCompleted({required String uid}) async {
    await _collection.doc(uid).set({
      'onboardingCompleted': true,
    }, SetOptions(merge: true));
  }
}
