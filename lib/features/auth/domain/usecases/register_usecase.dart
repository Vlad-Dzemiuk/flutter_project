import '/core/domain/base_usecase.dart';
import '../../auth_repository.dart';
import '../entities/user.dart';
import '../../data/mappers/user_mapper.dart';

/// Параметри для RegisterUseCase
class RegisterParams {
  final String email;
  final String password;

  const RegisterParams({
    required this.email,
    required this.password,
  });
}

/// Use case для реєстрації нового користувача
/// 
/// Валідує дані та створює нового користувача
/// Повертає domain entity (User), а не data model
class RegisterUseCase implements UseCase<User, RegisterParams> {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  @override
  Future<User> call(RegisterParams params) async {
    // Бізнес-логіка: валідація та реєстрація
    final trimmedEmail = params.email.trim();
    
    if (trimmedEmail.isEmpty) {
      throw Exception('Email не може бути порожнім');
    }
    
    if (params.password.isEmpty) {
      throw Exception('Пароль не може бути порожнім');
    }

    // Валідація формату email
    if (!trimmedEmail.contains('@')) {
      throw Exception('Невірний формат email');
    }

    // Валідація мінімальної довжини пароля
    if (params.password.length < 6) {
      throw Exception('Пароль повинен містити мінімум 6 символів');
    }

    // Виклик репозиторію для реєстрації (повертає data model)
    final localUser = await repository.register(
      email: trimmedEmail,
      password: params.password,
    );

    // Конвертація data model в domain entity
    return UserMapper.toEntity(localUser);
  }
}

