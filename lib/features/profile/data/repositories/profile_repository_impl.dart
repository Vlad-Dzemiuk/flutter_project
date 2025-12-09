import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../domain/repositories/profile_repository.dart';

/// Реалізація репозиторію для профілю
class ProfileRepositoryImpl implements ProfileRepository {
  final String _baseUrl = 'https://api.themoviedb.org/3';
  final String _apiKey = dotenv.env['TMDB_API_KEY']!;

  @override
  Future<UserProfile> getUserProfile(int userId) async {
    final url = Uri.parse('$_baseUrl/account/$userId?api_key=$_apiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return UserProfile.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load profile');
    }
  }
}

