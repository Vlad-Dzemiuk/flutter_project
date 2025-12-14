import '../../../../core/domain/base_usecase.dart';
import '../../auth_repository.dart';
import '../entities/user.dart';
import '../../data/mappers/user_mapper.dart';

/// Параметри для SignInUseCase
class SignInParams {
  final String email;
  final String password;

  const SignInParams({required this.email, required this.password});
}

/// Use case для входу користувача
///
/// Валідує email та пароль, виконує авторизацію
/// Повертає domain entity (User), а не data model
class SignInUseCase implements UseCase<User, SignInParams> {
  final AuthRepository repository;

  SignInUseCase(this.repository);

  @override
  Future<User> call(SignInParams params) async {
    // Бізнес-логіка: валідація та авторизація
    final trimmedEmail = params.email.trim();

    if (trimmedEmail.isEmpty) {
      throw Exception('Email не може бути порожнім');
    }

    if (params.password.isEmpty) {
      throw Exception('Пароль не може бути порожнім');
    }

    // Валідація формату email (базова перевірка)
    if (!trimmedEmail.contains('@')) {
      throw Exception('Невірний формат email');
    }

    // Виклик репозиторію для авторизації (повертає data model)
    final localUser = await repository.signIn(
      email: trimmedEmail,
      password: params.password,
    );

    // Конвертація data model в domain entity
    return UserMapper.toEntity(localUser);
  }
}
