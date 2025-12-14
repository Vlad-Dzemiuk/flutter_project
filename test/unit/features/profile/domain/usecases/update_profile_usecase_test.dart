import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:project/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:project/features/auth/auth_repository.dart';
import 'package:project/features/auth/data/models/local_user.dart';
import '../../../../helpers/test_helpers.dart';

void main() {
  late UpdateProfileUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = UpdateProfileUseCase(mockRepository);
  });

  group('UpdateProfileUseCase', () {
    test('should update profile successfully', () async {
      // Arrange
      final currentUser = TestDataFactory.createLocalUser();
      final updatedUser = TestDataFactory.createLocalUser(
        displayName: 'Updated Name',
      );

      when(() => mockRepository.currentUser).thenReturn(currentUser);
      when(
        () => mockRepository.updateProfile(
          displayName: any(named: 'displayName'),
          clearDisplayName: any(named: 'clearDisplayName'),
          avatarUrl: any(named: 'avatarUrl'),
          clearAvatar: any(named: 'clearAvatar'),
        ),
      ).thenAnswer((_) async => updatedUser);

      // Act
      final result = await useCase(
        UpdateProfileParams(displayName: 'Updated Name'),
      );

      // Assert
      expect(result.displayName, 'Updated Name');
      verify(
        () => mockRepository.updateProfile(
          displayName: 'Updated Name',
          clearDisplayName: false,
          avatarUrl: null,
          clearAvatar: false,
        ),
      ).called(1);
    });

    test('should throw exception when user is not authenticated', () async {
      // Arrange
      when(() => mockRepository.currentUser).thenReturn(null);

      // Act & Assert
      expect(
        () => useCase(UpdateProfileParams(displayName: 'Test')),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Користувач не авторизований'),
          ),
        ),
      );
    });

    test('should throw exception when displayName is empty', () async {
      // Arrange
      final currentUser = TestDataFactory.createLocalUser();
      when(() => mockRepository.currentUser).thenReturn(currentUser);

      // Act & Assert
      expect(
        () => useCase(UpdateProfileParams(displayName: '   ')),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Ім\'я не може бути порожнім'),
          ),
        ),
      );
    });

    test('should throw exception when displayName is too long', () async {
      // Arrange
      final currentUser = TestDataFactory.createLocalUser();
      when(() => mockRepository.currentUser).thenReturn(currentUser);
      final longName = 'a' * 51;

      // Act & Assert
      expect(
        () => useCase(UpdateProfileParams(displayName: longName)),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Ім\'я не може перевищувати 50 символів'),
          ),
        ),
      );
    });

    test('should validate URL format for avatarUrl', () async {
      // Arrange
      final currentUser = TestDataFactory.createLocalUser();
      final updatedUser = TestDataFactory.createLocalUser();
      when(() => mockRepository.currentUser).thenReturn(currentUser);
      when(
        () => mockRepository.updateProfile(
          displayName: any(named: 'displayName'),
          clearDisplayName: any(named: 'clearDisplayName'),
          avatarUrl: any(named: 'avatarUrl'),
          clearAvatar: any(named: 'clearAvatar'),
        ),
      ).thenAnswer((_) async => updatedUser);

      // Act
      await useCase(
        UpdateProfileParams(avatarUrl: 'https://example.com/avatar.jpg'),
      );

      // Assert
      verify(
        () => mockRepository.updateProfile(
          displayName: null,
          clearDisplayName: false,
          avatarUrl: 'https://example.com/avatar.jpg',
          clearAvatar: false,
        ),
      ).called(1);
    });

    test('should allow local file paths for avatarUrl', () async {
      // Arrange
      final currentUser = TestDataFactory.createLocalUser();
      final updatedUser = TestDataFactory.createLocalUser();
      when(() => mockRepository.currentUser).thenReturn(currentUser);
      when(
        () => mockRepository.updateProfile(
          displayName: any(named: 'displayName'),
          clearDisplayName: any(named: 'clearDisplayName'),
          avatarUrl: any(named: 'avatarUrl'),
          clearAvatar: any(named: 'clearAvatar'),
        ),
      ).thenAnswer((_) async => updatedUser);

      // Act
      await useCase(
        UpdateProfileParams(avatarUrl: '/local/path/to/avatar.jpg'),
      );

      // Assert
      verify(
        () => mockRepository.updateProfile(
          displayName: null,
          clearDisplayName: false,
          avatarUrl: '/local/path/to/avatar.jpg',
          clearAvatar: false,
        ),
      ).called(1);
    });
  });
}
