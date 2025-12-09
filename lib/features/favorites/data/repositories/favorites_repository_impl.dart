import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../home/data/models/movie_model.dart';
import '../../domain/repositories/favorites_repository.dart';

/// Реалізація репозиторію для улюблених
class FavoritesRepositoryImpl implements FavoritesRepository {
  final String _baseUrl = 'https://api.themoviedb.org/3';
  final String _apiKey = dotenv.env['TMDB_API_KEY']!;

  @override
  Future<List<Movie>> getFavoriteMovies(int accountId) async {
    final url = Uri.parse('$_baseUrl/account/$accountId/favorite/movies?api_key=$_apiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List results = json.decode(response.body)['results'];
      return results.map((json) => Movie.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load favorite movies');
    }
  }
}

