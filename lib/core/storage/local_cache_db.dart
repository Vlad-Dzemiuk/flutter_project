import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift_sqflite/drift_sqflite.dart';
import 'package:path/path.dart' as p;
// Використовується тільки для getDatabasesPath()
// Основна робота з БД виконується через Drift
import 'package:sqflite/sqflite.dart' as sqflite;

part 'local_cache_db.g.dart';

/// Drift таблиця для збереження кешованих даних API відповідей
/// Використовується для offline-first кешування TMDB API
@DataClassName('CacheEntry')
class CacheEntries extends Table {
  TextColumn get key => text()();
  TextColumn get data => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {key};
}

/// Drift база даних для локального кешу API відповідей
@DriftDatabase(tables: [CacheEntries])
class AppDatabase extends _$AppDatabase {
  AppDatabase._internal() : super(_openConnection());

  static final AppDatabase instance = AppDatabase._internal();

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Додати міграції при оновленні схеми
      },
    );
  }

  /// Створює з'єднання з базою даних через Drift
  /// Використовує drift_sqflite як драйвер для локального сховища
  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await sqflite.getDatabasesPath();
      final path = p.join(dbFolder, 'tmdb_cache.db');
      
      return SqfliteQueryExecutor(
        path: path,
        singleInstance: true,
      );
    });
  }
  
  /// Видалити стару базу даних для початку з чистого кешу
  static Future<void> deleteOldDatabase() async {
    try {
      final dbFolder = await sqflite.getDatabasesPath();
      final path = p.join(dbFolder, 'tmdb_cache.db');
      final dbFile = File(path);
      if (await dbFile.exists()) {
        await dbFile.delete();
      }
    } catch (_) {
      // Ігноруємо помилки
    }
  }

  /// Ініціалізувати базу даних (гарантує що база готова до використання)
  Future<void> ensureInitialized() async {
    // Виконуємо простий запит через Drift API для ініціалізації бази
    await (select(cacheEntries)..limit(0)).get();
  }

  /// Отримати JSON по ключу з перевіркою віку даних
  /// Використовує Drift select() запит для типобезпечного читання
  /// Якщо дані старші за [maxAge] – повертає null
  Future<Map<String, dynamic>?> getJson(
    String key, {
    Duration maxAge = const Duration(minutes: 30),
  }) async {
    final entry = await (select(cacheEntries)
          ..where((tbl) => tbl.key.equals(key))
          ..limit(1))
        .getSingleOrNull();

    if (entry == null) return null;

    final now = DateTime.now();
    if (now.difference(entry.updatedAt) > maxAge) {
      return null;
    }

    return jsonDecode(entry.data) as Map<String, dynamic>;
  }

  /// Отримати JSON по ключу без перевірки віку
  /// Використовується для offline-first fallback при помилках мережі
  /// Повертає дані навіть якщо вони застарілі
  Future<Map<String, dynamic>?> getJsonStale(String key) async {
    final entry = await (select(cacheEntries)
          ..where((tbl) => tbl.key.equals(key))
          ..limit(1))
        .getSingleOrNull();

    if (entry == null) return null;

    return jsonDecode(entry.data) as Map<String, dynamic>;
  }

  /// Зберегти JSON у кеш
  /// Використовує Drift insert() з InsertMode.replace для оновлення існуючих записів
  Future<void> putJson(String key, Map<String, dynamic> data) async {
    await into(cacheEntries).insert(
      CacheEntriesCompanion(
        key: Value(key),
        data: Value(jsonEncode(data)),
        updatedAt: Value(DateTime.now()),
      ),
      mode: InsertMode.replace,
    );
  }

  /// Очистити весь кеш
  Future<void> clearCache() async {
    await delete(cacheEntries).go();
  }
  
  /// Видалити базу даних повністю та створити нову
  Future<void> resetDatabase() async {
    await close();
    await deleteOldDatabase();
  }
}

/// Обгортка для зворотної сумісності з існуючим кодом
/// Делегує всі операції до AppDatabase (Drift база даних)
/// Дозволяє використовувати старий API без змін в інших частинах проєкту
class LocalCacheDb {
  LocalCacheDb._internal();
  static final LocalCacheDb instance = LocalCacheDb._internal();

  /// Отримати доступ до бази даних (для ініціалізації)
  Future<AppDatabase> get database async => AppDatabase.instance;

  /// Отримати JSON по ключу. Якщо дані старші за [maxAge] – повертає null.
  Future<Map<String, dynamic>?> getJson(
    String key, {
    Duration maxAge = const Duration(minutes: 30),
  }) async {
    return AppDatabase.instance.getJson(key, maxAge: maxAge);
  }

  /// Отримати JSON по ключу без перевірки віку (для fallback при помилках мережі).
  Future<Map<String, dynamic>?> getJsonStale(String key) async {
    return AppDatabase.instance.getJsonStale(key);
  }

  /// Зберегти JSON у кеш.
  Future<void> putJson(String key, Map<String, dynamic> data) async {
    return AppDatabase.instance.putJson(key, data);
  }
  
  /// Очистити весь кеш (видалити всі записи)
  Future<void> clearCache() async {
    return AppDatabase.instance.clearCache();
  }
  
  /// Видалити базу даних повністю та створити нову
  /// Дозволяє користувачам почати з повністю чистого кешу
  Future<void> resetDatabase() async {
    return AppDatabase.instance.resetDatabase();
  }
}
