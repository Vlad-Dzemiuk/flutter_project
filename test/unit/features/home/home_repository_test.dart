import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:project/features/home/home_repository.dart';
import 'package:project/features/home/home_api_service.dart';
import 'package:project/features/home/data/models/movie_model.dart';
import 'package:project/features/home/data/models/tv_show_model.dart';
import 'package:project/features/home/data/models/genre_model.dart';

void main() {
  late HomeRepositoryImpl repository;
  late MockHomeApiService mockApiService;

  setUp(() {
    mockApiService = MockHomeApiService();
    repository = HomeRepositoryImpl();
    // Note: HomeRepositoryImpl creates its own HomeApiService internally
    // For full testing, we would need to refactor to inject the service
  });

  group('HomeRepositoryImpl', () {
    test('should be instance of HomeRepository', () {
      expect(repository, isA<HomeRepository>());
    });

    test('should have fetchPopularMovies method', () {
      expect(repository.fetchPopularMovies, isA<Function>());
    });

    test('should have fetchAllMovies method', () {
      expect(repository.fetchAllMovies, isA<Function>());
    });

    test('should have fetchPopularTvShows method', () {
      expect(repository.fetchPopularTvShows, isA<Function>());
    });

    test('should have fetchAllTvShows method', () {
      expect(repository.fetchAllTvShows, isA<Function>());
    });

    test('should have fetchMovieGenres method', () {
      expect(repository.fetchMovieGenres, isA<Function>());
    });

    test('should have fetchTvGenres method', () {
      expect(repository.fetchTvGenres, isA<Function>());
    });

    test('should have searchByName method', () {
      expect(repository.searchByName, isA<Function>());
    });

    test('should have searchMovies method', () {
      expect(repository.searchMovies, isA<Function>());
    });

    test('should have searchTvShows method', () {
      expect(repository.searchTvShows, isA<Function>());
    });

    test('should have fetchMovieDetails method', () {
      expect(repository.fetchMovieDetails, isA<Function>());
    });

    test('should have fetchTvDetails method', () {
      expect(repository.fetchTvDetails, isA<Function>());
    });

    // Note: Full integration testing would require mocking HomeApiService
    // which is created internally. For better testability, consider dependency injection.
  });
}

class MockHomeApiService extends Mock implements HomeApiService {}


