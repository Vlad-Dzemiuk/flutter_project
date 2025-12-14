import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:project/features/search/data/repositories/search_repository_impl.dart';
import 'package:project/features/home/home_api_service.dart';
import 'package:project/features/home/data/models/movie_model.dart';

void main() {
  late SearchRepositoryImpl repository;
  late MockHomeApiService mockApiService;

  setUp(() {
    mockApiService = MockHomeApiService();
    repository = SearchRepositoryImpl(mockApiService);
  });

  group('SearchRepositoryImpl', () {
    test(
      'should return list of movies when searchMovies is successful',
      () async {
        // Arrange
        final movies = [
          Movie(
            id: 1,
            title: 'Test Movie 1',
            overview: 'Overview 1',
            posterPath: '/poster1.jpg',
            voteAverage: 8.5,
          ),
          Movie(
            id: 2,
            title: 'Test Movie 2',
            overview: 'Overview 2',
            posterPath: '/poster2.jpg',
            voteAverage: 7.5,
          ),
        ];

        when(
          () => mockApiService.searchMovies(
            genreName: any(named: 'genreName'),
            year: any(named: 'year'),
            rating: any(named: 'rating'),
            page: any(named: 'page'),
          ),
        ).thenAnswer((_) async => {'movies': movies});

        // Act
        final result = await repository.searchMovies(
          genreName: 'Action',
          year: 2020,
          rating: 8.0,
          page: 1,
        );

        // Assert
        expect(result, isA<List<Movie>>());
        expect(result.length, 2);
        expect(result[0].id, 1);
        expect(result[0].title, 'Test Movie 1');
        expect(result[1].id, 2);
        expect(result[1].title, 'Test Movie 2');

        verify(
          () => mockApiService.searchMovies(
            genreName: 'Action',
            year: 2020,
            rating: 8.0,
            page: 1,
          ),
        ).called(1);
      },
    );

    test('should return empty list when no movies found', () async {
      // Arrange
      when(
        () => mockApiService.searchMovies(
          genreName: any(named: 'genreName'),
          year: any(named: 'year'),
          rating: any(named: 'rating'),
          page: any(named: 'page'),
        ),
      ).thenAnswer((_) async => {'movies': <Movie>[]});

      // Act
      final result = await repository.searchMovies();

      // Assert
      expect(result, isEmpty);
    });

    test('should throw exception when API call fails', () async {
      // Arrange
      when(
        () => mockApiService.searchMovies(
          genreName: any(named: 'genreName'),
          year: any(named: 'year'),
          rating: any(named: 'rating'),
          page: any(named: 'page'),
        ),
      ).thenThrow(Exception('Network error'));

      // Act & Assert
      expect(
        () => repository.searchMovies(),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Помилка при пошуку фільмів'),
          ),
        ),
      );
    });

    test('should pass correct parameters to API service', () async {
      // Arrange
      when(
        () => mockApiService.searchMovies(
          genreName: any(named: 'genreName'),
          year: any(named: 'year'),
          rating: any(named: 'rating'),
          page: any(named: 'page'),
        ),
      ).thenAnswer((_) async => {'movies': <Movie>[]});

      // Act
      await repository.searchMovies(
        genreName: 'Drama',
        year: 2021,
        rating: 7.5,
        page: 2,
      );

      // Assert
      verify(
        () => mockApiService.searchMovies(
          genreName: 'Drama',
          year: 2021,
          rating: 7.5,
          page: 2,
        ),
      ).called(1);
    });
  });
}

class MockHomeApiService extends Mock implements HomeApiService {}

