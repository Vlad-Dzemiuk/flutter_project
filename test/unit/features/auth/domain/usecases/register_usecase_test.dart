import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:project/features/auth/domain/usecases/register_usecase.dart';
import 'package:project/features/auth/auth_repository.dart';
import 'package:project/features/auth/domain/entities/user.dart';
import '../../../../helpers/test_helpers.dart';

void main() {
  late RegisterUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = RegisterUseCase(mockRepository);
  });

  group('RegisterUseCase', () {
    test('should return User when registration is successful', () async {
      // Arrange
      final localUser = TestDataFactory.createLocalUser(
        id: 1,
        email: 'test@example.com',
        displayName: 'Test User',
      );

      when(
        () => mockRepository.register(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => localUser);

      // Act
      final result = await useCase(
        RegisterParams(email: 'test@example.com', password: 'password123'),
      );

      // Assert
      expect(result, isA<User>());
      expect(result.email, 'test@example.com');
      expect(result.id, 1);
      verify(
        () => mockRepository.register(
          email: 'test@example.com',
          password: 'password123',
        ),
      ).called(1);
    });

    test('should trim email before validation', () async {
      // Arrange
      final localUser = TestDataFactory.createLocalUser();

      when(
        () => mockRepository.register(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => localUser);

      // Act
      await useCase(
        RegisterParams(email: '  test@example.com  ', password: 'password123'),
      );

      // Assert
      verify(
        () => mockRepository.register(
          email: 'test@example.com',
          password: 'password123',
        ),
      ).called(1);
    });

    test('should throw exception when email is empty', () async {
      // Act & Assert
      expect(
        () => useCase(RegisterParams(email: '', password: 'password123')),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Email не може бути порожнім'),
          ),
        ),
      );
    });

    test('should throw exception when password is empty', () async {
      // Act & Assert
      expect(
        () => useCase(RegisterParams(email: 'test@example.com', password: '')),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Пароль не може бути порожнім'),
          ),
        ),
      );
    });

    test('should throw exception when email format is invalid', () async {
      // Act & Assert
      expect(
        () => useCase(
          RegisterParams(email: 'invalid-email', password: 'password123'),
        ),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Невірний формат email'),
          ),
        ),
      );
    });

    test('should throw exception when password is too short', () async {
      // Act & Assert
      expect(
        () => useCase(
          RegisterParams(email: 'test@example.com', password: '12345'),
        ),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Пароль повинен містити мінімум 6 символів'),
          ),
        ),
      );
    });

    test('should accept password with 6 characters', () async {
      // Arrange
      final localUser = TestDataFactory.createLocalUser();

      when(
        () => mockRepository.register(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => localUser);

      // Act
      await useCase(
        RegisterParams(email: 'test@example.com', password: '123456'),
      );

      // Assert
      verify(
        () => mockRepository.register(
          email: 'test@example.com',
          password: '123456',
        ),
      ).called(1);
    });
  });
}
