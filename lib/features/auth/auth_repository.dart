import 'dart:async';

import '../../core/storage/auth_db.dart';
import 'data/models/local_user.dart';

/// Репозиторій авторизації, що працює поверх SQLite (AuthDb).
class AuthRepository {
  AuthRepository() : _db = AuthDb.instance;

  final AuthDb _db;

  LocalUser? _currentUser;
  final _controller = StreamController<LocalUser?>.broadcast();

  LocalUser? get currentUser => _currentUser;

  Stream<LocalUser?> authStateChanges() => _controller.stream;

  LocalUser _mapRowToUser(Map<String, dynamic> row) {
    return LocalUser(
      id: row['id'] as int,
      email: row['email'] as String,
      displayName: row['display_name'] as String?,
      avatarUrl: row['avatar_url'] as String?,
    );
  }

  Future<LocalUser> signIn({
    required String email,
    required String password,
  }) async {
    final row = await _db.getUserByEmail(email);
    if (row == null) {
      throw Exception('Користувача з таким email не знайдено');
    }
    if (row['password'] != password) {
      throw Exception('Невірний пароль');
    }
    final user = _mapRowToUser(row);
    _setCurrentUser(user);
    return user;
  }

  Future<LocalUser> register({
    required String email,
    required String password,
  }) async {
    final existing = await _db.getUserByEmail(email);
    if (existing != null) {
      throw Exception('Користувач з таким email вже існує');
    }
    final id = await _db.insertUser(email, password);
    final user = LocalUser(id: id, email: email);
    _setCurrentUser(user);
    return user;
  }

  Future<void> signOut() async {
    _setCurrentUser(null);
  }

  Future<LocalUser> updateProfile({
    String? displayName,
    bool clearDisplayName = false,
    String? avatarUrl,
    bool clearAvatar = false,
  }) async {
    final user = _currentUser;
    if (user == null) {
      throw Exception('Користувач не авторизований');
    }
    await _db.updateUserProfile(
      user.id,
      displayName: displayName,
      clearDisplayName: clearDisplayName,
      avatarUrl: avatarUrl,
      clearAvatar: clearAvatar,
    );
    final row = await _db.getUserByEmail(user.email);
    if (row == null) {
      throw Exception('Не вдалося оновити профіль');
    }
    final updatedUser = _mapRowToUser(row);
    _setCurrentUser(updatedUser);
    return updatedUser;
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _currentUser;
    if (user == null) {
      throw Exception('Користувач не авторизований');
    }
    final row = await _db.getUserByEmail(user.email);
    if (row == null) {
      throw Exception('Користувача не знайдено');
    }
    if (row['password'] != currentPassword) {
      throw Exception('Невірний поточний пароль');
    }
    await _db.updateUserPassword(user.id, newPassword);
  }

  Future<void> deleteAccount() async {
    final user = _currentUser;
    if (user == null) return;
    await _db.deleteUser(user.id);
    _setCurrentUser(null);
  }

  void _setCurrentUser(LocalUser? user) {
    _currentUser = user;
    _controller.add(user);
  }
}



