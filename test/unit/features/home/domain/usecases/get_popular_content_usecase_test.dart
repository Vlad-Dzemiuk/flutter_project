import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:project/features/home/domain/usecases/get_popular_content_usecase.dart';
import 'package:project/features/home/home_repository.dart';
import 'package:project/features/home/data/models/movie_model.dart';
import 'package:project/features/home/data/models/tv_show_model.dart';
import '../../../../helpers/test_helpers.dart';

void main() {
  late GetPopularContentUseCase useCase;
  late MockHomeRepository mockRepository;

  setUp(() {
    mockRepository = MockHomeRepository();
    useCase = GetPopularContentUseCase(mockRepository);
  });

  group('GetPopularContentUseCase', () {
    test('should return PopularContentResult with all content', () async {
      // Arrange
      final movies = [
        TestDataFactory.createMovie(id: 1, title: 'Movie 1'),
        TestDataFactory.createMovie(id: 2, title: 'Movie 2'),
      ];
      final tvShows = [
        TestDataFactory.createTvShow(id: 1, name: 'TV Show 1'),
        TestDataFactory.createTvShow(id: 2, name: 'TV Show 2'),
      ];

      when(
        () => mockRepository.fetchPopularMovies(page: any(named: 'page')),
      ).thenAnswer((_) async => movies);
      when(
        () => mockRepository.fetchPopularTvShows(page: any(named: 'page')),
      ).thenAnswer((_) async => tvShows);
      when(
        () => mockRepository.fetchAllMovies(page: any(named: 'page')),
      ).thenAnswer((_) async => movies);
      when(
        () => mockRepository.fetchAllTvShows(page: any(named: 'page')),
      ).thenAnswer((_) async => tvShows);

      // Act
      final result = await useCase(const GetPopularContentParams(page: 1));

      // Assert
      expect(result, isA<PopularContentResult>());
      expect(result.popularMovies.length, 2);
      expect(result.popularTvShows.length, 2);
      expect(result.allMovies.length, 2);
      expect(result.allTvShows.length, 2);
      expect(result.popularMovies.first.title, 'Movie 1');
      expect(result.popularTvShows.first.title, 'TV Show 1');
    });

    test('should use default page 1 when page is not specified', () async {
      // Arrange
      when(
        () => mockRepository.fetchPopularMovies(page: any(named: 'page')),
      ).thenAnswer((_) async => []);
      when(
        () => mockRepository.fetchPopularTvShows(page: any(named: 'page')),
      ).thenAnswer((_) async => []);
      when(
        () => mockRepository.fetchAllMovies(page: any(named: 'page')),
      ).thenAnswer((_) async => []);
      when(
        () => mockRepository.fetchAllTvShows(page: any(named: 'page')),
      ).thenAnswer((_) async => []);

      // Act
      await useCase(const GetPopularContentParams());

      // Assert
      verify(() => mockRepository.fetchPopularMovies(page: 1)).called(1);
      verify(() => mockRepository.fetchPopularTvShows(page: 1)).called(1);
      verify(() => mockRepository.fetchAllMovies(page: 1)).called(1);
      verify(() => mockRepository.fetchAllTvShows(page: 1)).called(1);
    });

    test('should use specified page number', () async {
      // Arrange
      when(
        () => mockRepository.fetchPopularMovies(page: any(named: 'page')),
      ).thenAnswer((_) async => []);
      when(
        () => mockRepository.fetchPopularTvShows(page: any(named: 'page')),
      ).thenAnswer((_) async => []);
      when(
        () => mockRepository.fetchAllMovies(page: any(named: 'page')),
      ).thenAnswer((_) async => []);
      when(
        () => mockRepository.fetchAllTvShows(page: any(named: 'page')),
      ).thenAnswer((_) async => []);

      // Act
      await useCase(const GetPopularContentParams(page: 2));

      // Assert
      verify(() => mockRepository.fetchPopularMovies(page: 2)).called(1);
      verify(() => mockRepository.fetchPopularTvShows(page: 2)).called(1);
      verify(() => mockRepository.fetchAllMovies(page: 2)).called(1);
      verify(() => mockRepository.fetchAllTvShows(page: 2)).called(1);
    });

    test('should return empty lists when repository returns empty', () async {
      // Arrange
      when(
        () => mockRepository.fetchPopularMovies(page: any(named: 'page')),
      ).thenAnswer((_) async => <Movie>[]);
      when(
        () => mockRepository.fetchPopularTvShows(page: any(named: 'page')),
      ).thenAnswer((_) async => <TvShow>[]);
      when(
        () => mockRepository.fetchAllMovies(page: any(named: 'page')),
      ).thenAnswer((_) async => <Movie>[]);
      when(
        () => mockRepository.fetchAllTvShows(page: any(named: 'page')),
      ).thenAnswer((_) async => <TvShow>[]);

      // Act
      final result = await useCase(const GetPopularContentParams());

      // Assert
      expect(result.popularMovies, isEmpty);
      expect(result.popularTvShows, isEmpty);
      expect(result.allMovies, isEmpty);
      expect(result.allTvShows, isEmpty);
    });
  });
}
