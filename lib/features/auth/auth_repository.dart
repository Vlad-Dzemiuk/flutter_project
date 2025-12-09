import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../core/storage/auth_db.dart';
import '../../core/auth/firebase_auth_service.dart';
import '../../core/auth/jwt_token_service.dart';
import '../../core/auth/auth_method.dart';
import 'data/models/local_user.dart';

/// Репозиторій авторизації з підтримкою різних методів аутентифікації:
/// - Локальна база даних (Drift/SQLite)
/// - Firebase Authentication
/// - Mock API з JWT tokens
class AuthRepository {
  AuthRepository({
    AuthMethod? authMethod,
    FirebaseAuthService? firebaseAuthService,
    JwtTokenService? jwtTokenService,
  })  : _db = AuthDb.instance,
        _authMethod = authMethod ?? AuthMethod.local,
        _firebaseAuthService = firebaseAuthService ?? FirebaseAuthService(),
        _jwtTokenService = jwtTokenService ?? JwtTokenService.instance;

  final AuthDb _db;
  final AuthMethod _authMethod;
  final FirebaseAuthService _firebaseAuthService;
  final JwtTokenService _jwtTokenService;

  LocalUser? _currentUser;
  final _controller = StreamController<LocalUser?>.broadcast();

  LocalUser? get currentUser => _currentUser;

  Stream<LocalUser?> authStateChanges() {
    if (_authMethod == AuthMethod.firebase) {
      // Для Firebase використовуємо stream з Firebase Auth
      return _firebaseAuthService.authStateChanges().asyncMap((firebaseUser) async {
        if (firebaseUser == null) {
          _setCurrentUser(null);
          return null;
        }
        final user = _firebaseUserToLocalUser(firebaseUser);
        _setCurrentUser(user);
        return user;
      });
    }
    return _controller.stream;
  }

  /// Отримує JWT токен для поточного користувача (якщо використовується JWT метод)
  Future<String?> getJwtToken() async {
    if (_authMethod == AuthMethod.jwt) {
      return await _jwtTokenService.getToken();
    } else if (_authMethod == AuthMethod.firebase) {
      return await _firebaseAuthService.getIdToken();
    }
    return null;
  }

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
    switch (_authMethod) {
      case AuthMethod.firebase:
        final user = await _firebaseAuthService.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        _setCurrentUser(user);
        return user;

      case AuthMethod.jwt:
        // Для JWT використовуємо локальну БД для перевірки, але генеруємо JWT токен
        final row = await _db.getUserByEmail(email);
        if (row == null) {
          throw Exception('Користувача з таким email не знайдено');
        }
        if (row['password'] != password) {
          throw Exception('Невірний пароль');
        }
        final user = _mapRowToUser(row);
        // Генеруємо JWT токен
        await _jwtTokenService.generateToken(
          userId: user.id,
          email: user.email,
        );
        _setCurrentUser(user);
        return user;

      case AuthMethod.local:
      default:
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
  }

  Future<LocalUser> register({
    required String email,
    required String password,
  }) async {
    switch (_authMethod) {
      case AuthMethod.firebase:
        final user = await _firebaseAuthService.registerWithEmailAndPassword(
          email: email,
          password: password,
        );
        _setCurrentUser(user);
        return user;

      case AuthMethod.jwt:
        // Для JWT також зберігаємо в локальну БД та генеруємо токен
        final existing = await _db.getUserByEmail(email);
        if (existing != null) {
          throw Exception('Користувач з таким email вже існує');
        }
        final id = await _db.insertUser(email, password);
        final user = LocalUser(id: id, email: email);
        // Генеруємо JWT токен
        await _jwtTokenService.generateToken(
          userId: user.id,
          email: user.email,
        );
        _setCurrentUser(user);
        return user;

      case AuthMethod.local:
      default:
        final existing = await _db.getUserByEmail(email);
        if (existing != null) {
          throw Exception('Користувач з таким email вже існує');
        }
        final id = await _db.insertUser(email, password);
        final user = LocalUser(id: id, email: email);
        _setCurrentUser(user);
        return user;
    }
  }

  Future<void> signOut() async {
    switch (_authMethod) {
      case AuthMethod.firebase:
        await _firebaseAuthService.signOut();
        _setCurrentUser(null);
        break;

      case AuthMethod.jwt:
        await _jwtTokenService.deleteToken();
        _setCurrentUser(null);
        break;

      case AuthMethod.local:
      default:
        _setCurrentUser(null);
        break;
    }
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

    switch (_authMethod) {
      case AuthMethod.firebase:
        final updatedUser = await _firebaseAuthService.updateProfile(
          displayName: clearDisplayName ? null : displayName,
          avatarUrl: clearAvatar ? null : avatarUrl,
        );
        _setCurrentUser(updatedUser);
        return updatedUser;

      case AuthMethod.jwt:
      case AuthMethod.local:
      default:
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
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _currentUser;
    if (user == null) {
      throw Exception('Користувач не авторизований');
    }

    switch (_authMethod) {
      case AuthMethod.firebase:
        await _firebaseAuthService.changePassword(
          currentPassword: currentPassword,
          newPassword: newPassword,
        );
        break;

      case AuthMethod.jwt:
      case AuthMethod.local:
      default:
        final row = await _db.getUserByEmail(user.email);
        if (row == null) {
          throw Exception('Користувача не знайдено');
        }
        if (row['password'] != currentPassword) {
          throw Exception('Невірний поточний пароль');
        }
        await _db.updateUserPassword(user.id, newPassword);
        break;
    }
  }

  Future<void> deleteAccount() async {
    final user = _currentUser;
    if (user == null) return;

    switch (_authMethod) {
      case AuthMethod.firebase:
        await _firebaseAuthService.deleteAccount();
        _setCurrentUser(null);
        break;

      case AuthMethod.jwt:
        await _jwtTokenService.deleteToken();
        await _db.deleteUser(user.id);
        _setCurrentUser(null);
        break;

      case AuthMethod.local:
      default:
        await _db.deleteUser(user.id);
        _setCurrentUser(null);
        break;
    }
  }

  /// Ініціалізація - перевіряє чи є збережений користувач
  Future<void> initialize() async {
    switch (_authMethod) {
      case AuthMethod.firebase:
        // Для Firebase перевіряємо поточного користувача
        final firebaseUser = _firebaseAuthService.currentFirebaseUser;
        if (firebaseUser != null) {
          final user = _firebaseUserToLocalUser(firebaseUser);
          _setCurrentUser(user);
        }
        break;

      case AuthMethod.jwt:
        // Для JWT перевіряємо токен
        final token = await _jwtTokenService.getToken();
        if (token != null) {
          final payload = await _jwtTokenService.validateToken(token);
          if (payload != null) {
            final userId = payload['userId'] as int?;
            final email = payload['email'] as String?;
            if (userId != null && email != null) {
              final row = await _db.getUserByEmail(email);
              if (row != null) {
                final user = _mapRowToUser(row);
                _setCurrentUser(user);
              }
            }
          }
        }
        break;

      case AuthMethod.local:
      default:
        // Для локальної БД не зберігаємо стан між сесіями
        break;
    }
  }

  void _setCurrentUser(LocalUser? user) {
    _currentUser = user;
    _controller.add(user);
  }

  LocalUser _firebaseUserToLocalUser(firebase_auth.User firebaseUser) {
    // Використовуємо hash code як id для сумісності
    final id = firebaseUser.uid.hashCode;
    
    return LocalUser(
      id: id,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName,
      avatarUrl: firebaseUser.photoURL,
    );
  }
}



