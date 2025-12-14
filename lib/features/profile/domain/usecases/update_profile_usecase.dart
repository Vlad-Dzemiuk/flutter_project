import '../../../auth/auth_repository.dart';
import '../../../../core/domain/base_usecase.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/data/mappers/user_mapper.dart';

/// Параметри для UpdateProfileUseCase
class UpdateProfileParams {
  final String? displayName;
  final bool clearDisplayName;
  final String? avatarUrl;
  final bool clearAvatar;

  const UpdateProfileParams({
    this.displayName,
    this.clearDisplayName = false,
    this.avatarUrl,
    this.clearAvatar = false,
  });
}

/// Use case для оновлення профілю користувача
/// 
/// Валідує дані та оновлює профіль користувача
/// Повертає domain entity (User), а не data model
class UpdateProfileUseCase
    implements UseCase<User, UpdateProfileParams> {
  final AuthRepository repository;

  UpdateProfileUseCase(this.repository);

  @override
  Future<User> call(UpdateProfileParams params) async {
    // Бізнес-логіка: валідація та оновлення профілю
    
    // Перевірка, чи користувач авторизований
    if (repository.currentUser == null) {
      throw Exception('Користувач не авторизований');
    }

    // Валідація displayName (якщо вказано)
    if (params.displayName != null && params.displayName!.trim().isEmpty) {
      throw Exception('Ім\'я не може бути порожнім');
    }

    // Валідація довжини displayName
    if (params.displayName != null && params.displayName!.length > 50) {
      throw Exception('Ім\'я не може перевищувати 50 символів');
    }

    // Валідація URL аватара (тільки для URL, не для локальних файлів)
    // Якщо avatarUrl вказано і це не локальний файл (починається з http/https),
    // то валідуємо формат URL
    if (params.avatarUrl != null && 
        params.avatarUrl!.isNotEmpty &&
        (params.avatarUrl!.startsWith('http://') || params.avatarUrl!.startsWith('https://'))) {
      // Додаткова валідація URL (опціонально)
      try {
        Uri.parse(params.avatarUrl!);
      } catch (e) {
        throw Exception('Невірний формат URL аватара');
      }
    }
    // Якщо avatarUrl - це локальний файл (не починається з http/https),
    // то валідацію не виконуємо, оскільки це шлях до файлу

    // Виклик репозиторію для оновлення профілю (повертає data model)
    final updatedLocalUser = await repository.updateProfile(
      displayName: params.displayName?.trim(),
      clearDisplayName: params.clearDisplayName,
      avatarUrl: params.avatarUrl,
      clearAvatar: params.clearAvatar,
    );

    // Конвертація data model в domain entity
    return UserMapper.toEntity(updatedLocalUser);
  }
}

