import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FavoritesRepository {
  final String _baseUrl = 'https://api.themoviedb.org/3';
  final String _apiKey = dotenv.env['TMDB_API_KEY']!;

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

class Movie {
  final String title;
  final String posterPath;
  final String overview;

  Movie({required this.title, required this.posterPath, required this.overview});

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      title: json['title'] ?? '',
      posterPath: json['poster_path'] ?? '',
      overview: json['overview'] ?? '',
    );
  }
}
