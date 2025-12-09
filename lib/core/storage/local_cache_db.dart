import 'dart:convert';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Простіший кеш на SQLite для збереження відповідей TMDB (JSON як текст).
class LocalCacheDb {
  LocalCacheDb._internal();

  static final LocalCacheDb instance = LocalCacheDb._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'tmdb_cache.db');

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE cache_entries (
            key TEXT PRIMARY KEY,
            data TEXT NOT NULL,
            updated_at INTEGER NOT NULL
          )
        ''');
      },
    );

    return _db!;
  }

  /// Отримати JSON по ключу. Якщо дані старші за [maxAge] – повертає null.
  Future<Map<String, dynamic>?> getJson(
    String key, {
    Duration maxAge = const Duration(minutes: 30),
  }) async {
    final db = await database;
    final rows = await db.query(
      'cache_entries',
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (rows.isEmpty) return null;

    final row = rows.first;
    final updatedAt =
        DateTime.fromMillisecondsSinceEpoch(row['updated_at'] as int);

    if (DateTime.now().difference(updatedAt) > maxAge) {
      return null;
    }

    return jsonDecode(row['data'] as String) as Map<String, dynamic>;
  }

  /// Отримати JSON по ключу без перевірки віку (для fallback при помилках мережі).
  Future<Map<String, dynamic>?> getJsonStale(String key) async {
    final db = await database;
    final rows = await db.query(
      'cache_entries',
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (rows.isEmpty) return null;

    final row = rows.first;
    return jsonDecode(row['data'] as String) as Map<String, dynamic>;
  }

  /// Зберегти JSON у кеш.
  Future<void> putJson(String key, Map<String, dynamic> data) async {
    final db = await database;
    await db.insert(
      'cache_entries',
      {
        'key': key,
        'data': jsonEncode(data),
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}


