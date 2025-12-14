import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../storage/secure_storage_service.dart';

/// Сервіс для роботи з JWT токенами (Mock API)
///
/// Генерує та зберігає JWT токени для локальної аутентифікації
class JwtTokenService {
  static const String _jwtSecret =
      'your-secret-key-change-in-production'; // В продакшені використовуйте безпечний ключ

  JwtTokenService._internal([SecureStorageService? secureStorage])
      : _secureStorage = secureStorage ?? SecureStorageService.instance;
  static final JwtTokenService instance = JwtTokenService._internal();

  /// Конструктор для тестування (дозволяє передати тестовий SecureStorageService)
  JwtTokenService.forTesting(SecureStorageService secureStorage)
      : _secureStorage = secureStorage;

  final SecureStorageService _secureStorage;

  /// Генерує JWT токен для користувача
  ///
  /// [userId] - ID користувача
  /// [email] - Email користувача
  /// [expiresInDays] - Термін дії токена в днях (за замовчуванням 7 днів)
  Future<String> generateToken({
    required int userId,
    required String email,
    int expiresInDays = 7,
  }) async {
    final now = DateTime.now();
    final expiresAt = now.add(Duration(days: expiresInDays));

    // Створюємо payload
    final payload = {
      'userId': userId,
      'email': email,
      'iat': now.millisecondsSinceEpoch ~/ 1000, // Issued at (Unix timestamp)
      'exp': expiresAt.millisecondsSinceEpoch ~/
          1000, // Expiration (Unix timestamp)
    };

    // Кодуємо header та payload
    final header = base64Url.encode(
      utf8.encode(jsonEncode({'typ': 'JWT', 'alg': 'HS256'})),
    );
    final payloadEncoded = base64Url.encode(utf8.encode(jsonEncode(payload)));

    // Створюємо signature
    final signature = _createSignature('$header.$payloadEncoded');

    // Формуємо JWT токен
    final token = '$header.$payloadEncoded.$signature';

    // Зберігаємо токен
    await _secureStorage.saveJwtToken(token);

    return token;
  }

  /// Перевіряє валідність JWT токена
  ///
  /// Повертає payload якщо токен валідний, null якщо ні
  Future<Map<String, dynamic>?> validateToken(String? token) async {
    if (token == null || token.isEmpty) {
      return null;
    }

    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        return null;
      }

      final header = parts[0];
      final payload = parts[1];
      final signature = parts[2];

      // Перевіряємо signature
      final expectedSignature = _createSignature('$header.$payload');
      if (signature != expectedSignature) {
        return null;
      }

      // Декодуємо payload
      final payloadBytes = base64Url.decode(payload);
      final payloadJson =
          jsonDecode(utf8.decode(payloadBytes)) as Map<String, dynamic>;

      // Перевіряємо термін дії
      final exp = payloadJson['exp'] as int?;
      if (exp != null) {
        final expirationDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
        if (DateTime.now().isAfter(expirationDate)) {
          // Токен прострочений
          await _secureStorage.deleteJwtToken();
          return null;
        }
      }

      return payloadJson;
    } catch (e) {
      return null;
    }
  }

  /// Отримує збережений JWT токен
  Future<String?> getToken() async {
    return await _secureStorage.getJwtToken();
  }

  /// Видаляє JWT токен
  Future<void> deleteToken() async {
    await _secureStorage.deleteJwtToken();
  }

  /// Створює signature для JWT токена
  String _createSignature(String data) {
    final key = utf8.encode(_jwtSecret);
    final bytes = utf8.encode(data);
    final hmac = Hmac(sha256, key);
    final digest = hmac.convert(bytes);
    return base64Url.encode(digest.bytes);
  }

  /// Отримує userId з токена
  Future<int?> getUserIdFromToken() async {
    final token = await getToken();
    if (token == null) return null;

    final payload = await validateToken(token);
    if (payload == null) return null;

    return payload['userId'] as int?;
  }

  /// Отримує email з токена
  Future<String?> getEmailFromToken() async {
    final token = await getToken();
    if (token == null) return null;

    final payload = await validateToken(token);
    if (payload == null) return null;

    return payload['email'] as String?;
  }
}
