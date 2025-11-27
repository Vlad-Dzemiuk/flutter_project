import 'package:hive_flutter/hive_flutter.dart';

class MediaCollectionsStorage {
  MediaCollectionsStorage._();
  static final MediaCollectionsStorage instance = MediaCollectionsStorage._();

  static const _boxName = 'media_collections_box';
  static const _favoritesKey = 'favorites';
  static const _watchlistKey = 'watchlist';

  Box? _box;

  Future<Box> _getBox() async {
    if (_box != null && _box!.isOpen) {
      return _box!;
    }
    _box = await Hive.openBox(_boxName);
    return _box!;
  }

  Future<Map<String, Map<String, dynamic>>> readFavorites() {
    return _readCollection(_favoritesKey);
  }

  Future<Map<String, Map<String, dynamic>>> readWatchlist() {
    return _readCollection(_watchlistKey);
  }

  Future<void> writeFavorites(Map<String, Map<String, dynamic>> data) {
    return _writeCollection(_favoritesKey, data);
  }

  Future<void> writeWatchlist(Map<String, Map<String, dynamic>> data) {
    return _writeCollection(_watchlistKey, data);
  }

  Future<Map<String, Map<String, dynamic>>> _readCollection(String key) async {
    final box = await _getBox();
    final raw = box.get(key);
    if (raw == null) {
      return {};
    }
    final map = Map<String, dynamic>.from(raw as Map);
    return map.map(
      (k, value) =>
          MapEntry(k as String, Map<String, dynamic>.from(value as Map)),
    );
  }

  Future<void> _writeCollection(
    String key,
    Map<String, Map<String, dynamic>> data,
  ) async {
    final box = await _getBox();
    await box.put(key, data);
  }
}
