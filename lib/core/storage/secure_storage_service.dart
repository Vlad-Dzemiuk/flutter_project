import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../constants.dart';

/// Безпечне зберігання чутливих даних (API key, токени).
class SecureStorageService {
  static const _tmdbApiKeyKey = 'tmdb_api_key';
  static const _jwtTokenKey = 'jwt_token';

  SecureStorageService._internal();
  static final SecureStorageService instance = SecureStorageService._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// Повертає TMDB API key.
  /// Якщо його ще немає в secure storage – бере з .env / AppConstants і зберігає.
  Future<String> getTmdbApiKey() async {
    final fromStorage = await _storage.read(key: _tmdbApiKeyKey);
    if (fromStorage != null && fromStorage.isNotEmpty) {
      return fromStorage;
    }

    final fromEnv = dotenv.env['TMDB_API_KEY'] ?? AppConstants.tmdbApiKey;
    if (fromEnv.isEmpty || fromEnv == 'YOUR_API_KEY_HERE') {
      throw Exception('TMDB_API_KEY is not configured');
    }

    await _storage.write(key: _tmdbApiKeyKey, value: fromEnv);
    return fromEnv;
  }

  Future<void> clearTmdbApiKey() async {
    await _storage.delete(key: _tmdbApiKeyKey);
  }

  /// Зберігає JWT токен
  Future<void> saveJwtToken(String token) async {
    await _storage.write(key: _jwtTokenKey, value: token);
  }

  /// Отримує JWT токен
  Future<String?> getJwtToken() async {
    return await _storage.read(key: _jwtTokenKey);
  }

  /// Видаляє JWT токен
  Future<void> deleteJwtToken() async {
    await _storage.delete(key: _jwtTokenKey);
  }
}


