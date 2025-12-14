import 'package:drift/drift.dart';
import 'package:drift_sqflite/drift_sqflite.dart';
import 'package:path/path.dart' as p;
// Використовується тільки для getDatabasesPath()
// Основна робота з БД виконується через Drift
import 'package:sqflite/sqflite.dart' as sqflite;

part 'auth_db.g.dart';

/// Drift таблиця для збереження локальних користувачів
@DataClassName('User')
class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get email => text().withLength(min: 1).unique()();
  TextColumn get password => text().withLength(min: 1)();
  TextColumn get displayName => text().nullable()();
  TextColumn get avatarUrl => text().nullable()();
}

/// Drift база даних для локальної авторизації
@DriftDatabase(tables: [Users])
class AuthDatabase extends _$AuthDatabase {
  AuthDatabase._internal() : super(_openConnection());

  static final AuthDatabase instance = AuthDatabase._internal();

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          // Додаємо нові колонки для версії 2
          await m.addColumn(users, users.displayName);
          await m.addColumn(users, users.avatarUrl);
        }
      },
    );
  }

  /// Створює з'єднання з базою даних через Drift
  /// Використовує drift_sqflite як драйвер для локального сховища
  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await sqflite.getDatabasesPath();
      final path = p.join(dbFolder, 'auth.db');

      return SqfliteQueryExecutor(path: path, singleInstance: true);
    });
  }

  /// Ініціалізувати базу даних (гарантує що база готова до використання)
  Future<void> ensureInitialized() async {
    // Виконуємо простий запит через Drift API для ініціалізації бази
    await (select(users)..limit(0)).get();
  }

  /// Вставити нового користувача
  Future<int> insertUser(String email, String password) async {
    final companion = UsersCompanion(
      email: Value(email),
      password: Value(password),
    );
    // Не вказуємо mode - помилка буде викинута якщо email вже існує (unique constraint)
    // Перевірка на існуючого користувача вже виконується в AuthRepository
    return await into(users).insert(companion);
  }

  /// Отримати користувача по email
  Future<User?> getUserByEmail(String email) async {
    final query = select(users)
      ..where((tbl) => tbl.email.equals(email))
      ..limit(1);
    return await query.getSingleOrNull();
  }

  /// Отримати користувача по id
  Future<User?> getUserById(int id) async {
    final query = select(users)
      ..where((tbl) => tbl.id.equals(id))
      ..limit(1);
    return await query.getSingleOrNull();
  }

  /// Оновити профіль користувача
  Future<void> updateUserProfile(
    int id, {
    String? displayName,
    bool clearDisplayName = false,
    String? avatarUrl,
    bool clearAvatar = false,
  }) async {
    final companion = UsersCompanion(
      displayName: clearDisplayName ? const Value.absent() : Value(displayName),
      avatarUrl: clearAvatar ? const Value.absent() : Value(avatarUrl),
    );

    await (update(users)..where((tbl) => tbl.id.equals(id))).write(companion);
  }

  /// Оновити пароль користувача
  Future<void> updateUserPassword(int id, String newPassword) async {
    final companion = UsersCompanion(password: Value(newPassword));
    await (update(users)..where((tbl) => tbl.id.equals(id))).write(companion);
  }

  /// Видалити користувача
  Future<void> deleteUser(int id) async {
    await (delete(users)..where((tbl) => tbl.id.equals(id))).go();
  }
}

/// Обгортка для зворотної сумісності з існуючим кодом
/// Делегує всі операції до AuthDatabase (Drift база даних)
class AuthDb {
  AuthDb._internal();
  static final AuthDb instance = AuthDb._internal();

  /// Отримати доступ до бази даних (для ініціалізації)
  Future<AuthDatabase> get database async => AuthDatabase.instance;

  /// Вставити нового користувача
  Future<int> insertUser(String email, String password) async {
    return AuthDatabase.instance.insertUser(email, password);
  }

  /// Отримати користувача по email (повертає Map для сумісності)
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final user = await AuthDatabase.instance.getUserByEmail(email);
    if (user == null) return null;

    return {
      'id': user.id,
      'email': user.email,
      'password': user.password,
      'display_name': user.displayName,
      'avatar_url': user.avatarUrl,
    };
  }

  /// Оновити профіль користувача
  Future<void> updateUserProfile(
    int id, {
    String? displayName,
    bool clearDisplayName = false,
    String? avatarUrl,
    bool clearAvatar = false,
  }) async {
    return AuthDatabase.instance.updateUserProfile(
      id,
      displayName: displayName,
      clearDisplayName: clearDisplayName,
      avatarUrl: avatarUrl,
      clearAvatar: clearAvatar,
    );
  }

  /// Оновити пароль користувача
  Future<void> updateUserPassword(int id, String newPassword) async {
    return AuthDatabase.instance.updateUserPassword(id, newPassword);
  }

  /// Видалити користувача
  Future<void> deleteUser(int id) async {
    return AuthDatabase.instance.deleteUser(id);
  }
}
