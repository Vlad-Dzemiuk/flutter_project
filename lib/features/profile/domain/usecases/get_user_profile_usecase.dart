import '../../../../core/domain/base_usecase.dart';
import '../repositories/profile_repository.dart';

/// Параметри для GetUserProfileUseCase
class GetUserProfileParams {
  final int userId;

  const GetUserProfileParams({required this.userId});
}

/// Use case для отримання профілю користувача
/// 
/// Валідує userId та завантажує профіль користувача
class GetUserProfileUseCase
    implements UseCase<UserProfile, GetUserProfileParams> {
  final ProfileRepository repository;

  GetUserProfileUseCase(this.repository);

  @override
  Future<UserProfile> call(GetUserProfileParams params) async {
    // Бізнес-логіка: валідація та завантаження профілю
    if (params.userId <= 0) {
      throw Exception('Невірний ID користувача');
    }

    // Виклик репозиторію для отримання профілю
    final profile = await repository.getUserProfile(params.userId);

    return profile;
  }
}


