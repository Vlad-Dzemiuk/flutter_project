import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// SQLite-база для збереження локальних користувачів (email + пароль).
class AuthDb {
  AuthDb._internal();

  static final AuthDb instance = AuthDb._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'auth.db');

    _db = await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            email TEXT UNIQUE NOT NULL,
            password TEXT NOT NULL,
            display_name TEXT,
            avatar_url TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'ALTER TABLE users ADD COLUMN display_name TEXT NULL',
          );
          await db.execute('ALTER TABLE users ADD COLUMN avatar_url TEXT NULL');
        }
      },
    );

    return _db!;
  }

  Future<int> insertUser(String email, String password) async {
    final db = await database;
    return db.insert('users', {
      'email': email,
      'password': password,
    }, conflictAlgorithm: ConflictAlgorithm.abort);
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await database;
    final rows = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first;
  }

  Future<void> updateUserProfile(
    int id, {
    String? displayName,
    bool clearDisplayName = false,
    String? avatarUrl,
    bool clearAvatar = false,
  }) async {
    final db = await database;
    final data = <String, Object?>{};
    if (clearDisplayName) {
      data['display_name'] = null;
    } else if (displayName != null) {
      data['display_name'] = displayName;
    }
    if (clearAvatar) {
      data['avatar_url'] = null;
    } else if (avatarUrl != null) {
      data['avatar_url'] = avatarUrl;
    }
    if (data.isEmpty) return;

    await db.update('users', data, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateUserPassword(int id, String newPassword) async {
    final db = await database;
    await db.update(
      'users',
      {'password': newPassword},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteUser(int id) async {
    final db = await database;
    await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }
}
