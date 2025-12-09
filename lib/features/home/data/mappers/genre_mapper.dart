import '../../domain/entities/genre.dart';
import '../models/genre_model.dart';

/// Mapper для конвертації між data model (Genre) та domain entity (GenreEntity)
class GenreMapper {
  /// Конвертує Genre (data model) в GenreEntity (domain entity)
  static GenreEntity toEntity(Genre genre) {
    return GenreEntity(
      id: genre.id,
      name: genre.name,
    );
  }

  /// Конвертує список Genre в список GenreEntity
  static List<GenreEntity> toEntityList(List<Genre> genres) {
    return genres.map((genre) => toEntity(genre)).toList();
  }
}


