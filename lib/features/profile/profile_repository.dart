import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ProfileRepository {
  final String _baseUrl = 'https://api.themoviedb.org/3';
  final String _apiKey = dotenv.env['TMDB_API_KEY']!;

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

class UserProfile {
  final String name;
  final String username;
  final String avatarPath;

  UserProfile({
    required this.name,
    required this.username,
    required this.avatarPath,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      avatarPath: json['avatar']['tmdb']['avatar_path'] ?? '',
    );
  }
}
