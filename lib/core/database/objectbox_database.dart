import 'package:dishcovery_app/core/models/scan_model.dart';
import 'package:dishcovery_app/core/models/scan_result_entity.dart';
import 'package:dishcovery_app/objectbox.g.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ObjectBoxDatabase {
  /// The Store of this app.
  late final Store _store;

  /// A Box of scan results.
  late final Box<ScanResultEntity> _scanResultBox;

  ObjectBoxDatabase._create(this._store) {
    _scanResultBox = Box<ScanResultEntity>(_store);
  }

  /// Create an instance of ObjectBox to use throughout the app.
  static Future<ObjectBoxDatabase> create() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final store = await openStore(
      directory: p.join(docsDir.path, "dishcovery-obx"),
    );
    return ObjectBoxDatabase._create(store);
  }

  /// Insert a scan result
  Future<int> insertScanResult(ScanResult result) async {
    if (!result.isFood) {
      return -1;
    }
    final entity = ScanResultEntity.fromScanResult(result);
    return _scanResultBox.put(entity);
  }

  /// Get all history items
  Future<List<ScanResult>> getAllHistory() async {
    final query = _scanResultBox
        .query()
        .order(ScanResultEntity_.createdAt, flags: Order.descending)
        .build();
    final entities = query.find();
    query.close();
    return entities.map((e) => e.toScanResult()).toList();
  }

  /// Delete a history item by ID
  Future<bool> deleteHistory(int id) async {
    return _scanResultBox.remove(id);
  }

  /// Clear all history
  Future<void> clearAll() async {
    await _scanResultBox.removeAll();
  }

  /// Update a scan result
  Future<void> updateScanResult(ScanResult result) async {
    if (result.id != null) {
      final entity = ScanResultEntity.fromScanResult(result);
      _scanResultBox.put(entity);
    }
  }

  /// Get a single scan result by ID
  ScanResult? getScanResultById(int id) {
    final entity = _scanResultBox.get(id);
    return entity?.toScanResult();
  }

  /// Get favorite scan results
  Future<List<ScanResult>> getFavorites() async {
    final query = _scanResultBox
        .query(ScanResultEntity_.isFavorite.equals(true))
        .order(ScanResultEntity_.createdAt, flags: Order.descending)
        .build();
    final entities = query.find();
    query.close();
    return entities.map((e) => e.toScanResult()).toList();
  }

  /// Get cached public scan results
  Future<List<ScanResult>> getCachedPublicScans() async {
    final query = _scanResultBox
        .query(ScanResultEntity_.isPublic.equals(true))
        .order(ScanResultEntity_.createdAt, flags: Order.descending)
        .build();
    final entities = query.find();
    query.close();
    return entities.map((e) => e.toScanResult()).toList();
  }

  /// Search scan results by name
  Future<List<ScanResult>> searchByName(String searchTerm) async {
    final query = _scanResultBox
        .query(
          ScanResultEntity_.name.contains(searchTerm, caseSensitive: false),
        )
        .order(ScanResultEntity_.createdAt, flags: Order.descending)
        .build();
    final entities = query.find();
    query.close();
    return entities.map((e) => e.toScanResult()).toList();
  }

  /// Close the store
  void close() {
    _store.close();
  }
}
