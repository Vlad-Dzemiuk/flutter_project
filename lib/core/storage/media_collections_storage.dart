import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// SQLite-зберігання для улюблених та watchlist
class MediaCollectionsStorage {
  MediaCollectionsStorage._();
  static final MediaCollectionsStorage instance = MediaCollectionsStorage._();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'media_collections.db');

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE favorites (
            key TEXT PRIMARY KEY,
            data TEXT NOT NULL,
            updated_at INTEGER NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE watchlist (
            key TEXT PRIMARY KEY,
            data TEXT NOT NULL,
            updated_at INTEGER NOT NULL
          )
        ''');
      },
    );

    return _db!;
  }

  Future<Map<String, Map<String, dynamic>>> readFavorites() {
    return _readCollection('favorites');
  }

  Future<Map<String, Map<String, dynamic>>> readWatchlist() {
    return _readCollection('watchlist');
  }

  Future<void> writeFavorites(Map<String, Map<String, dynamic>> data) {
    return _writeCollection('favorites', data);
  }

  Future<void> writeWatchlist(Map<String, Map<String, dynamic>> data) {
    return _writeCollection('watchlist', data);
  }

  Future<Map<String, Map<String, dynamic>>> _readCollection(
    String tableName,
  ) async {
    final db = await database;
    final rows = await db.query(tableName);
    
    final result = <String, Map<String, dynamic>>{};
    for (final row in rows) {
      final key = row['key'] as String;
      final dataJson = jsonDecode(row['data'] as String) as Map<String, dynamic>;
      result[key] = dataJson;
    }
    
    return result;
  }

  Future<void> _writeCollection(
    String tableName,
    Map<String, Map<String, dynamic>> data,
  ) async {
    final db = await database;
    
    // Видаляємо всі старі записи
    await db.delete(tableName);
    
    // Додаємо нові записи
    final batch = db.batch();
    final now = DateTime.now().millisecondsSinceEpoch;
    
    for (final entry in data.entries) {
      batch.insert(
        tableName,
        {
          'key': entry.key,
          'data': jsonEncode(entry.value),
          'updated_at': now,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    
    await batch.commit(noResult: true);
  }
}
