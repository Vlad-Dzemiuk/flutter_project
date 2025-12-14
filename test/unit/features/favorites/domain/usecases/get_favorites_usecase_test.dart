import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:project/features/favorites/domain/usecases/get_favorites_usecase.dart';
import '../../../../helpers/test_helpers.dart';

void main() {
  late GetFavoritesUseCase useCase;
  late MockFavoritesRepository mockRepository;

  setUp(() {
    mockRepository = MockFavoritesRepository();
    useCase = GetFavoritesUseCase(mockRepository);
  });

  group('GetFavoritesUseCase', () {
    test('should return sorted list of favorite movies', () async {
      // Arrange
      final movies = [
        TestDataFactory.createMovie(id: 2, title: 'B Movie'),
        TestDataFactory.createMovie(id: 1, title: 'A Movie'),
        TestDataFactory.createMovie(id: 3, title: 'C Movie'),
      ];

      when(
        () => mockRepository.getFavoriteMovies(any()),
      ).thenAnswer((_) async => movies);

      // Act
      final result = await useCase(const GetFavoritesParams(accountId: 1));

      // Assert
      expect(result.length, 3);
      expect(result[0].title, 'A Movie');
      expect(result[1].title, 'B Movie');
      expect(result[2].title, 'C Movie');
      verify(() => mockRepository.getFavoriteMovies(1)).called(1);
    });

    test('should throw exception when accountId is invalid', () async {
      // Act & Assert
      expect(
        () => useCase(const GetFavoritesParams(accountId: 0)),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Невірний ID акаунта'),
          ),
        ),
      );
      expect(
        () => useCase(const GetFavoritesParams(accountId: -1)),
        throwsA(isA<Exception>()),
      );
    });
  });
}
