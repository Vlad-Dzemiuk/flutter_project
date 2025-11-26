import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../constants.dart';

/// Безпечне зберігання чутливих даних (API key, токени).
class SecureStorageService {
  static const _tmdbApiKeyKey = 'tmdb_api_key';

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
}


