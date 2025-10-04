import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// A service class that handles Firebase authentication operations.
class FirebaseAuthService {
  static final FirebaseAuthService _instance = FirebaseAuthService._internal();
  
  /// Factory constructor that returns the singleton instance.
  factory FirebaseAuthService() => _instance;
  
  FirebaseAuthService._internal() {
    _initializeGoogleSignIn();
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _googleSignInInitialized = false;

  static const String _serverClientId = '222073084834-ocgjatr2d87br6osblqvildtnr04m3b1.apps.googleusercontent.com';

  /// Initializes the Google Sign-In service.
  /// 
  /// This method is called automatically when the service is instantiated.
  Future<void> _initializeGoogleSignIn() async {
    if (_googleSignInInitialized) return;

    try {
      debugPrint('🚀 FirebaseAuthService: Initializing Google Sign-In');

      await _googleSignIn.initialize(
        serverClientId: _serverClientId,
      );
      _googleSignInInitialized = true;
      debugPrint('✅ FirebaseAuthService: Google Sign-In initialized successfully');
    } catch (e) {
      debugPrint('❌ FirebaseAuthService: Failed to initialize Google Sign-In: $e');
    }
  }

  /// Returns the currently signed-in user.
  User? get currentUser => _auth.currentUser;

  /// Returns a stream of authentication state changes.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Returns whether a user is currently authenticated.
  bool get isAuthenticated => currentUser != null;

  /// Signs in a user with email and password.
  /// 
  /// Returns a [UserCredential] if successful.
  /// 
  /// Throws an exception with a user-friendly message if authentication fails.
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

  /// Registers a new user with email and password.
  /// 
  /// Optionally updates the user's display name if provided.
  /// 
  /// Returns a [UserCredential] if successful.
  /// 
  /// Throws an exception with a user-friendly message if registration fails.
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

  /// Sends a password reset email to the specified email address.
  /// 
  /// Throws an exception with a user-friendly message if the operation fails.
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Authenticates the user with Google Sign-In.
  /// 
  /// Returns a [UserCredential] containing the signed-in Firebase user.
  /// 
  /// Throws an exception with a user-friendly message if authentication fails.
  Future<UserCredential?> signInWithGoogle() async {
    try {
      if (!_googleSignInInitialized) await _initializeGoogleSignIn();
      if (!_googleSignIn.supportsAuthenticate()) {
        throw Exception('Google Sign-In is not supported on this platform');
      }

      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception('Failed to get ID token from Google Sign-In');
      }

      final credential = GoogleAuthProvider.credential(idToken: idToken);
      return await _auth.signInWithCredential(credential);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw Exception('Google sign-in was cancelled');
      }
      throw Exception('Google Sign-In failed: ${e.toString()}');
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      if (e.toString().contains('cancelled')) rethrow;
      throw Exception('Failed to sign in with Google: ${e.toString()}');
    }
  }
  
  /// Signs the current user out of the Google Sign-In session.
  /// 
  /// This method only revokes the Google OAuth tokens; the Firebase
  /// authentication session remains active. To sign out completely
  /// (Firebase + Google) use [signOut] instead.
  Future<void> signOutFromGoogle() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      if (kDebugMode) {
        print('Failed to sign out from Google: ${e.toString()}');
      }
    }
  }

  /// Signs out the current user from both Firebase and Google.
  /// 
  /// Throws an exception with a user-friendly message if the operation fails.
  Future<void> signOut() async {
    try {
      await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
    } catch (e) {
      throw Exception('Failed to sign out: ${e.toString()}');
    }
  }

  /// Deletes the current user's account.
  /// 
  /// Throws an exception with a user-friendly message if the operation fails.
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

  /// Updates the current user's profile information.
  /// 
  /// Throws an exception with a user-friendly message if the operation fails.
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

  /// Updates the current user's email address.
  /// 
  /// Sends a verification email to the new email address.
  /// 
  /// Throws an exception with a user-friendly message if the operation fails.
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

  /// Updates the current user's password.
  /// 
  /// Throws an exception with a user-friendly message if the operation fails.
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

  /// Sends an email verification to the current user.
  /// 
  /// Throws an exception with a user-friendly message if the operation fails.
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

  /// Reloads the current user to get updated information.
  /// 
  /// Any errors are logged in debug mode but not thrown.
  Future<void> reloadUser() async {
    try {
      await currentUser?.reload();
    } catch (e) {
      if (kDebugMode) {
        print('Failed to reload user: ${e.toString()}');
      }
    }
  }

  /// Handles Firebase Auth exceptions and returns user-friendly messages.
  /// 
  /// Takes a [FirebaseAuthException] and returns a user-friendly error message.
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

