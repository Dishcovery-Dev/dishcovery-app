import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dishcovery_app/core/models/scan_model.dart';
import 'package:dishcovery_app/core/services/firebase_storage_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Service for managing Firestore operations for scan results and feeds
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorageService _storageService = FirebaseStorageService();

  static const String _scansCollection = 'scans';

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Save scan result to Firestore (automatically public)
  Future<String?> saveScanResult(ScanResult scanResult) async {
    try {
      final user = currentUser;
      if (user == null) return null;

      // Upload image to Firebase Storage if it's a local path
      String? imageUrl = scanResult.imageUrl;
      if (scanResult.imagePath.isNotEmpty &&
          !scanResult.imagePath.startsWith('http')) {
        final uploadedUrl = await _storageService.uploadImage(
          scanResult.imagePath,
        );
        if (uploadedUrl != null) {
          imageUrl = uploadedUrl;
        }
      }

      final updatedResult = scanResult.copyWith(
        userId: user.uid,
        userEmail: user.email,
        userName: user.displayName ?? user.email?.split('@').first ?? 'User',
        imageUrl: imageUrl,
        isPublic: true,
        updatedAt: DateTime.now(),
      );

      final docRef = await _firestore
          .collection(_scansCollection)
          .add(updatedResult.toFirestore());

      return docRef.id;
    } catch (e) {
      print('Error saving scan result: $e');
      return null;
    }
  }

  /// Update scan result in Firestore
  Future<bool> updateScanResult(String docId, ScanResult scanResult) async {
    try {
      await _firestore
          .collection(_scansCollection)
          .doc(docId)
          .update(scanResult.toFirestore());
      return true;
    } catch (e) {
      print('Error updating scan result: $e');
      return false;
    }
  }

  /// Get user's scan history
  Stream<List<ScanResult>> getUserScans(String userId) {
    return _firestore
        .collection(_scansCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['firestoreId'] = doc.id;
            return ScanResult.fromJson(data);
          }).toList();
        });
  }

  /// Get public feeds (all public scans)
  Stream<List<ScanResult>> getPublicFeeds({int limit = 50}) {
    return _firestore
        .collection(_scansCollection)
        .where('isPublic', isEqualTo: true)
        .where('isFood', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['firestoreId'] = doc.id;
            return ScanResult.fromJson(data);
          }).toList();
        });
  }

  /// Search feeds by name
  Future<List<ScanResult>> searchFeeds(String query) async {
    try {
      final snapshot = await _firestore
          .collection(_scansCollection)
          .where('isPublic', isEqualTo: true)
          .where('isFood', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) {
            final data = doc.data();
            data['firestoreId'] = doc.id;
            return ScanResult.fromJson(data);
          })
          .where(
            (scan) =>
                scan.name.toLowerCase().contains(query.toLowerCase()) ||
                scan.tags.any(
                  (tag) => tag.toLowerCase().contains(query.toLowerCase()),
                ),
          )
          .toList();
    } catch (e) {
      print('Error searching feeds: $e');
      return [];
    }
  }

  /// Delete scan result
  Future<bool> deleteScanResult(String docId) async {
    try {
      // Get the scan to retrieve the image URL
      final doc = await _firestore
          .collection(_scansCollection)
          .doc(docId)
          .get();
      if (doc.exists) {
        final data = doc.data()!;
        final imageUrl = data['imageUrl'] as String?;

        // Delete image from Firebase Storage if it exists
        if (imageUrl != null) {
          await _storageService.deleteImage(imageUrl);
        }
      }

      // Delete the document from Firestore
      await _firestore.collection(_scansCollection).doc(docId).delete();
      return true;
    } catch (e) {
      print('Error deleting scan result: $e');
      return false;
    }
  }

  /// Get single scan by ID
  Future<ScanResult?> getScanById(String docId) async {
    try {
      final doc = await _firestore
          .collection(_scansCollection)
          .doc(docId)
          .get();
      if (doc.exists) {
        final data = doc.data()!;
        data['firestoreId'] = doc.id;
        return ScanResult.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error getting scan by ID: $e');
      return null;
    }
  }

  /// Batch save scan results (for migration)
  Future<void> batchSaveScanResults(List<ScanResult> scans) async {
    final batch = _firestore.batch();
    final user = currentUser;
    if (user == null) return;

    for (final scan in scans) {
      final docRef = _firestore.collection(_scansCollection).doc();
      final updatedScan = scan.copyWith(
        userId: user.uid,
        userEmail: user.email,
        userName: user.displayName ?? user.email?.split('@').first ?? 'User',
        isPublic: true,
        updatedAt: DateTime.now(),
      );
      batch.set(docRef, updatedScan.toFirestore());
    }

    await batch.commit();
  }
}
