import 'package:flutter_test/flutter_test.dart';
import 'package:project/features/auth/data/mappers/user_mapper.dart';
import 'package:project/features/auth/data/models/local_user.dart';
import 'package:project/features/auth/domain/entities/user.dart';
import '../../../../helpers/test_helpers.dart';

void main() {
  group('UserMapper', () {
    test('should convert LocalUser to User entity', () {
      // Arrange
      final localUser = TestDataFactory.createLocalUser(
        id: 1,
        email: 'test@example.com',
        displayName: 'Test User',
        avatarUrl: 'https://example.com/avatar.jpg',
      );

      // Act
      final user = UserMapper.toEntity(localUser);

      // Assert
      expect(user, isA<User>());
      expect(user.id, 1);
      expect(user.email, 'test@example.com');
      expect(user.displayName, 'Test User');
      expect(user.avatarUrl, 'https://example.com/avatar.jpg');
    });

    test('should convert User entity to LocalUser', () {
      // Arrange
      final user = User(
        id: 1,
        email: 'test@example.com',
        displayName: 'Test User',
        avatarUrl: 'https://example.com/avatar.jpg',
      );

      // Act
      final localUser = UserMapper.toDataModel(user);

      // Assert
      expect(localUser, isA<LocalUser>());
      expect(localUser.id, 1);
      expect(localUser.email, 'test@example.com');
      expect(localUser.displayName, 'Test User');
      expect(localUser.avatarUrl, 'https://example.com/avatar.jpg');
    });

    test('should handle null displayName and avatarUrl', () {
      // Arrange
      final localUser = LocalUser(
        id: 1,
        email: 'test@example.com',
        displayName: null,
        avatarUrl: null,
      );

      // Act
      final user = UserMapper.toEntity(localUser);

      // Assert
      expect(user.displayName, isNull);
      expect(user.avatarUrl, isNull);
    });
  });
}

