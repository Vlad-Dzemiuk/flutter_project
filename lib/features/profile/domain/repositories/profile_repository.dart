/// Абстракція репозиторію для профілю
abstract class ProfileRepository {
  Future<UserProfile> getUserProfile(int userId);
}

/// Модель профілю користувача
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
      avatarPath: json['avatar']?['tmdb']?['avatar_path'] ?? '',
    );
  }
}


