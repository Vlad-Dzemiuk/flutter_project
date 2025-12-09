import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift_sqflite/drift_sqflite.dart';
import 'package:path/path.dart' as p;
// Використовується тільки для getDatabasesPath()
// Основна робота з БД виконується через Drift
import 'package:sqflite/sqflite.dart' as sqflite;

part 'media_collections_storage.g.dart';

/// Drift таблиця для улюблених
@DataClassName('FavoriteEntry')
class Favorites extends Table {
  TextColumn get key => text()();
  TextColumn get data => text()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {key};
}

/// Drift таблиця для watchlist
@DataClassName('WatchlistEntry')
class Watchlist extends Table {
  TextColumn get key => text()();
  TextColumn get data => text()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {key};
}

/// Drift база даних для улюблених та watchlist
@DriftDatabase(tables: [Favorites, Watchlist])
class MediaCollectionsDatabase extends _$MediaCollectionsDatabase {
  MediaCollectionsDatabase._internal() : super(_openConnection());

  static final MediaCollectionsDatabase instance = MediaCollectionsDatabase._internal();

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
      final path = p.join(dbFolder, 'media_collections.db');
      
      return SqfliteQueryExecutor(
        path: path,
        singleInstance: true,
      );
    });
  }

  /// Ініціалізувати базу даних (гарантує що база готова до використання)
  Future<void> ensureInitialized() async {
    // Виконуємо простий запит через Drift API для ініціалізації бази
    await (select(favorites)..limit(0)).get();
  }

  /// Отримати всі улюблені
  Future<Map<String, Map<String, dynamic>>> readFavorites() async {
    final entries = await select(favorites).get();
    final result = <String, Map<String, dynamic>>{};
    
    for (final entry in entries) {
      final dataJson = jsonDecode(entry.data) as Map<String, dynamic>;
      result[entry.key] = dataJson;
    }
    
    return result;
  }

  /// Отримати весь watchlist
  Future<Map<String, Map<String, dynamic>>> readWatchlist() async {
    final entries = await select(watchlist).get();
    final result = <String, Map<String, dynamic>>{};
    
    for (final entry in entries) {
      final dataJson = jsonDecode(entry.data) as Map<String, dynamic>;
      result[entry.key] = dataJson;
    }
    
    return result;
  }

  /// Записати улюблені
  Future<void> writeFavorites(Map<String, Map<String, dynamic>> data) async {
    await _writeFavoritesInternal(data);
  }

  /// Записати watchlist
  Future<void> writeWatchlist(Map<String, Map<String, dynamic>> data) async {
    await _writeWatchlistInternal(data);
  }

  /// Записати улюблені (внутрішній метод)
  Future<void> _writeFavoritesInternal(Map<String, Map<String, dynamic>> data) async {
    // Видаляємо всі старі записи
    await delete(favorites).go();
    
    // Додаємо нові записи через batch
    final now = DateTime.now().millisecondsSinceEpoch;
    await batch((batch) {
      for (final entry in data.entries) {
        batch.insert(
          favorites,
          FavoritesCompanion(
            key: Value(entry.key),
            data: Value(jsonEncode(entry.value)),
            updatedAt: Value(now),
          ),
          mode: InsertMode.replace,
        );
      }
    });
  }

  /// Записати watchlist (внутрішній метод)
  Future<void> _writeWatchlistInternal(Map<String, Map<String, dynamic>> data) async {
    // Видаляємо всі старі записи
    await delete(watchlist).go();
    
    // Додаємо нові записи через batch
    final now = DateTime.now().millisecondsSinceEpoch;
    await batch((batch) {
      for (final entry in data.entries) {
        batch.insert(
          watchlist,
          WatchlistCompanion(
            key: Value(entry.key),
            data: Value(jsonEncode(entry.value)),
            updatedAt: Value(now),
          ),
          mode: InsertMode.replace,
        );
      }
    });
  }
}

/// Обгортка для зворотної сумісності з існуючим кодом
/// Делегує всі операції до MediaCollectionsDatabase (Drift база даних)
class MediaCollectionsStorage {
  MediaCollectionsStorage._();
  static final MediaCollectionsStorage instance = MediaCollectionsStorage._();

  /// Отримати доступ до бази даних (для ініціалізації)
  Future<MediaCollectionsDatabase> get database async => MediaCollectionsDatabase.instance;

  /// Отримати всі улюблені
  Future<Map<String, Map<String, dynamic>>> readFavorites() {
    return MediaCollectionsDatabase.instance.readFavorites();
  }

  /// Отримати весь watchlist
  Future<Map<String, Map<String, dynamic>>> readWatchlist() {
    return MediaCollectionsDatabase.instance.readWatchlist();
  }

  /// Записати улюблені
  Future<void> writeFavorites(Map<String, Map<String, dynamic>> data) {
    return MediaCollectionsDatabase.instance.writeFavorites(data);
  }

  /// Записати watchlist
  Future<void> writeWatchlist(Map<String, Map<String, dynamic>> data) {
    return MediaCollectionsDatabase.instance.writeWatchlist(data);
  }
}
