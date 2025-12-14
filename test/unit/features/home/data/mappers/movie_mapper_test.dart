import 'package:flutter_test/flutter_test.dart';
import 'package:project/features/home/data/mappers/movie_mapper.dart';
import 'package:project/features/home/data/models/movie_model.dart';
import 'package:project/features/home/domain/entities/movie.dart';

void main() {
  group('MovieMapper', () {
    test('should convert Movie to MovieEntity', () {
      // Arrange
      final movie = Movie(
        id: 1,
        title: 'Test Movie',
        overview: 'Test overview',
        posterPath: '/poster.jpg',
        voteAverage: 8.5,
      );

      // Act
      final movieEntity = MovieMapper.toEntity(movie);

      // Assert
      expect(movieEntity, isA<MovieEntity>());
      expect(movieEntity.id, 1);
      expect(movieEntity.title, 'Test Movie');
      expect(movieEntity.overview, 'Test overview');
      expect(movieEntity.posterPath, '/poster.jpg');
      expect(movieEntity.voteAverage, 8.5);
    });

    test('should convert Movie with null posterPath to MovieEntity', () {
      // Arrange
      final movie = Movie(
        id: 2,
        title: 'Test Movie 2',
        overview: 'Test overview 2',
        posterPath: null,
        voteAverage: 7.5,
      );

      // Act
      final movieEntity = MovieMapper.toEntity(movie);

      // Assert
      expect(movieEntity.id, 2);
      expect(movieEntity.title, 'Test Movie 2');
      expect(movieEntity.posterPath, isNull);
      expect(movieEntity.voteAverage, 7.5);
    });

    test('should convert list of Movie to list of MovieEntity', () {
      // Arrange
      final movies = [
        Movie(
          id: 1,
          title: 'Movie 1',
          overview: 'Overview 1',
          posterPath: '/poster1.jpg',
          voteAverage: 8.0,
        ),
        Movie(
          id: 2,
          title: 'Movie 2',
          overview: 'Overview 2',
          posterPath: '/poster2.jpg',
          voteAverage: 9.0,
        ),
        Movie(
          id: 3,
          title: 'Movie 3',
          overview: 'Overview 3',
          posterPath: null,
          voteAverage: 7.5,
        ),
      ];

      // Act
      final movieEntities = MovieMapper.toEntityList(movies);

      // Assert
      expect(movieEntities.length, 3);
      expect(movieEntities[0].id, 1);
      expect(movieEntities[0].title, 'Movie 1');
      expect(movieEntities[1].id, 2);
      expect(movieEntities[1].title, 'Movie 2');
      expect(movieEntities[2].id, 3);
      expect(movieEntities[2].title, 'Movie 3');
      expect(movieEntities[2].posterPath, isNull);
    });

    test('should convert empty list to empty list', () {
      // Arrange
      final movies = <Movie>[];

      // Act
      final movieEntities = MovieMapper.toEntityList(movies);

      // Assert
      expect(movieEntities, isEmpty);
    });
  });
}
