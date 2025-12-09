import 'package:dio/dio.dart';
import '../../../home/data/models/movie_model.dart';
import '../../domain/repositories/favorites_repository.dart';
import 'package:project/core/network/dio_client.dart';
import 'package:project/core/storage/local_cache_db.dart';

/// Реалізація репозиторію для улюблених
class FavoritesRepositoryImpl implements FavoritesRepository {
  final Dio _dio = DioClient().dio;

  @override
  Future<List<Movie>> getFavoriteMovies(int accountId) async {
    final cacheKey = 'favorite_movies_$accountId';
    final cached =
        await LocalCacheDb.instance.getJson(cacheKey, maxAge: const Duration(minutes: 10));

    if (cached != null) {
      final List results = cached['results'] as List;
      return results.map((json) => Movie.fromJson(json as Map<String, dynamic>)).toList();
    }

    try {
      final response = await _dio.get('/account/$accountId/favorite/movies');
      final data = response.data as Map<String, dynamic>;
      await LocalCacheDb.instance.putJson(cacheKey, data);
      final List results = data['results'] as List;
      return results.map((json) => Movie.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      // Offline-first: спробувати отримати застарілі дані з кешу
      final staleCached = await LocalCacheDb.instance.getJsonStale(cacheKey);
      if (staleCached != null) {
        final List results = staleCached['results'] as List;
        return results.map((json) => Movie.fromJson(json as Map<String, dynamic>)).toList();
      }
      throw Exception('Failed to load favorite movies: ${e.message}');
    }
  }
}


