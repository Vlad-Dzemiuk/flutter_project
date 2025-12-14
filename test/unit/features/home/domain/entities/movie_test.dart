import 'package:flutter_test/flutter_test.dart';
import 'package:project/features/home/domain/entities/movie.dart';

void main() {
  group('MovieEntity', () {
    test('should create MovieEntity with all properties', () {
      // Arrange & Act
      final movie = MovieEntity(
        id: 1,
        title: 'Test Movie',
        overview: 'Test overview',
        posterPath: '/poster.jpg',
        voteAverage: 8.5,
        releaseDate: '2023-01-01',
        genreIds: [1, 2, 3],
      );

      // Assert
      expect(movie.id, 1);
      expect(movie.title, 'Test Movie');
      expect(movie.overview, 'Test overview');
      expect(movie.posterPath, '/poster.jpg');
      expect(movie.voteAverage, 8.5);
      expect(movie.releaseDate, '2023-01-01');
      expect(movie.genreIds, [1, 2, 3]);
    });

    test('fullPosterUrl should return correct URL when posterPath is provided', () {
      // Arrange
      final movie = MovieEntity(
        id: 1,
        title: 'Test Movie',
        overview: 'Test overview',
        posterPath: '/poster.jpg',
        voteAverage: 8.5,
      );

      // Act & Assert
      expect(movie.fullPosterUrl, 'https://image.tmdb.org/t/p/w500/poster.jpg');
    });

    test('fullPosterUrl should return empty string when posterPath is null', () {
      // Arrange
      final movie = MovieEntity(
        id: 1,
        title: 'Test Movie',
        overview: 'Test overview',
        posterPath: null,
        voteAverage: 8.5,
      );

      // Act & Assert
      expect(movie.fullPosterUrl, '');
    });

    test('fullPosterUrl should return empty string when posterPath is empty', () {
      // Arrange
      final movie = MovieEntity(
        id: 1,
        title: 'Test Movie',
        overview: 'Test overview',
        posterPath: '',
        voteAverage: 8.5,
      );

      // Act & Assert
      expect(movie.fullPosterUrl, '');
    });

    test('hasPoster should return true when posterPath is provided', () {
      // Arrange
      final movie = MovieEntity(
        id: 1,
        title: 'Test Movie',
        overview: 'Test overview',
        posterPath: '/poster.jpg',
        voteAverage: 8.5,
      );

      // Act & Assert
      expect(movie.hasPoster, true);
    });

    test('hasPoster should return false when posterPath is null', () {
      // Arrange
      final movie = MovieEntity(
        id: 1,
        title: 'Test Movie',
        overview: 'Test overview',
        posterPath: null,
        voteAverage: 8.5,
      );

      // Act & Assert
      expect(movie.hasPoster, false);
    });

    test('hasPoster should return false when posterPath is empty', () {
      // Arrange
      final movie = MovieEntity(
        id: 1,
        title: 'Test Movie',
        overview: 'Test overview',
        posterPath: '',
        voteAverage: 8.5,
      );

      // Act & Assert
      expect(movie.hasPoster, false);
    });
  });
}

