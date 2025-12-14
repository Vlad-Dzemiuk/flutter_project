import 'package:dio/dio.dart';
import 'package:project/features/home/data/models/movie_model.dart';
import 'package:project/features/home/data/models/tv_show_model.dart';
import 'package:project/features/home/data/models/genre_model.dart';
import 'package:project/core/storage/local_cache_db.dart';
import 'package:project/core/network/dio_client.dart';

class HomeApiService {
  final Dio _dio = DioClient().dio;

  // Метод для отримання популярних фільмів
  Future<List<Movie>> fetchPopularMovies({int page = 1}) async {
    final cacheKey = 'popular_movies_page_$page';
    final cached = await LocalCacheDb.instance.getJson(
      cacheKey,
      maxAge: const Duration(minutes: 30),
    );

    if (cached != null) {
      final results = cached['results'] as List<dynamic>;
      return results
          .map<Movie>((json) => Movie.fromJson(json as Map<String, dynamic>))
          .toList();
    }

    try {
      final response = await _dio.get(
        '/movie/popular',
        queryParameters: {'page': page},
      );

      final data = response.data as Map<String, dynamic>;
      await LocalCacheDb.instance.putJson(cacheKey, data);
      final results = data['results'] as List<dynamic>;
      return results
          .map<Movie>((json) => Movie.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      // Offline-first: спробувати отримати застарілі дані з кешу
      final staleCached = await LocalCacheDb.instance.getJsonStale(cacheKey);
      if (staleCached != null) {
        final results = staleCached['results'] as List<dynamic>;
        return results
            .map<Movie>((json) => Movie.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Failed to fetch movies: ${e.message}');
    }
  }

  Future<List<Movie>> fetchAllMovies({int page = 1}) async {
    final cacheKey = 'all_movies_page_$page';
    final cached = await LocalCacheDb.instance.getJson(
      cacheKey,
      maxAge: const Duration(minutes: 30),
    );

    if (cached != null) {
      final results = cached['results'] as List<dynamic>;
      return results
          .map<Movie>((json) => Movie.fromJson(json as Map<String, dynamic>))
          .toList();
    }

    try {
      final response = await _dio.get(
        '/discover/movie',
        queryParameters: {'sort_by': 'popularity.desc', 'page': page},
      );

      final data = response.data as Map<String, dynamic>;
      await LocalCacheDb.instance.putJson(cacheKey, data);
      final results = data['results'] as List<dynamic>;
      return results
          .map<Movie>((json) => Movie.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      // Offline-first: спробувати отримати застарілі дані з кешу
      final staleCached = await LocalCacheDb.instance.getJsonStale(cacheKey);
      if (staleCached != null) {
        final results = staleCached['results'] as List<dynamic>;
        return results
            .map<Movie>((json) => Movie.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Failed to fetch movies catalog: ${e.message}');
    }
  }

  Future<List<TvShow>> fetchPopularTvShows({int page = 1}) async {
    final cacheKey = 'popular_tv_shows_page_$page';
    final cached = await LocalCacheDb.instance.getJson(
      cacheKey,
      maxAge: const Duration(minutes: 30),
    );

    if (cached != null) {
      final results = cached['results'] as List<dynamic>;
      return results
          .map<TvShow>((json) => TvShow.fromJson(json as Map<String, dynamic>))
          .toList();
    }

    try {
      final response = await _dio.get(
        '/tv/popular',
        queryParameters: {'page': page},
      );

      final data = response.data as Map<String, dynamic>;
      await LocalCacheDb.instance.putJson(cacheKey, data);
      final results = data['results'] as List<dynamic>;
      return results
          .map<TvShow>((json) => TvShow.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      // Offline-first: спробувати отримати застарілі дані з кешу
      final staleCached = await LocalCacheDb.instance.getJsonStale(cacheKey);
      if (staleCached != null) {
        final results = staleCached['results'] as List<dynamic>;
        return results
            .map<TvShow>(
              (json) => TvShow.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      }
      throw Exception('Failed to fetch tv shows: ${e.message}');
    }
  }

  Future<List<TvShow>> fetchAllTvShows({int page = 1}) async {
    final cacheKey = 'all_tv_shows_page_$page';
    final cached = await LocalCacheDb.instance.getJson(
      cacheKey,
      maxAge: const Duration(minutes: 30),
    );

    if (cached != null) {
      final results = cached['results'] as List<dynamic>;
      return results
          .map<TvShow>((json) => TvShow.fromJson(json as Map<String, dynamic>))
          .toList();
    }

    try {
      final response = await _dio.get(
        '/discover/tv',
        queryParameters: {'sort_by': 'popularity.desc', 'page': page},
      );

      final data = response.data as Map<String, dynamic>;
      await LocalCacheDb.instance.putJson(cacheKey, data);
      final results = data['results'] as List<dynamic>;
      return results
          .map<TvShow>((json) => TvShow.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      // Offline-first: спробувати отримати застарілі дані з кешу
      final staleCached = await LocalCacheDb.instance.getJsonStale(cacheKey);
      if (staleCached != null) {
        final results = staleCached['results'] as List<dynamic>;
        return results
            .map<TvShow>(
              (json) => TvShow.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      }
      throw Exception('Failed to fetch tv catalog: ${e.message}');
    }
  }

  // ===== Деталі фільму / серіалу, відео, відгуки, рекомендації =====

  Future<Map<String, dynamic>> fetchMovieDetails(int movieId) async {
    final cacheKey = 'movie_details_$movieId';
    final cached = await LocalCacheDb.instance.getJson(
      cacheKey,
      maxAge: const Duration(hours: 24),
    );

    if (cached != null) {
      return cached;
    }

    try {
      final response = await _dio.get('/movie/$movieId');
      final data = response.data as Map<String, dynamic>;
      await LocalCacheDb.instance.putJson(cacheKey, data);
      return data;
    } on DioException catch (e) {
      // Offline-first: спробувати отримати застарілі дані з кешу
      final staleCached = await LocalCacheDb.instance.getJsonStale(cacheKey);
      if (staleCached != null) {
        return staleCached;
      }
      throw Exception('Failed to fetch movie details: ${e.message}');
    }
  }

  Future<Map<String, dynamic>> fetchTvDetails(int tvId) async {
    final cacheKey = 'tv_details_$tvId';
    final cached = await LocalCacheDb.instance.getJson(
      cacheKey,
      maxAge: const Duration(hours: 24),
    );

    if (cached != null) {
      return cached;
    }

    try {
      final response = await _dio.get('/tv/$tvId');
      final data = response.data as Map<String, dynamic>;
      await LocalCacheDb.instance.putJson(cacheKey, data);
      return data;
    } on DioException catch (e) {
      // Offline-first: спробувати отримати застарілі дані з кешу
      final staleCached = await LocalCacheDb.instance.getJsonStale(cacheKey);
      if (staleCached != null) {
        return staleCached;
      }
      throw Exception('Failed to fetch tv details: ${e.message}');
    }
  }

  Future<List<dynamic>> fetchMovieVideos(int movieId) async {
    final cacheKey = 'movie_videos_$movieId';
    // Зменшено час кешування з 12 годин до 2 годин для уникнення застарілих відео
    final cached = await LocalCacheDb.instance.getJson(
      cacheKey,
      maxAge: const Duration(hours: 2),
    );

    if (cached != null) {
      return (cached['results'] as List<dynamic>);
    }

    try {
      final response = await _dio.get(
        '/movie/$movieId/videos',
        queryParameters: {'include_video_language': 'en,null,uk,ru'},
      );

      final data = response.data as Map<String, dynamic>;
      await LocalCacheDb.instance.putJson(cacheKey, data);
      return (data['results'] as List<dynamic>);
    } on DioException catch (e) {
      // Offline-first: спробувати отримати застарілі дані з кешу
      final staleCached = await LocalCacheDb.instance.getJsonStale(cacheKey);
      if (staleCached != null) {
        return (staleCached['results'] as List<dynamic>);
      }
      throw Exception('Failed to fetch movie videos: ${e.message}');
    }
  }

  Future<List<dynamic>> fetchTvVideos(int tvId) async {
    final cacheKey = 'tv_videos_$tvId';
    // Зменшено час кешування з 12 годин до 2 годин для уникнення застарілих відео
    final cached = await LocalCacheDb.instance.getJson(
      cacheKey,
      maxAge: const Duration(hours: 2),
    );

    if (cached != null) {
      return (cached['results'] as List<dynamic>);
    }

    try {
      final response = await _dio.get(
        '/tv/$tvId/videos',
        queryParameters: {'include_video_language': 'en,null,uk,ru'},
      );

      final data = response.data as Map<String, dynamic>;
      await LocalCacheDb.instance.putJson(cacheKey, data);
      return (data['results'] as List<dynamic>);
    } on DioException catch (e) {
      // Offline-first: спробувати отримати застарілі дані з кешу
      final staleCached = await LocalCacheDb.instance.getJsonStale(cacheKey);
      if (staleCached != null) {
        return (staleCached['results'] as List<dynamic>);
      }
      throw Exception('Failed to fetch tv videos: ${e.message}');
    }
  }

  Future<List<dynamic>> fetchMovieReviews(int movieId) async {
    final cacheKey = 'movie_reviews_$movieId';
    final cached = await LocalCacheDb.instance.getJson(
      cacheKey,
      maxAge: const Duration(hours: 6),
    );

    if (cached != null) {
      return (cached['results'] as List<dynamic>);
    }

    try {
      final response = await _dio.get('/movie/$movieId/reviews');
      final data = response.data as Map<String, dynamic>;
      await LocalCacheDb.instance.putJson(cacheKey, data);
      return (data['results'] as List<dynamic>);
    } on DioException catch (e) {
      // Offline-first: спробувати отримати застарілі дані з кешу
      final staleCached = await LocalCacheDb.instance.getJsonStale(cacheKey);
      if (staleCached != null) {
        return (staleCached['results'] as List<dynamic>);
      }
      throw Exception('Failed to fetch movie reviews: ${e.message}');
    }
  }

  Future<List<dynamic>> fetchTvReviews(int tvId) async {
    final cacheKey = 'tv_reviews_$tvId';
    final cached = await LocalCacheDb.instance.getJson(
      cacheKey,
      maxAge: const Duration(hours: 6),
    );

    if (cached != null) {
      return (cached['results'] as List<dynamic>);
    }

    try {
      final response = await _dio.get('/tv/$tvId/reviews');
      final data = response.data as Map<String, dynamic>;
      await LocalCacheDb.instance.putJson(cacheKey, data);
      return (data['results'] as List<dynamic>);
    } on DioException catch (e) {
      // Offline-first: спробувати отримати застарілі дані з кешу
      final staleCached = await LocalCacheDb.instance.getJsonStale(cacheKey);
      if (staleCached != null) {
        return (staleCached['results'] as List<dynamic>);
      }
      throw Exception('Failed to fetch tv reviews: ${e.message}');
    }
  }

  Future<List<Movie>> fetchMovieRecommendations(int movieId) async {
    final cacheKey = 'movie_recommendations_$movieId';
    final cached = await LocalCacheDb.instance.getJson(
      cacheKey,
      maxAge: const Duration(hours: 12),
    );

    if (cached != null) {
      final results = cached['results'] as List<dynamic>;
      return results
          .map<Movie>((json) => Movie.fromJson(json as Map<String, dynamic>))
          .toList();
    }

    try {
      final response = await _dio.get('/movie/$movieId/recommendations');
      final data = response.data as Map<String, dynamic>;
      await LocalCacheDb.instance.putJson(cacheKey, data);
      final results = data['results'] as List<dynamic>;
      return results
          .map<Movie>((json) => Movie.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      // Offline-first: спробувати отримати застарілі дані з кешу
      final staleCached = await LocalCacheDb.instance.getJsonStale(cacheKey);
      if (staleCached != null) {
        final results = staleCached['results'] as List<dynamic>;
        return results
            .map<Movie>((json) => Movie.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Failed to fetch movie recommendations: ${e.message}');
    }
  }

  Future<List<TvShow>> fetchTvRecommendations(int tvId) async {
    final cacheKey = 'tv_recommendations_$tvId';
    final cached = await LocalCacheDb.instance.getJson(
      cacheKey,
      maxAge: const Duration(hours: 12),
    );

    if (cached != null) {
      final results = cached['results'] as List<dynamic>;
      return results
          .map<TvShow>((json) => TvShow.fromJson(json as Map<String, dynamic>))
          .toList();
    }

    try {
      final response = await _dio.get('/tv/$tvId/recommendations');
      final data = response.data as Map<String, dynamic>;
      await LocalCacheDb.instance.putJson(cacheKey, data);
      final results = data['results'] as List<dynamic>;
      return results
          .map<TvShow>((json) => TvShow.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      // Offline-first: спробувати отримати застарілі дані з кешу
      final staleCached = await LocalCacheDb.instance.getJsonStale(cacheKey);
      if (staleCached != null) {
        final results = staleCached['results'] as List<dynamic>;
        return results
            .map<TvShow>(
              (json) => TvShow.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      }
      throw Exception('Failed to fetch tv recommendations: ${e.message}');
    }
  }

  // Метод для отримання списку жанрів фільмів
  Future<List<Genre>> fetchMovieGenres() async {
    const cacheKey = 'movie_genres';
    final cached = await LocalCacheDb.instance.getJson(
      cacheKey,
      maxAge: const Duration(days: 7),
    );

    if (cached != null) {
      final results = cached['genres'] as List<dynamic>;
      return results
          .map<Genre>((json) => Genre.fromJson(json as Map<String, dynamic>))
          .toList();
    }

    try {
      final response = await _dio.get('/genre/movie/list');
      final data = response.data as Map<String, dynamic>;
      await LocalCacheDb.instance.putJson(cacheKey, data);
      final results = data['genres'] as List<dynamic>;
      return results
          .map<Genre>((json) => Genre.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      // Offline-first: спробувати отримати застарілі дані з кешу
      final staleCached = await LocalCacheDb.instance.getJsonStale(cacheKey);
      if (staleCached != null) {
        final results = staleCached['genres'] as List<dynamic>;
        return results
            .map<Genre>((json) => Genre.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Failed to fetch movie genres: ${e.message}');
    }
  }

  // Метод для отримання списку жанрів серіалів
  Future<List<Genre>> fetchTvGenres() async {
    const cacheKey = 'tv_genres';
    final cached = await LocalCacheDb.instance.getJson(
      cacheKey,
      maxAge: const Duration(days: 7),
    );

    if (cached != null) {
      final results = cached['genres'] as List<dynamic>;
      return results
          .map<Genre>((json) => Genre.fromJson(json as Map<String, dynamic>))
          .toList();
    }

    try {
      final response = await _dio.get('/genre/tv/list');
      final data = response.data as Map<String, dynamic>;
      await LocalCacheDb.instance.putJson(cacheKey, data);
      final results = data['genres'] as List<dynamic>;
      return results
          .map<Genre>((json) => Genre.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      // Offline-first: спробувати отримати застарілі дані з кешу
      final staleCached = await LocalCacheDb.instance.getJsonStale(cacheKey);
      if (staleCached != null) {
        final results = staleCached['genres'] as List<dynamic>;
        return results
            .map<Genre>((json) => Genre.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Failed to fetch tv genres: ${e.message}');
    }
  }

  // Метод для пошуку за назвою (фільми + серіали)
  Future<Map<String, dynamic>> searchByName(
    String query, {
    int page = 1,
  }) async {
    final cacheKey = 'search_multi_${query.toLowerCase()}_page_$page';
    final cached = await LocalCacheDb.instance.getJson(
      cacheKey,
      maxAge: const Duration(minutes: 15),
    );

    if (cached != null) {
      final results = cached['results'] as List<dynamic>;
      final totalPages = cached['total_pages'] as int? ?? 1;

      final List<Movie> movies = [];
      final List<TvShow> tvShows = [];

      for (var item in results) {
        final mediaType = item['media_type'] as String?;
        if (mediaType == 'movie') {
          movies.add(Movie.fromJson(item as Map<String, dynamic>));
        } else if (mediaType == 'tv') {
          tvShows.add(TvShow.fromJson(item as Map<String, dynamic>));
        }
      }

      return {
        'movies': movies,
        'tvShows': tvShows,
        'page': page,
        'totalPages': totalPages,
        'hasMore': page < totalPages,
      };
    }

    try {
      final response = await _dio.get(
        '/search/multi',
        queryParameters: {'query': query, 'page': page},
      );

      final data = response.data as Map<String, dynamic>;
      await LocalCacheDb.instance.putJson(cacheKey, data);
      final results = data['results'] as List<dynamic>;
      final totalPages = data['total_pages'] as int? ?? 1;

      final List<Movie> movies = [];
      final List<TvShow> tvShows = [];

      for (var item in results) {
        final mediaType = item['media_type'] as String?;
        if (mediaType == 'movie') {
          movies.add(Movie.fromJson(item as Map<String, dynamic>));
        } else if (mediaType == 'tv') {
          tvShows.add(TvShow.fromJson(item as Map<String, dynamic>));
        }
      }

      return {
        'movies': movies,
        'tvShows': tvShows,
        'page': page,
        'totalPages': totalPages,
        'hasMore': page < totalPages,
      };
    } on DioException catch (e) {
      // Offline-first: спробувати отримати застарілі дані з кешу
      final staleCached = await LocalCacheDb.instance.getJsonStale(cacheKey);
      if (staleCached != null) {
        final results = staleCached['results'] as List<dynamic>;
        final totalPages = staleCached['total_pages'] as int? ?? 1;

        final List<Movie> movies = [];
        final List<TvShow> tvShows = [];

        for (var item in results) {
          final mediaType = item['media_type'] as String?;
          if (mediaType == 'movie') {
            movies.add(Movie.fromJson(item as Map<String, dynamic>));
          } else if (mediaType == 'tv') {
            tvShows.add(TvShow.fromJson(item as Map<String, dynamic>));
          }
        }

        return {
          'movies': movies,
          'tvShows': tvShows,
          'page': page,
          'totalPages': totalPages,
          'hasMore': page < totalPages,
        };
      }
      throw Exception('Помилка при пошуку: ${e.message}');
    }
  }

  // Метод для пошуку фільмів за фільтрами (з підтримкою пагінації)
  Future<Map<String, dynamic>> searchMovies({
    String? query,
    String? genreName,
    int? year,
    double? rating,
    int page = 1,
  }) async {
    // Створюємо унікальний ключ кешу на основі параметрів
    final cacheKeyParts = <String>['search_movies'];
    if (query != null && query.isNotEmpty) {
      cacheKeyParts.add('query_${query.toLowerCase()}');
    } else {
      if (genreName != null && genreName.isNotEmpty) {
        cacheKeyParts.add('genre_${genreName.toLowerCase()}');
      }
      if (year != null) cacheKeyParts.add('year_$year');
      if (rating != null) cacheKeyParts.add('rating_$rating');
    }
    cacheKeyParts.add('page_$page');
    final cacheKey = cacheKeyParts.join('_');

    final cached = await LocalCacheDb.instance.getJson(
      cacheKey,
      maxAge: const Duration(minutes: 15),
    );

    if (cached != null) {
      final results = cached['results'] as List<dynamic>;
      final totalPages = cached['total_pages'] as int? ?? 1;
      final movies = results
          .map<Movie>((json) => Movie.fromJson(json as Map<String, dynamic>))
          .toList();
      return {
        'movies': movies,
        'page': page,
        'totalPages': totalPages,
        'hasMore': page < totalPages,
      };
    }

    try {
      if (query != null && query.isNotEmpty) {
        // Пошук за назвою
        final response = await _dio.get(
          '/search/movie',
          queryParameters: {'query': query, 'page': page},
        );

        final data = response.data as Map<String, dynamic>;
        await LocalCacheDb.instance.putJson(cacheKey, data);
        final results = data['results'] as List<dynamic>;
        final totalPages = data['total_pages'] as int? ?? 1;
        final movies = results
            .map<Movie>((json) => Movie.fromJson(json as Map<String, dynamic>))
            .toList();
        return {
          'movies': movies,
          'page': page,
          'totalPages': totalPages,
          'hasMore': page < totalPages,
        };
      } else {
        // Пошук за фільтрами через discover
        final queryParams = <String, dynamic>{'page': page};

        if (genreName != null && genreName.isNotEmpty) {
          // Спочатку знаходимо ID жанру за назвою
          final genres = await fetchMovieGenres();
          final genre = genres.firstWhere(
            (g) => g.name.toLowerCase() == genreName.toLowerCase(),
            orElse: () => Genre(id: 0, name: ''),
          );
          if (genre.id != 0) {
            queryParams['with_genres'] = genre.id.toString();
          }
        }
        if (year != null) queryParams['primary_release_year'] = year.toString();
        if (rating != null) queryParams['vote_average.gte'] = rating.toString();

        final response = await _dio.get(
          '/discover/movie',
          queryParameters: queryParams,
        );

        final data = response.data as Map<String, dynamic>;
        await LocalCacheDb.instance.putJson(cacheKey, data);
        final results = data['results'] as List<dynamic>;
        final totalPages = data['total_pages'] as int? ?? 1;
        final movies = results
            .map<Movie>((json) => Movie.fromJson(json as Map<String, dynamic>))
            .toList();
        return {
          'movies': movies,
          'page': page,
          'totalPages': totalPages,
          'hasMore': page < totalPages,
        };
      }
    } on DioException catch (e) {
      // Offline-first: спробувати отримати застарілі дані з кешу
      final staleCached = await LocalCacheDb.instance.getJsonStale(cacheKey);
      if (staleCached != null) {
        final results = staleCached['results'] as List<dynamic>;
        final totalPages = staleCached['total_pages'] as int? ?? 1;
        final movies = results
            .map<Movie>((json) => Movie.fromJson(json as Map<String, dynamic>))
            .toList();
        return {
          'movies': movies,
          'page': page,
          'totalPages': totalPages,
          'hasMore': page < totalPages,
        };
      }
      throw Exception('Помилка при пошуку фільмів: ${e.message}');
    }
  }

  // Метод для пошуку серіалів за фільтрами (з підтримкою пагінації)
  Future<Map<String, dynamic>> searchTvShows({
    String? query,
    String? genreName,
    int? year,
    double? rating,
    int page = 1,
  }) async {
    // Створюємо унікальний ключ кешу на основі параметрів
    final cacheKeyParts = <String>['search_tv_shows'];
    if (query != null && query.isNotEmpty) {
      cacheKeyParts.add('query_${query.toLowerCase()}');
    } else {
      if (genreName != null && genreName.isNotEmpty) {
        cacheKeyParts.add('genre_${genreName.toLowerCase()}');
      }
      if (year != null) cacheKeyParts.add('year_$year');
      if (rating != null) cacheKeyParts.add('rating_$rating');
    }
    cacheKeyParts.add('page_$page');
    final cacheKey = cacheKeyParts.join('_');

    final cached = await LocalCacheDb.instance.getJson(
      cacheKey,
      maxAge: const Duration(minutes: 15),
    );

    if (cached != null) {
      final results = cached['results'] as List<dynamic>;
      final totalPages = cached['total_pages'] as int? ?? 1;
      final tvShows = results
          .map<TvShow>((json) => TvShow.fromJson(json as Map<String, dynamic>))
          .toList();
      return {
        'tvShows': tvShows,
        'page': page,
        'totalPages': totalPages,
        'hasMore': page < totalPages,
      };
    }

    try {
      if (query != null && query.isNotEmpty) {
        // Пошук за назвою
        final response = await _dio.get(
          '/search/tv',
          queryParameters: {'query': query, 'page': page},
        );

        final data = response.data as Map<String, dynamic>;
        await LocalCacheDb.instance.putJson(cacheKey, data);
        final results = data['results'] as List<dynamic>;
        final totalPages = data['total_pages'] as int? ?? 1;
        final tvShows = results
            .map<TvShow>(
              (json) => TvShow.fromJson(json as Map<String, dynamic>),
            )
            .toList();
        return {
          'tvShows': tvShows,
          'page': page,
          'totalPages': totalPages,
          'hasMore': page < totalPages,
        };
      } else {
        // Пошук за фільтрами через discover
        final queryParams = <String, dynamic>{'page': page};

        if (genreName != null && genreName.isNotEmpty) {
          // Спочатку знаходимо ID жанру за назвою
          final genres = await fetchTvGenres();
          final genre = genres.firstWhere(
            (g) => g.name.toLowerCase() == genreName.toLowerCase(),
            orElse: () => Genre(id: 0, name: ''),
          );
          if (genre.id != 0) {
            queryParams['with_genres'] = genre.id.toString();
          }
        }
        if (year != null) queryParams['first_air_date_year'] = year.toString();
        if (rating != null) queryParams['vote_average.gte'] = rating.toString();

        final response = await _dio.get(
          '/discover/tv',
          queryParameters: queryParams,
        );

        final data = response.data as Map<String, dynamic>;
        await LocalCacheDb.instance.putJson(cacheKey, data);
        final results = data['results'] as List<dynamic>;
        final totalPages = data['total_pages'] as int? ?? 1;
        final tvShows = results
            .map<TvShow>(
              (json) => TvShow.fromJson(json as Map<String, dynamic>),
            )
            .toList();
        return {
          'tvShows': tvShows,
          'page': page,
          'totalPages': totalPages,
          'hasMore': page < totalPages,
        };
      }
    } on DioException catch (e) {
      // Offline-first: спробувати отримати застарілі дані з кешу
      final staleCached = await LocalCacheDb.instance.getJsonStale(cacheKey);
      if (staleCached != null) {
        final results = staleCached['results'] as List<dynamic>;
        final totalPages = staleCached['total_pages'] as int? ?? 1;
        final tvShows = results
            .map<TvShow>(
              (json) => TvShow.fromJson(json as Map<String, dynamic>),
            )
            .toList();
        return {
          'tvShows': tvShows,
          'page': page,
          'totalPages': totalPages,
          'hasMore': page < totalPages,
        };
      }
      throw Exception('Помилка при пошуку серіалів: ${e.message}');
    }
  }
}
