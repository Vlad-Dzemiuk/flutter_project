import 'package:flutter_test/flutter_test.dart';
import 'package:project/features/home/data/mappers/tv_show_mapper.dart';
import 'package:project/features/home/data/models/tv_show_model.dart';
import 'package:project/features/home/domain/entities/tv_show.dart';

void main() {
  group('TvShowMapper', () {
    test('should convert TvShow to TvShowEntity', () {
      // Arrange
      final tvShow = TvShow(
        id: 1,
        name: 'Test TV Show',
        overview: 'Test overview',
        posterPath: '/poster.jpg',
        voteAverage: 8.5,
      );

      // Act
      final tvShowEntity = TvShowMapper.toEntity(tvShow);

      // Assert
      expect(tvShowEntity, isA<TvShowEntity>());
      expect(tvShowEntity.id, 1);
      expect(tvShowEntity.name, 'Test TV Show');
      expect(tvShowEntity.overview, 'Test overview');
      expect(tvShowEntity.posterPath, '/poster.jpg');
      expect(tvShowEntity.voteAverage, 8.5);
    });

    test('should convert TvShow with null posterPath to TvShowEntity', () {
      // Arrange
      final tvShow = TvShow(
        id: 2,
        name: 'Test TV Show 2',
        overview: 'Test overview 2',
        posterPath: null,
        voteAverage: 7.5,
      );

      // Act
      final tvShowEntity = TvShowMapper.toEntity(tvShow);

      // Assert
      expect(tvShowEntity.id, 2);
      expect(tvShowEntity.name, 'Test TV Show 2');
      expect(tvShowEntity.posterPath, isNull);
      expect(tvShowEntity.voteAverage, 7.5);
    });

    test('should convert list of TvShow to list of TvShowEntity', () {
      // Arrange
      final tvShows = [
        TvShow(
          id: 1,
          name: 'TV Show 1',
          overview: 'Overview 1',
          posterPath: '/poster1.jpg',
          voteAverage: 8.0,
        ),
        TvShow(
          id: 2,
          name: 'TV Show 2',
          overview: 'Overview 2',
          posterPath: '/poster2.jpg',
          voteAverage: 9.0,
        ),
        TvShow(
          id: 3,
          name: 'TV Show 3',
          overview: 'Overview 3',
          posterPath: null,
          voteAverage: 7.5,
        ),
      ];

      // Act
      final tvShowEntities = TvShowMapper.toEntityList(tvShows);

      // Assert
      expect(tvShowEntities.length, 3);
      expect(tvShowEntities[0].id, 1);
      expect(tvShowEntities[0].name, 'TV Show 1');
      expect(tvShowEntities[1].id, 2);
      expect(tvShowEntities[1].name, 'TV Show 2');
      expect(tvShowEntities[2].id, 3);
      expect(tvShowEntities[2].name, 'TV Show 3');
      expect(tvShowEntities[2].posterPath, isNull);
    });

    test('should convert empty list to empty list', () {
      // Arrange
      final tvShows = <TvShow>[];

      // Act
      final tvShowEntities = TvShowMapper.toEntityList(tvShows);

      // Assert
      expect(tvShowEntities, isEmpty);
    });
  });
}
