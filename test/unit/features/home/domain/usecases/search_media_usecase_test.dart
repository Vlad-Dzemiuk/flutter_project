import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:project/features/home/domain/usecases/search_media_usecase.dart';
import 'package:project/features/home/home_repository.dart';
import 'package:project/features/home/data/models/movie_model.dart';
import 'package:project/features/home/data/models/tv_show_model.dart';
import '../../../../helpers/test_helpers.dart';

void main() {
  late SearchMediaUseCase useCase;
  late MockHomeRepository mockRepository;

  setUp(() {
    mockRepository = MockHomeRepository();
    useCase = SearchMediaUseCase(mockRepository);
  });

  group('SearchMediaUseCase', () {
    test('should search by name when query is provided', () async {
      // Arrange
      final movies = [TestDataFactory.createMovie(id: 1, title: 'Test Movie')];
      final tvShows = [TestDataFactory.createTvShow(id: 1, name: 'Test TV')];

      when(
        () => mockRepository.searchByName(any(), page: any(named: 'page')),
      ).thenAnswer(
        (_) async => {'movies': movies, 'tvShows': tvShows, 'hasMore': false},
      );

      // Act
      final result = await useCase(SearchMediaParams(query: 'test', page: 1));

      // Assert
      expect(result.results.length, 2);
      expect(result.hasMore, false);
      verify(() => mockRepository.searchByName('test', page: 1)).called(1);
      verifyNever(
        () => mockRepository.searchMovies(
          genreName: any(named: 'genreName'),
          year: any(named: 'year'),
          rating: any(named: 'rating'),
          page: any(named: 'page'),
        ),
      );
    });

    test('should search by filters when query is not provided', () async {
      // Arrange
      final movies = [TestDataFactory.createMovie(id: 1)];
      final tvShows = [TestDataFactory.createTvShow(id: 1)];

      when(
        () => mockRepository.searchMovies(
          genreName: any(named: 'genreName'),
          year: any(named: 'year'),
          rating: any(named: 'rating'),
          page: any(named: 'page'),
        ),
      ).thenAnswer(
        (_) async =>
            {'movies': movies, 'hasMore': false} as Map<String, dynamic>,
      );

      when(
        () => mockRepository.searchTvShows(
          genreName: any(named: 'genreName'),
          year: any(named: 'year'),
          rating: any(named: 'rating'),
          page: any(named: 'page'),
        ),
      ).thenAnswer(
        (_) async =>
            {'tvShows': tvShows, 'hasMore': false} as Map<String, dynamic>,
      );

      // Act
      final result = await useCase(
        SearchMediaParams(
          genreName: 'Action',
          year: 2020,
          rating: 8.0,
          page: 1,
        ),
      );

      // Assert
      expect(result.results.length, 2);
      expect(result.hasMore, false);
      verify(
        () => mockRepository.searchMovies(
          genreName: 'Action',
          year: 2020,
          rating: 8.0,
          page: 1,
        ),
      ).called(1);
      verify(
        () => mockRepository.searchTvShows(
          genreName: 'Action',
          year: 2020,
          rating: 8.0,
          page: 1,
        ),
      ).called(1);
    });

    test(
      'should set hasMore to true when either movies or tv shows have more',
      () async {
        // Arrange
        when(
          () => mockRepository.searchMovies(
            genreName: any(named: 'genreName'),
            year: any(named: 'year'),
            rating: any(named: 'rating'),
            page: any(named: 'page'),
          ),
        ).thenAnswer((_) async => {'movies': <Movie>[], 'hasMore': true});

        when(
          () => mockRepository.searchTvShows(
            genreName: any(named: 'genreName'),
            year: any(named: 'year'),
            rating: any(named: 'rating'),
            page: any(named: 'page'),
          ),
        ).thenAnswer((_) async => {'tvShows': <TvShow>[], 'hasMore': false});

        // Act
        final result = await useCase(SearchMediaParams(genreName: 'Action'));

        // Assert
        expect(result.hasMore, true);
      },
    );

    test('should combine movies and tv shows in results', () async {
      // Arrange
      final movies = [
        TestDataFactory.createMovie(id: 1, title: 'Movie 1'),
        TestDataFactory.createMovie(id: 2, title: 'Movie 2'),
      ];
      final tvShows = [TestDataFactory.createTvShow(id: 3, name: 'TV 1')];

      when(
        () => mockRepository.searchByName(any(), page: any(named: 'page')),
      ).thenAnswer(
        (_) async => {'movies': movies, 'tvShows': tvShows, 'hasMore': false},
      );

      // Act
      final result = await useCase(SearchMediaParams(query: 'test'));

      // Assert
      expect(result.results.length, 3);
      expect(result.results[0].title, 'Movie 1');
      expect(result.results[1].title, 'Movie 2');
      expect(result.results[2].title, 'TV 1');
    });
  });
}
