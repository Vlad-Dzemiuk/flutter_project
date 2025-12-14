import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:project/features/profile/domain/usecases/get_user_profile_usecase.dart';
import 'package:project/features/profile/domain/repositories/profile_repository.dart';
import '../../../../helpers/test_helpers.dart';

void main() {
  late GetUserProfileUseCase useCase;
  late MockProfileRepository mockRepository;

  setUp(() {
    mockRepository = MockProfileRepository();
    useCase = GetUserProfileUseCase(mockRepository);
  });

  group('GetUserProfileUseCase', () {
    test('should return UserProfile when successful', () async {
      // Arrange
      final profile = UserProfile(
        name: 'Test User',
        username: 'testuser',
        avatarPath: '/avatar.jpg',
      );

      when(() => mockRepository.getUserProfile(any()))
          .thenAnswer((_) async => profile);

      // Act
      final result = await useCase(const GetUserProfileParams(userId: 1));

      // Assert
      expect(result, isA<UserProfile>());
      expect(result.name, 'Test User');
      expect(result.username, 'testuser');
      expect(result.avatarPath, '/avatar.jpg');
      verify(() => mockRepository.getUserProfile(1)).called(1);
    });

    test('should throw exception when userId is invalid', () async {
      // Act & Assert
      expect(
        () => useCase(const GetUserProfileParams(userId: 0)),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Невірний ID користувача'),
        )),
      );
      expect(
        () => useCase(const GetUserProfileParams(userId: -1)),
        throwsA(isA<Exception>()),
      );
      verifyNever(() => mockRepository.getUserProfile(any()));
    });
  });
}

