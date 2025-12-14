import 'package:flutter_test/flutter_test.dart';
import 'package:project/features/home/domain/entities/tv_show.dart';

void main() {
  group('TvShowEntity', () {
    test('should create TvShowEntity with all properties', () {
      // Arrange & Act
      final tvShow = TvShowEntity(
        id: 1,
        name: 'Test TV Show',
        overview: 'Test overview',
        posterPath: '/poster.jpg',
        voteAverage: 8.5,
        firstAirDate: '2023-01-01',
        genreIds: [1, 2, 3],
      );

      // Assert
      expect(tvShow.id, 1);
      expect(tvShow.name, 'Test TV Show');
      expect(tvShow.overview, 'Test overview');
      expect(tvShow.posterPath, '/poster.jpg');
      expect(tvShow.voteAverage, 8.5);
      expect(tvShow.firstAirDate, '2023-01-01');
      expect(tvShow.genreIds, [1, 2, 3]);
    });

    test('fullPosterUrl should return correct URL when posterPath is provided', () {
      // Arrange
      final tvShow = TvShowEntity(
        id: 1,
        name: 'Test TV Show',
        overview: 'Test overview',
        posterPath: '/poster.jpg',
        voteAverage: 8.5,
      );

      // Act & Assert
      expect(tvShow.fullPosterUrl, 'https://image.tmdb.org/t/p/w500/poster.jpg');
    });

    test('fullPosterUrl should return empty string when posterPath is null', () {
      // Arrange
      final tvShow = TvShowEntity(
        id: 1,
        name: 'Test TV Show',
        overview: 'Test overview',
        posterPath: null,
        voteAverage: 8.5,
      );

      // Act & Assert
      expect(tvShow.fullPosterUrl, '');
    });

    test('hasPoster should return true when posterPath is provided', () {
      // Arrange
      final tvShow = TvShowEntity(
        id: 1,
        name: 'Test TV Show',
        overview: 'Test overview',
        posterPath: '/poster.jpg',
        voteAverage: 8.5,
      );

      // Act & Assert
      expect(tvShow.hasPoster, true);
    });

    test('hasPoster should return false when posterPath is null', () {
      // Arrange
      final tvShow = TvShowEntity(
        id: 1,
        name: 'Test TV Show',
        overview: 'Test overview',
        posterPath: null,
        voteAverage: 8.5,
      );

      // Act & Assert
      expect(tvShow.hasPoster, false);
    });
  });
}

