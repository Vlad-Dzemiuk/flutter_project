import 'package:firebase_auth/firebase_auth.dart';
import '../../features/auth/data/models/local_user.dart';

/// Сервіс для роботи з Firebase Authentication
class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Отримати поточного користувача Firebase
  User? get currentFirebaseUser => _auth.currentUser;

  /// Stream змін стану аутентифікації
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  /// Вхід з email та паролем
  Future<LocalUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user == null) {
        throw Exception('Не вдалося увійти. Користувач не знайдений.');
      }

      return _firebaseUserToLocalUser(credential.user!);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw Exception('Помилка входу: ${e.toString()}');
    }
  }

  /// Реєстрація з email та паролем
  Future<LocalUser> registerWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user == null) {
        throw Exception('Не вдалося зареєструвати користувача.');
      }

      return _firebaseUserToLocalUser(credential.user!);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw Exception('Помилка реєстрації: ${e.toString()}');
    }
  }

  /// Вихід
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Оновити профіль користувача
  Future<LocalUser> updateProfile({
    String? displayName,
    String? avatarUrl,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Користувач не авторизований');
    }

    try {
      await user.updateDisplayName(displayName);
      if (avatarUrl != null) {
        await user.updatePhotoURL(avatarUrl);
      }
      await user.reload();
      final updatedUser = _auth.currentUser;
      if (updatedUser == null) {
        throw Exception('Не вдалося оновити профіль');
      }
      return _firebaseUserToLocalUser(updatedUser);
    } catch (e) {
      throw Exception('Помилка оновлення профілю: ${e.toString()}');
    }
  }

  /// Змінити пароль
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Користувач не авторизований');
    }
    if (user.email == null) {
      throw Exception('Email користувача не знайдено');
    }

    try {
      // Перевіряємо поточний пароль
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Змінюємо пароль
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw Exception('Помилка зміни пароля: ${e.toString()}');
    }
  }

  /// Видалити акаунт
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) {
      return;
    }

    try {
      await user.delete();
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw Exception('Помилка видалення акаунта: ${e.toString()}');
    }
  }

  /// Отримати ID токен для авторизації API запитів
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      return await user.getIdToken(forceRefresh);
    } catch (e) {
      return null;
    }
  }

  /// Конвертує Firebase User в LocalUser
  LocalUser _firebaseUserToLocalUser(User firebaseUser) {
    // Використовуємо hash code як id, оскільки Firebase використовує String UID
    // Для сумісності з існуючою системою, конвертуємо UID в int
    final id = firebaseUser.uid.hashCode;

    return LocalUser(
      id: id,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName,
      avatarUrl: firebaseUser.photoURL,
    );
  }

  /// Обробка помилок Firebase Auth
  Exception _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return Exception('Користувача з таким email не знайдено');
      case 'wrong-password':
        return Exception('Невірний пароль');
      case 'email-already-in-use':
        return Exception('Користувач з таким email вже існує');
      case 'weak-password':
        return Exception('Пароль занадто слабкий');
      case 'invalid-email':
        return Exception('Невірний формат email');
      case 'user-disabled':
        return Exception('Акаунт користувача заблоковано');
      case 'too-many-requests':
        return Exception('Занадто багато запитів. Спробуйте пізніше');
      case 'operation-not-allowed':
        return Exception('Операція не дозволена');
      case 'requires-recent-login':
        return Exception(
          'Потрібен нещодавній вхід для виконання цієї операції',
        );
      default:
        return Exception(e.message ?? 'Помилка аутентифікації');
    }
  }
}
