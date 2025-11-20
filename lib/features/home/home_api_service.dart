import 'dart:convert';
import 'package:http/http.dart' as http;
import 'movie_model.dart';
import 'tv_show_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class HomeApiService {
  final String baseUrl = 'https://api.themoviedb.org/3';
  final String apiKey = dotenv.env['TMDB_API_KEY'] ?? '';

  // Метод для отримання популярних фільмів
  Future<List<Movie>> fetchPopularMovies({int page = 1}) async {
    final url = Uri.parse('$baseUrl/movie/popular?api_key=$apiKey&language=en-US&page=$page');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>;
      return results.map<Movie>((json) => Movie.fromJson(json as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to fetch movies');
    }
  }

  Future<List<Movie>> fetchAllMovies({int page = 1}) async {
    final url = Uri.parse('$baseUrl/discover/movie?api_key=$apiKey&language=en-US&sort_by=popularity.desc&page=$page');
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
    final url = Uri.parse('$baseUrl/tv/popular?api_key=$apiKey&language=en-US&page=$page');
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
    final url = Uri.parse('$baseUrl/discover/tv?api_key=$apiKey&language=en-US&sort_by=popularity.desc&page=$page');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>;
      return results.map<TvShow>((json) => TvShow.fromJson(json as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to fetch tv catalog');
    }
  }

  // Метод для пошуку фільмів за фільтрами
  Future<List<Movie>> searchMovies({
    String? genre,
    int? year,
    double? rating,
  }) async {
    final queryParams = <String, String>{
      'api_key': apiKey,
      'language': 'en-US',
    };

    if (genre != null && genre.isNotEmpty) queryParams['with_genres'] = genre;
    if (year != null) queryParams['primary_release_year'] = year.toString();
    if (rating != null) queryParams['vote_average.gte'] = rating.toString();

    final uri = Uri.https('api.themoviedb.org', '/3/discover/movie', queryParams);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>;
      return results.map<Movie>((json) => Movie.fromJson(json as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Помилка при пошуку фільмів');
    }
  }
}
