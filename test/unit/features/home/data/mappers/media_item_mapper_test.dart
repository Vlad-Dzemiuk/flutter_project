import 'package:flutter_test/flutter_test.dart';
import 'package:project/features/home/data/mappers/media_item_mapper.dart';
import 'package:project/features/home/domain/entities/movie.dart';
import 'package:project/features/home/domain/entities/tv_show.dart';
import 'package:project/features/home/domain/entities/media_item.dart';

void main() {
  group('MediaItemMapper', () {
    test('should convert MovieEntity to MediaItemEntity', () {
      // Arrange
      final movie = MovieEntity(
        id: 1,
        title: 'Test Movie',
        overview: 'Test overview',
        posterPath: '/poster.jpg',
        voteAverage: 8.5,
      );

      // Act
      final mediaItem = MediaItemMapper.fromMovieEntity(movie);

      // Assert
      expect(mediaItem, isA<MediaItemEntity>());
      expect(mediaItem.id, 1);
      expect(mediaItem.title, 'Test Movie');
      expect(mediaItem.overview, 'Test overview');
      expect(mediaItem.posterPath, '/poster.jpg');
      expect(mediaItem.rating, 8.5);
      expect(mediaItem.isMovie, true);
    });

    test('should convert TvShowEntity to MediaItemEntity', () {
      // Arrange
      final tvShow = TvShowEntity(
        id: 1,
        name: 'Test TV Show',
        overview: 'Test overview',
        posterPath: '/poster.jpg',
        voteAverage: 8.5,
      );

      // Act
      final mediaItem = MediaItemMapper.fromTvShowEntity(tvShow);

      // Assert
      expect(mediaItem, isA<MediaItemEntity>());
      expect(mediaItem.id, 1);
      expect(mediaItem.title, 'Test TV Show');
      expect(mediaItem.overview, 'Test overview');
      expect(mediaItem.posterPath, '/poster.jpg');
      expect(mediaItem.rating, 8.5);
      expect(mediaItem.isMovie, false);
    });

    test('should convert list of MovieEntity to list of MediaItemEntity', () {
      // Arrange
      final movies = [
        MovieEntity(
          id: 1,
          title: 'Movie 1',
          overview: 'Overview 1',
          posterPath: '/poster1.jpg',
          voteAverage: 8.0,
        ),
        MovieEntity(
          id: 2,
          title: 'Movie 2',
          overview: 'Overview 2',
          posterPath: '/poster2.jpg',
          voteAverage: 9.0,
        ),
      ];

      // Act
      final mediaItems = MediaItemMapper.fromMovieEntityList(movies);

      // Assert
      expect(mediaItems.length, 2);
      expect(mediaItems[0].title, 'Movie 1');
      expect(mediaItems[1].title, 'Movie 2');
      expect(mediaItems[0].isMovie, true);
      expect(mediaItems[1].isMovie, true);
    });

    test('should convert list of TvShowEntity to list of MediaItemEntity', () {
      // Arrange
      final tvShows = [
        TvShowEntity(
          id: 1,
          name: 'TV Show 1',
          overview: 'Overview 1',
          posterPath: '/poster1.jpg',
          voteAverage: 8.0,
        ),
        TvShowEntity(
          id: 2,
          name: 'TV Show 2',
          overview: 'Overview 2',
          posterPath: '/poster2.jpg',
          voteAverage: 9.0,
        ),
      ];

      // Act
      final mediaItems = MediaItemMapper.fromTvShowEntityList(tvShows);

      // Assert
      expect(mediaItems.length, 2);
      expect(mediaItems[0].title, 'TV Show 1');
      expect(mediaItems[1].title, 'TV Show 2');
      expect(mediaItems[0].isMovie, false);
      expect(mediaItems[1].isMovie, false);
    });
  });
}

