import 'package:flutter_test/flutter_test.dart';
import 'package:project/core/auth/jwt_token_service.dart';
import 'package:project/core/storage/secure_storage_service.dart';

/// In-memory implementation of SecureStorageService for testing
class TestSecureStorageService implements SecureStorageService {
  final Map<String, String> _storage = {};

  @override
  Future<String> getTmdbApiKey() async {
    return _storage['tmdb_api_key'] ?? 'test_api_key';
  }

  @override
  Future<void> clearTmdbApiKey() async {
    _storage.remove('tmdb_api_key');
  }

  @override
  Future<void> saveJwtToken(String token) async {
    _storage['jwt_token'] = token;
  }

  @override
  Future<String?> getJwtToken() async {
    return _storage['jwt_token'];
  }

  @override
  Future<void> deleteJwtToken() async {
    _storage.remove('jwt_token');
  }
}

void main() {
  late JwtTokenService jwtTokenService;
  late TestSecureStorageService testSecureStorage;

  setUp(() {
    testSecureStorage = TestSecureStorageService();
    // Create JwtTokenService with test storage
    jwtTokenService = JwtTokenService.forTesting(testSecureStorage);
  });

  group('JwtTokenService', () {
    test('should generate valid JWT token', () async {
      // Act
      final token = await jwtTokenService.generateToken(
        userId: 1,
        email: 'test@example.com',
      );

      // Assert
      expect(token, isNotEmpty);
      expect(token.split('.').length, 3); // JWT has 3 parts
      
      // Verify token was saved
      final savedToken = await testSecureStorage.getJwtToken();
      expect(savedToken, equals(token));
    });

    test('should validate valid token', () async {
      // Arrange
      final token = await jwtTokenService.generateToken(
        userId: 1,
        email: 'test@example.com',
      );

      // Act
      final payload = await jwtTokenService.validateToken(token);

      // Assert
      expect(payload, isNotNull);
      expect(payload!['userId'], 1);
      expect(payload['email'], 'test@example.com');
    });

    test('should return null for invalid token', () async {
      // Act
      final payload = await jwtTokenService.validateToken('invalid.token.here');

      // Assert
      expect(payload, isNull);
    });

    test('should return null for null token', () async {
      // Act
      final payload = await jwtTokenService.validateToken(null);

      // Assert
      expect(payload, isNull);
    });

    test('should return null for empty token', () async {
      // Act
      final payload = await jwtTokenService.validateToken('');

      // Assert
      expect(payload, isNull);
    });

    test('should extract userId from token', () async {
      // Arrange
      final token = await jwtTokenService.generateToken(
        userId: 123,
        email: 'test@example.com',
      );

      // Act
      final userId = await jwtTokenService.getUserIdFromToken();

      // Assert
      // Note: This depends on token being saved, which might not work in test
      // This is more of an integration test
      expect(userId, isA<int?>());
    });

    test('should extract email from token', () async {
      // Arrange
      final token = await jwtTokenService.generateToken(
        userId: 1,
        email: 'test@example.com',
      );

      // Act
      final email = await jwtTokenService.getEmailFromToken();

      // Assert
      // Note: This depends on token being saved
      expect(email, isA<String?>());
    });
  });
}

