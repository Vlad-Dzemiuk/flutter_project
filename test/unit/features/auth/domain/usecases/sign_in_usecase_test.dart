import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:project/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:project/features/auth/auth_repository.dart';
import 'package:project/features/auth/data/models/local_user.dart';
import 'package:project/features/auth/domain/entities/user.dart';
import '../../../../helpers/test_helpers.dart';

void main() {
  late SignInUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = SignInUseCase(mockRepository);
  });

  group('SignInUseCase', () {
    test('should return User when sign in is successful', () async {
      // Arrange
      final localUser = TestDataFactory.createLocalUser(
        id: 1,
        email: 'test@example.com',
        displayName: 'Test User',
      );

      when(
        () => mockRepository.signIn(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => localUser);

      // Act
      final result = await useCase(
        SignInParams(email: 'test@example.com', password: 'password123'),
      );

      // Assert
      expect(result, isA<User>());
      expect(result.email, 'test@example.com');
      expect(result.id, 1);
      verify(
        () => mockRepository.signIn(
          email: 'test@example.com',
          password: 'password123',
        ),
      ).called(1);
    });

    test('should trim email before validation', () async {
      // Arrange
      final localUser = TestDataFactory.createLocalUser();

      when(
        () => mockRepository.signIn(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => localUser);

      // Act
      await useCase(
        SignInParams(email: '  test@example.com  ', password: 'password123'),
      );

      // Assert
      verify(
        () => mockRepository.signIn(
          email: 'test@example.com',
          password: 'password123',
        ),
      ).called(1);
    });

    test('should throw exception when email is empty', () async {
      // Act & Assert
      expect(
        () => useCase(SignInParams(email: '', password: 'password123')),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Email не може бути порожнім'),
          ),
        ),
      );
      verifyNever(
        () => mockRepository.signIn(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      );
    });

    test('should throw exception when email is only whitespace', () async {
      // Act & Assert
      expect(
        () => useCase(SignInParams(email: '   ', password: 'password123')),
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
        () => useCase(SignInParams(email: 'test@example.com', password: '')),
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
          SignInParams(email: 'invalid-email', password: 'password123'),
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

    test('should throw exception when repository throws error', () async {
      // Arrange
      when(
        () => mockRepository.signIn(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(Exception('Network error'));

      // Act & Assert
      expect(
        () => useCase(
          SignInParams(email: 'test@example.com', password: 'password123'),
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
