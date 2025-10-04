import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../core/models/user_preferences.dart';
import '../core/services/user_preferences_service.dart';
import '../providers/auth_provider.dart';

class UserPreferencesProvider extends ChangeNotifier {
  final UserPreferencesService _service;
  AuthProvider _auth;

  UserPreferences _prefs = const UserPreferences();
  bool _loading = false;
  String? _error;
  bool? _hasCompletedOnboarding;

  UserPreferencesProvider({
    required UserPreferencesService service,
    required AuthProvider auth,
  }) : _service = service,
       _auth = auth;

  UserPreferences get prefs => _prefs;
  bool get isLoading => _loading;
  String? get error => _error;
  bool? get hasCompletedOnboarding => _hasCompletedOnboarding;

  // Allow updating auth provider reference (needed for ProxyProvider)
  set auth(AuthProvider value) {
    _auth = value;
  }

  Future<void> load() async {
    final user = _auth.user;
    if (user == null) return;
    _loading = true;
    notifyListeners();
    try {
      _prefs = await _service.getPreferences(uid: user.uid);
      _hasCompletedOnboarding = await _service.hasCompletedOnboarding(
        uid: user.uid,
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> checkOnboardingStatus() async {
    final user = _auth.user;
    if (user == null) return;

    _loading = true;
    notifyListeners();

    try {
      _hasCompletedOnboarding = await _service.hasCompletedOnboarding(
        uid: user.uid,
      );
      _error = null;
    } catch (e) {
      // Handle Firestore permission errors gracefully
      if (e.toString().contains('PERMISSION_DENIED')) {
        _error =
            'Akses database ditolak. Pastikan aturan Firestore sudah dikonfigurasi dengan benar.';
        _hasCompletedOnboarding =
            false; // Assume onboarding not completed if we can't check
      } else {
        _error = e.toString();
        _hasCompletedOnboarding = false;
      }
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> save(UserPreferences prefs) async {
    final user = _auth.user;
    if (user == null) return;
    _loading = true;
    notifyListeners();
    try {
      await _service.savePreferences(uid: user.uid, prefs: prefs);
      await _service.markOnboardingCompleted(uid: user.uid);
      _prefs = prefs;
      _hasCompletedOnboarding = true;
      _error = null;
    } catch (e) {
      // Handle Firestore permission errors with user-friendly messages
      if (e.toString().contains('PERMISSION_DENIED')) {
        _error =
            'Gagal menyimpan preferensi: Akses database ditolak. Hubungi administrator.';
      } else if (e.toString().contains('network')) {
        _error = 'Gagal menyimpan preferensi: Periksa koneksi internet Anda.';
      } else {
        _error = 'Gagal menyimpan preferensi: ${e.toString()}';
      }
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> updateLocation() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      final req = await Geolocator.requestPermission();
      if (req == LocationPermission.denied ||
          req == LocationPermission.deniedForever) {
        _error = 'Izin lokasi ditolak';
        notifyListeners();
        return;
      }
    }

    final pos = await Geolocator.getCurrentPosition();
    _prefs = _prefs.copyWith(latitude: pos.latitude, longitude: pos.longitude);
    notifyListeners();
  }
}
