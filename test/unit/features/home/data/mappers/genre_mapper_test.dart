import 'package:flutter_test/flutter_test.dart';
import 'package:project/features/home/data/mappers/genre_mapper.dart';
import 'package:project/features/home/data/models/genre_model.dart';
import 'package:project/features/home/domain/entities/genre.dart';

void main() {
  group('GenreMapper', () {
    test('should convert Genre to GenreEntity', () {
      // Arrange
      final genre = Genre(id: 1, name: 'Action');

      // Act
      final genreEntity = GenreMapper.toEntity(genre);

      // Assert
      expect(genreEntity, isA<GenreEntity>());
      expect(genreEntity.id, 1);
      expect(genreEntity.name, 'Action');
    });

    test('should convert Genre with different values to GenreEntity', () {
      // Arrange
      final genre = Genre(id: 28, name: 'Drama');

      // Act
      final genreEntity = GenreMapper.toEntity(genre);

      // Assert
      expect(genreEntity.id, 28);
      expect(genreEntity.name, 'Drama');
    });

    test('should convert list of Genre to list of GenreEntity', () {
      // Arrange
      final genres = [
        Genre(id: 1, name: 'Action'),
        Genre(id: 2, name: 'Comedy'),
        Genre(id: 3, name: 'Drama'),
        Genre(id: 4, name: 'Thriller'),
      ];

      // Act
      final genreEntities = GenreMapper.toEntityList(genres);

      // Assert
      expect(genreEntities.length, 4);
      expect(genreEntities[0].id, 1);
      expect(genreEntities[0].name, 'Action');
      expect(genreEntities[1].id, 2);
      expect(genreEntities[1].name, 'Comedy');
      expect(genreEntities[2].id, 3);
      expect(genreEntities[2].name, 'Drama');
      expect(genreEntities[3].id, 4);
      expect(genreEntities[3].name, 'Thriller');
    });

    test('should convert empty list to empty list', () {
      // Arrange
      final genres = <Genre>[];

      // Act
      final genreEntities = GenreMapper.toEntityList(genres);

      // Assert
      expect(genreEntities, isEmpty);
    });

    test('should preserve all genre properties during conversion', () {
      // Arrange
      final genre = Genre(id: 99, name: 'Sci-Fi');

      // Act
      final genreEntity = GenreMapper.toEntity(genre);

      // Assert
      expect(genreEntity.id, equals(genre.id));
      expect(genreEntity.name, equals(genre.name));
    });
  });
}
