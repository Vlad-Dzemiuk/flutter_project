import 'dart:convert';
import 'package:http/http.dart' as http;
import 'movie_model.dart';
import 'tv_show_model.dart';
import 'genre_model.dart';
import 'package:project/core/storage/local_cache_db.dart';
import 'package:project/core/storage/secure_storage_service.dart';

class HomeApiService {
  final String baseUrl = 'https://api.themoviedb.org/3';

  Future<String> _getApiKey() =>
      SecureStorageService.instance.getTmdbApiKey();

  // Метод для отримання популярних фільмів
  Future<List<Movie>> fetchPopularMovies({int page = 1}) async {
    final cacheKey = 'popular_movies_page_$page';
    final cached =
        await LocalCacheDb.instance.getJson(cacheKey, maxAge: const Duration(minutes: 30));

    if (cached != null) {
      final results = cached['results'] as List<dynamic>;
      return results
          .map<Movie>((json) => Movie.fromJson(json as Map<String, dynamic>))
          .toList();
    }

    final apiKey = await _getApiKey();
    final url = Uri.parse(
        '$baseUrl/movie/popular?api_key=$apiKey&language=en-US&page=$page');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      await LocalCacheDb.instance.putJson(cacheKey, data);
      final results = data['results'] as List<dynamic>;
      return results
          .map<Movie>((json) => Movie.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to fetch movies');
    }
  }

  Future<List<Movie>> fetchAllMovies({int page = 1}) async {
    final apiKey = await _getApiKey();
    final url = Uri.parse(
        '$baseUrl/discover/movie?api_key=$apiKey&language=en-US&sort_by=popularity.desc&page=$page');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>;
      return results.map<Movie>((json) => Movie.fromJson(json as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to fetch movies catalog');
    }
  }

  Future<List<TvShow>> fetchPopularTvShows({int page = 1}) async {
    final apiKey = await _getApiKey();
    final url = Uri.parse(
        '$baseUrl/tv/popular?api_key=$apiKey&language=en-US&page=$page');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>;
      return results.map<TvShow>((json) => TvShow.fromJson(json as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to fetch tv shows');
    }
  }

  Future<List<TvShow>> fetchAllTvShows({int page = 1}) async {
    final apiKey = await _getApiKey();
    final url = Uri.parse(
        '$baseUrl/discover/tv?api_key=$apiKey&language=en-US&sort_by=popularity.desc&page=$page');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>;
      return results.map<TvShow>((json) => TvShow.fromJson(json as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to fetch tv catalog');
    }
  }


  // ===== Деталі фільму / серіалу, відео, відгуки, рекомендації =====

  Future<Map<String, dynamic>> fetchMovieDetails(int movieId) async {
    final apiKey = await _getApiKey();
    final url =
        Uri.parse('$baseUrl/movie/$movieId?api_key=$apiKey&language=en-US');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to fetch movie details');
    }
  }

  Future<Map<String, dynamic>> fetchTvDetails(int tvId) async {
    final apiKey = await _getApiKey();
    final url = Uri.parse('$baseUrl/tv/$tvId?api_key=$apiKey&language=en-US');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to fetch tv details');
    }
  }

  Future<List<dynamic>> fetchMovieVideos(int movieId) async {
    final apiKey = await _getApiKey();
    final url = Uri.parse(
      '$baseUrl/movie/$movieId/videos?api_key=$apiKey&language=en-US&include_video_language=en,null,uk,ru',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return (data['results'] as List<dynamic>);
    } else {
      throw Exception('Failed to fetch movie videos');
    }
  }

  Future<List<dynamic>> fetchTvVideos(int tvId) async {
    final apiKey = await _getApiKey();
    final url = Uri.parse(
      '$baseUrl/tv/$tvId/videos?api_key=$apiKey&language=en-US&include_video_language=en,null,uk,ru',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return (data['results'] as List<dynamic>);
    } else {
      throw Exception('Failed to fetch tv videos');
    }
  }

  Future<List<dynamic>> fetchMovieReviews(int movieId) async {
    final apiKey = await _getApiKey();
    final url = Uri.parse(
        '$baseUrl/movie/$movieId/reviews?api_key=$apiKey&language=en-US');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return (data['results'] as List<dynamic>);
    } else {
      throw Exception('Failed to fetch movie reviews');
    }
  }

  Future<List<dynamic>> fetchTvReviews(int tvId) async {
    final apiKey = await _getApiKey();
    final url =
        Uri.parse('$baseUrl/tv/$tvId/reviews?api_key=$apiKey&language=en-US');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return (data['results'] as List<dynamic>);
    } else {
      throw Exception('Failed to fetch tv reviews');
    }
  }

  Future<List<Movie>> fetchMovieRecommendations(int movieId) async {
    final apiKey = await _getApiKey();
    final url = Uri.parse(
        '$baseUrl/movie/$movieId/recommendations?api_key=$apiKey&language=en-US');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>;
      return results.map<Movie>((json) => Movie.fromJson(json as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to fetch movie recommendations');
    }
  }

  Future<List<TvShow>> fetchTvRecommendations(int tvId) async {
    final apiKey = await _getApiKey();
    final url = Uri.parse(
        '$baseUrl/tv/$tvId/recommendations?api_key=$apiKey&language=en-US');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>;
      return results.map<TvShow>((json) => TvShow.fromJson(json as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to fetch tv recommendations');
    }
  }

  // Метод для отримання списку жанрів фільмів
  Future<List<Genre>> fetchMovieGenres() async {
    final apiKey = await _getApiKey();
    final url = Uri.parse(
        '$baseUrl/genre/movie/list?api_key=$apiKey&language=en-US');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final results = data['genres'] as List<dynamic>;
      return results.map<Genre>((json) => Genre.fromJson(json as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to fetch movie genres');
    }
  }

  // Метод для отримання списку жанрів серіалів
  Future<List<Genre>> fetchTvGenres() async {
    final apiKey = await _getApiKey();
    final url =
        Uri.parse('$baseUrl/genre/tv/list?api_key=$apiKey&language=en-US');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final results = data['genres'] as List<dynamic>;
      return results.map<Genre>((json) => Genre.fromJson(json as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to fetch tv genres');
    }
  }

  // Метод для пошуку за назвою (фільми + серіали)
  Future<Map<String, dynamic>> searchByName(String query, {int page = 1}) async {
    final apiKey = await _getApiKey();
    final url = Uri.parse(
        '$baseUrl/search/multi?api_key=$apiKey&language=en-US&query=${Uri.encodeComponent(query)}&page=$page');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
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
    } else {
      throw Exception('Помилка при пошуку');
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
    final queryParams = <String, String>{
      'api_key': await _getApiKey(),
      'language': 'en-US',
      'page': page.toString(),
    };

    if (query != null && query.isNotEmpty) {
      // Пошук за назвою
      final apiKey = await _getApiKey();
      final url = Uri.parse(
          '$baseUrl/search/movie?api_key=$apiKey&language=en-US&query=${Uri.encodeComponent(query)}&page=$page');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>;
        final totalPages = data['total_pages'] as int? ?? 1;
        final movies = results.map<Movie>((json) => Movie.fromJson(json as Map<String, dynamic>)).toList();
        return {
          'movies': movies,
          'page': page,
          'totalPages': totalPages,
          'hasMore': page < totalPages,
        };
      } else {
        throw Exception('Помилка при пошуку фільмів');
      }
    } else {
      // Пошук за фільтрами через discover
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

      final uri = Uri.https('api.themoviedb.org', '/3/discover/movie', queryParams);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>;
        final totalPages = data['total_pages'] as int? ?? 1;
        final movies = results.map<Movie>((json) => Movie.fromJson(json as Map<String, dynamic>)).toList();
        return {
          'movies': movies,
          'page': page,
          'totalPages': totalPages,
          'hasMore': page < totalPages,
        };
      } else {
        throw Exception('Помилка при пошуку фільмів');
      }
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
    final queryParams = <String, String>{
      'api_key': await _getApiKey(),
      'language': 'en-US',
      'page': page.toString(),
    };

    if (query != null && query.isNotEmpty) {
      // Пошук за назвою
      final apiKey = await _getApiKey();
      final url = Uri.parse(
          '$baseUrl/search/tv?api_key=$apiKey&language=en-US&query=${Uri.encodeComponent(query)}&page=$page');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>;
        final totalPages = data['total_pages'] as int? ?? 1;
        final tvShows = results.map<TvShow>((json) => TvShow.fromJson(json as Map<String, dynamic>)).toList();
        return {
          'tvShows': tvShows,
          'page': page,
          'totalPages': totalPages,
          'hasMore': page < totalPages,
        };
      } else {
        throw Exception('Помилка при пошуку серіалів');
      }
    } else {
      // Пошук за фільтрами через discover
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

      final uri = Uri.https('api.themoviedb.org', '/3/discover/tv', queryParams);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>;
        final totalPages = data['total_pages'] as int? ?? 1;
        final tvShows = results.map<TvShow>((json) => TvShow.fromJson(json as Map<String, dynamic>)).toList();
        return {
          'tvShows': tvShows,
          'page': page,
          'totalPages': totalPages,
          'hasMore': page < totalPages,
        };
      } else {
        throw Exception('Помилка при пошуку серіалів');
      }
    }
  }
}
