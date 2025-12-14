import 'package:flutter_test/flutter_test.dart';
import 'package:project/features/home/domain/entities/media_item.dart';

void main() {
  group('MediaItemEntity', () {
    test('should create MediaItemEntity with all properties', () {
      // Arrange & Act
      final mediaItem = MediaItemEntity(
        id: 1,
        title: 'Test Media',
        overview: 'Test overview',
        posterPath: '/poster.jpg',
        rating: 8.5,
        isMovie: true,
      );

      // Assert
      expect(mediaItem.id, 1);
      expect(mediaItem.title, 'Test Media');
      expect(mediaItem.overview, 'Test overview');
      expect(mediaItem.posterPath, '/poster.jpg');
      expect(mediaItem.rating, 8.5);
      expect(mediaItem.isMovie, true);
    });

    test(
      'fullPosterUrl should return correct URL when posterPath is provided',
      () {
        // Arrange
        final mediaItem = MediaItemEntity(
          id: 1,
          title: 'Test Media',
          overview: 'Test overview',
          posterPath: '/poster.jpg',
          rating: 8.5,
          isMovie: true,
        );

        // Act & Assert
        expect(
          mediaItem.fullPosterUrl,
          'https://image.tmdb.org/t/p/w500/poster.jpg',
        );
      },
    );

    test(
      'fullPosterUrl should return empty string when posterPath is null',
      () {
        // Arrange
        final mediaItem = MediaItemEntity(
          id: 1,
          title: 'Test Media',
          overview: 'Test overview',
          posterPath: null,
          rating: 8.5,
          isMovie: true,
        );

        // Act & Assert
        expect(mediaItem.fullPosterUrl, '');
      },
    );

    test('hasPoster should return true when posterPath is provided', () {
      // Arrange
      final mediaItem = MediaItemEntity(
        id: 1,
        title: 'Test Media',
        overview: 'Test overview',
        posterPath: '/poster.jpg',
        rating: 8.5,
        isMovie: true,
      );

      // Act & Assert
      expect(mediaItem.hasPoster, true);
    });

    test('hasPoster should return false when posterPath is null', () {
      // Arrange
      final mediaItem = MediaItemEntity(
        id: 1,
        title: 'Test Media',
        overview: 'Test overview',
        posterPath: null,
        rating: 8.5,
        isMovie: true,
      );

      // Act & Assert
      expect(mediaItem.hasPoster, false);
    });
  });
}
