import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Збереження user preferences (тема, мова, тощо) через SQLite.
class UserPrefs {
  UserPrefs._internal();
  static final UserPrefs instance = UserPrefs._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'user_prefs.db');

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE preferences (
            key TEXT PRIMARY KEY,
            value TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE search_history (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            media_id INTEGER NOT NULL,
            is_movie INTEGER NOT NULL,
            data TEXT NOT NULL,
            added_at INTEGER NOT NULL
          )
        ''');
        // Створюємо індекс для швидкого пошуку
        await db.execute('''
          CREATE INDEX idx_search_history_media 
          ON search_history(media_id, is_movie)
        ''');
      },
    );

    return _db!;
  }

  // === Тема застосунку ===

  Future<void> setThemeMode(String mode) async {
    // 'light', 'dark', 'system'
    final db = await database;
    await db.insert(
      'preferences',
      {'key': 'theme_mode', 'value': mode},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String> getThemeMode() async {
    final db = await database;
    final rows = await db.query(
      'preferences',
      where: 'key = ?',
      whereArgs: ['theme_mode'],
      limit: 1,
    );
    if (rows.isEmpty) return 'system';
    return rows.first['value'] as String;
  }

  // === Мова інтерфейсу ===

  Future<void> setLanguageCode(String code) async {
    final db = await database;
    await db.insert(
      'preferences',
      {'key': 'language_code', 'value': code},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String> getLanguageCode() async {
    final db = await database;
    final rows = await db.query(
      'preferences',
      where: 'key = ?',
      whereArgs: ['language_code'],
      limit: 1,
    );
    if (rows.isEmpty) return 'en';
    return rows.first['value'] as String;
  }

  // === Історія переглянутих фільмів/серіалів з пошуку ===

  Future<void> addToSearchHistory(Map<String, dynamic> mediaItem) async {
    final db = await database;
    final mediaId = mediaItem['id'] as int;
    final isMovie = (mediaItem['isMovie'] as bool?) ?? false;
    
    // Видаляємо якщо вже є (за id та isMovie)
    await db.delete(
      'search_history',
      where: 'media_id = ? AND is_movie = ?',
      whereArgs: [mediaId, isMovie ? 1 : 0],
    );

    // Додаємо новий запис
    await db.insert(
      'search_history',
      {
        'media_id': mediaId,
        'is_movie': isMovie ? 1 : 0,
        'data': jsonEncode(mediaItem),
        'added_at': DateTime.now().millisecondsSinceEpoch,
      },
    );

    // Обмежуємо до 50 елементів - видаляємо найстаріші
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM search_history'),
    ) ?? 0;
    
    if (count > 50) {
      final rowsToDelete = await db.query(
        'search_history',
        orderBy: 'added_at ASC',
        limit: count - 50,
      );
      for (final row in rowsToDelete) {
        await db.delete(
          'search_history',
          where: 'id = ?',
          whereArgs: [row['id']],
        );
      }
    }
  }

  Future<List<Map<String, dynamic>>> getSearchHistory() async {
    final db = await database;
    final rows = await db.query(
      'search_history',
      orderBy: 'added_at DESC',
      limit: 50,
    );
    
    return rows.map((row) {
      final dataJson = jsonDecode(row['data'] as String) as Map<String, dynamic>;
      return dataJson;
    }).toList();
  }

  Future<void> clearSearchHistory() async {
    final db = await database;
    await db.delete('search_history');
  }
}
