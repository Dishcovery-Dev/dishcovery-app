import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Service class for handling Firebase Authentication operations
class FirebaseAuthService {
  static final FirebaseAuthService _instance = FirebaseAuthService._internal();
  factory FirebaseAuthService() => _instance;
  FirebaseAuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Get authentication state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  /// Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Register with email and password
  Future<UserCredential?> registerWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name if provided
      if (displayName != null && displayName.isNotEmpty) {
        await credential.user?.updateDisplayName(displayName);
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    debugPrint('🚀 FirebaseAuthService: Starting Google Sign-In flow');
    debugPrint('🚀 FirebaseAuthService: Current Firebase user: ${_auth.currentUser?.email ?? 'null'}');
    debugPrint('🚀 FirebaseAuthService: GoogleSignIn instance initialized: ${_googleSignIn.toString()}');
    
    try {
      // Trigger the Google Sign-In flow
      debugPrint('🚀 FirebaseAuthService: Triggering Google Sign-In dialog');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      debugPrint('🚀 FirebaseAuthService: Google Sign-In dialog completed');

      if (googleUser == null) {
        // User canceled the sign-in
        debugPrint('❌ FirebaseAuthService: User cancelled Google Sign-In');
        throw Exception('Google sign-in was cancelled');
      }

      debugPrint('✅ FirebaseAuthService: Google user obtained: ${googleUser.email}');
      debugPrint('🚀 FirebaseAuthService: Google user display name: ${googleUser.displayName}');
      debugPrint('🚀 FirebaseAuthService: Google user ID: ${googleUser.id}');

      // Obtain the auth details from the request
      debugPrint('🚀 FirebaseAuthService: Obtaining Google authentication details');
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      debugPrint('✅ FirebaseAuthService: Google authentication details obtained');
      debugPrint('🚀 FirebaseAuthService: Access token available: ${googleAuth.accessToken != null}');
      debugPrint('🚀 FirebaseAuthService: ID token available: ${googleAuth.idToken != null}');

      // Create a new credential
      debugPrint('🚀 FirebaseAuthService: Creating Firebase credential from Google tokens');
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      debugPrint('✅ FirebaseAuthService: Firebase credential created successfully');

      // Sign in to Firebase with the Google credential
      debugPrint('🚀 FirebaseAuthService: Signing in to Firebase with Google credential');
      final userCredential = await _auth.signInWithCredential(credential);
      debugPrint('✅ FirebaseAuthService: Firebase sign-in completed successfully');
      debugPrint('🚀 FirebaseAuthService: Firebase user: ${userCredential.user?.email ?? 'null'}');
      debugPrint('🚀 FirebaseAuthService: Firebase user UID: ${userCredential.user?.uid ?? 'null'}');
      debugPrint('🚀 FirebaseAuthService: Firebase user display name: ${userCredential.user?.displayName ?? 'null'}');
      debugPrint('🚀 FirebaseAuthService: Firebase user email verified: ${userCredential.user?.emailVerified ?? false}');
      
      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ FirebaseAuthService: FirebaseAuthException occurred');
      debugPrint('❌ FirebaseAuthService: Error code: ${e.code}');
      debugPrint('❌ FirebaseAuthService: Error message: ${e.message}');
      debugPrint('❌ FirebaseAuthService: Error details: ${e.toString()}');
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('❌ FirebaseAuthService: General exception occurred');
      debugPrint('❌ FirebaseAuthService: Exception type: ${e.runtimeType}');
      debugPrint('❌ FirebaseAuthService: Exception message: ${e.toString()}');
      
      if (e.toString().contains('cancelled')) {
        debugPrint('❌ FirebaseAuthService: Re-throwing cancellation exception');
        rethrow;
      }
      throw Exception('Failed to sign in with Google: ${e.toString()}');
    }
  }

  /// Sign out from Google
  Future<void> signOutFromGoogle() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      if (kDebugMode) {
        print('Failed to sign out from Google: ${e.toString()}');
      }
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
    } catch (e) {
      throw Exception('Failed to sign out: ${e.toString()}');
    }
  }

  /// Delete current user account
  Future<void> deleteAccount() async {
    try {
      final user = currentUser;
      if (user != null) {
        await user.delete();
      } else {
        throw Exception('No user is currently signed in');
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Update user profile
  Future<void> updateProfile({String? displayName, String? photoURL}) async {
    try {
      final user = currentUser;
      if (user != null) {
        await user.updateDisplayName(displayName);
        await user.updatePhotoURL(photoURL);
      } else {
        throw Exception('No user is currently signed in');
      }
    } catch (e) {
      throw Exception('Failed to update profile: ${e.toString()}');
    }
  }

  /// Update user email
  Future<void> updateEmail({required String newEmail}) async {
    try {
      final user = currentUser;
      if (user != null) {
        await user.verifyBeforeUpdateEmail(newEmail);
      } else {
        throw Exception('No user is currently signed in');
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Update user password
  Future<void> updatePassword({required String newPassword}) async {
    try {
      final user = currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);
      } else {
        throw Exception('No user is currently signed in');
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Send email verification
  Future<void> sendEmailVerification() async {
    try {
      final user = currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      } else if (user == null) {
        throw Exception('No user is currently signed in');
      } else {
        throw Exception('Email is already verified');
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Reload current user to get updated information
  Future<void> reloadUser() async {
    try {
      await currentUser?.reload();
    } catch (e) {
      if (kDebugMode) {
        print('Failed to reload user: ${e.toString()}');
      }
    }
  }

  /// Handle Firebase Auth exceptions and return user-friendly messages
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed. Please contact support.';
      case 'invalid-credential':
        return 'Invalid credentials. Please check your email and password.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with a different sign-in method.';
      case 'requires-recent-login':
        return 'This operation requires recent authentication. Please sign in again.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      default:
        return e.message ??
            'An authentication error occurred. Please try again.';
    }
  }
}
