import 'package:dio/dio.dart';
import '../../domain/repositories/profile_repository.dart';
import 'package:project/core/network/dio_client.dart';
import 'package:project/core/storage/local_cache_db.dart';

/// Реалізація репозиторію для профілю
class ProfileRepositoryImpl implements ProfileRepository {
  final Dio _dio = DioClient().dio;

  @override
  Future<UserProfile> getUserProfile(int userId) async {
    final cacheKey = 'user_profile_$userId';
    final cached =
        await LocalCacheDb.instance.getJson(cacheKey, maxAge: const Duration(minutes: 15));

    if (cached != null) {
      return UserProfile.fromJson(cached);
    }

    try {
      final response = await _dio.get('/account/$userId');
      final data = response.data as Map<String, dynamic>;
      await LocalCacheDb.instance.putJson(cacheKey, data);
      return UserProfile.fromJson(data);
    } on DioException catch (e) {
      // Offline-first: спробувати отримати застарілі дані з кешу
      final staleCached = await LocalCacheDb.instance.getJsonStale(cacheKey);
      if (staleCached != null) {
        return UserProfile.fromJson(staleCached);
      }
      throw Exception('Failed to load profile: ${e.message}');
    }
  }
}


