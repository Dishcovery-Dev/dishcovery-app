import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart' as path;

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Upload image to Firebase Storage
  Future<String?> uploadImage(String imagePath, {String? folder}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final file = File(imagePath);
      if (!file.existsSync()) return null;

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${user.uid}_$timestamp${path.extension(imagePath)}';

      // Define storage path
      final storagePath = folder != null
          ? '$folder/${user.uid}/$fileName'
          : 'scans/${user.uid}/$fileName';

      // Upload file
      final ref = _storage.ref().child(storagePath);
      final uploadTask = ref.putFile(file);

      // Wait for upload to complete
      final snapshot = await uploadTask;

      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();

      print('Image uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // Upload image from bytes (for camera captures)
  Future<String?> uploadImageBytes(
    List<int> imageBytes, {
    String? folder,
    String? extension = '.jpg',
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${user.uid}_$timestamp$extension';

      // Define storage path
      final storagePath = folder != null
          ? '$folder/${user.uid}/$fileName'
          : 'scans/${user.uid}/$fileName';

      // Upload bytes
      final ref = _storage.ref().child(storagePath);
      final uploadTask = ref.putData(
        Uint8List.fromList(imageBytes),
        SettableMetadata(contentType: 'image/jpeg'),
      );

      // Wait for upload to complete
      final snapshot = await uploadTask;

      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();

      print('Image uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('Error uploading image bytes: $e');
      return null;
    }
  }

  // Delete image from Firebase Storage
  Future<bool> deleteImage(String imageUrl) async {
    try {
      // Check if it's a Firebase Storage URL
      if (!imageUrl.contains('firebasestorage.googleapis.com')) {
        return true; // Not a Firebase Storage URL, nothing to delete
      }

      // Get reference from URL
      final ref = _storage.refFromURL(imageUrl);

      // Delete the file
      await ref.delete();

      print('Image deleted successfully: $imageUrl');
      return true;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }

  // Delete all images for a user (used when deleting account)
  Future<bool> deleteUserImages() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // List all files in user's scan folder
      final ref = _storage.ref().child('scans/${user.uid}');
      final result = await ref.listAll();

      // Delete all files
      for (final fileRef in result.items) {
        await fileRef.delete();
      }

      print('All user images deleted successfully');
      return true;
    } catch (e) {
      print('Error deleting user images: $e');
      return false;
    }
  }

  // Get storage usage for current user
  Future<int> getUserStorageUsage() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 0;

      int totalSize = 0;

      // List all files in user's scan folder
      final ref = _storage.ref().child('scans/${user.uid}');
      final result = await ref.listAll();

      // Calculate total size
      for (final fileRef in result.items) {
        final metadata = await fileRef.getMetadata();
        totalSize += metadata.size ?? 0;
      }

      return totalSize;
    } catch (e) {
      print('Error getting storage usage: $e');
      return 0;
    }
  }

  // Validate image file
  bool isValidImageFile(String filePath) {
    final validExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
    final extension = path.extension(filePath).toLowerCase();
    return validExtensions.contains(extension);
  }

  // Compress image before upload (optional, requires image package)
  // This is a placeholder - actual implementation would need image compression library
  Future<File?> compressImage(File imageFile, {int quality = 85}) async {
    // For now, return the original file
    // In production, you'd use packages like image or flutter_image_compress
    return imageFile;
  }
}
