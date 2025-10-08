import 'dart:async';

import 'package:dishcovery_app/core/database/objectbox_database.dart';
import 'package:dishcovery_app/core/models/scan_model.dart';
import 'package:dishcovery_app/core/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Provider for managing scan history from Firestore and local cache
class HistoryProvider extends ChangeNotifier {
  final ObjectBoxDatabase _database;
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<ScanResult> _historyList = [];
  List<ScanResult> _favoritesList = [];
  StreamSubscription? _historySubscription;
  bool _isLoading = false;

  HistoryProvider(this._database) {
    _initializeHistory();
  }

  List<ScanResult> get historyList => _historyList;
  List<ScanResult> get favoritesList => _favoritesList;
  bool get isLoading => _isLoading;

  void _initializeHistory() {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        loadHistory();
        loadFavorites();
      } else {
        _historyList = [];
        _favoritesList = [];
        notifyListeners();
      }
    });
  }

  /// Load history from Firestore (online) or ObjectBox (offline)
  Future<void> loadHistory() async {
    final user = _auth.currentUser;
    if (user == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Cancel previous subscription
      await _historySubscription?.cancel();

      // Subscribe to Firestore updates
      _historySubscription = _firestoreService
          .getUserScans(user.uid)
          .listen(
            (scans) {
              _historyList = scans;
              _isLoading = false;
              notifyListeners();

              // Cache to ObjectBox for offline access
              _cacheScansToLocal(scans);
            },
            onError: (error) async {
              print('Error loading from Firestore, using local cache: $error');
              // Fallback to ObjectBox cache
              _historyList = await _database.getAllHistory();
              _isLoading = false;
              notifyListeners();
            },
          );
    } catch (e) {
      print('Error loading history: $e');
      // Fallback to ObjectBox cache
      _historyList = await _database.getAllHistory();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cache scans to ObjectBox
  Future<void> _cacheScansToLocal(List<ScanResult> scans) async {
    for (final scan in scans) {
      try {
        // Check if already exists in cache
        final existing = await _database.getAllHistory();
        final exists = existing.any((s) => s.firestoreId == scan.firestoreId);

        if (!exists) {
          await _database.insertScanResult(scan);
        } else {
          await _database.updateScanResult(scan);
        }
      } catch (e) {
        print('Error caching scan: $e');
      }
    }
  }

  /// Add new scan (saved to both Firestore and ObjectBox)
  Future<void> addHistory(ScanResult data) async {
    // Cache locally immediately
    await _database.insertScanResult(data);

    // Update local list
    final cached = await _database.getAllHistory();
    _historyList = cached;
    notifyListeners();
  }

  /// Delete history item
  Future<void> deleteHistory(int id) async {
    // Find the scan with this local ID
    ScanResult? scan;
    try {
      scan = _database.getScanResultById(id);
    } catch (e) {
      print('Error finding scan: $e');
    }

    if (scan != null) {
      // Delete from Firestore if it has a Firestore ID
      if (scan.firestoreId != null) {
        await _firestoreService.deleteScanResult(scan.firestoreId!);
      }

      // Delete from local cache
      await _database.deleteHistory(id);
    }

    // Reload
    await loadHistory();
  }

  /// Clear all history
  Future<void> clearAll() async {
    final user = _auth.currentUser;
    if (user == null) return;

    // Delete all user's scans from Firestore
    final scans = await _firestoreService.getUserScans(user.uid).first;
    for (final scan in scans) {
      if (scan.firestoreId != null) {
        await _firestoreService.deleteScanResult(scan.firestoreId!);
      }
    }

    // Clear local cache
    await _database.clearAll();

    _historyList = [];
    notifyListeners();
  }

  /// Load favorites (local only)
  Future<void> loadFavorites() async {
    _favoritesList = await _database.getFavorites();
    notifyListeners();
  }

  /// Toggle favorite status
  Future<void> toggleFavorite(ScanResult scan) async {
    final updated = scan.copyWith(isFavorite: !scan.isFavorite);
    await _database.updateScanResult(updated);
    await loadFavorites();
  }

  /// Search history
  Future<List<ScanResult>> searchHistory(String searchTerm) async {
    if (searchTerm.isEmpty) return _historyList;

    return _historyList
        .where(
          (scan) =>
              scan.name.toLowerCase().contains(searchTerm.toLowerCase()) ||
              scan.origin.toLowerCase().contains(searchTerm.toLowerCase()) ||
              scan.tags.any(
                (tag) => tag.toLowerCase().contains(searchTerm.toLowerCase()),
              ),
        )
        .toList();
  }

  @override
  void dispose() {
    _historySubscription?.cancel();
    _database.close();
    super.dispose();
  }
}
