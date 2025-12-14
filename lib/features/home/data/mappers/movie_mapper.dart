import '../../domain/entities/movie.dart';
import '../models/movie_model.dart';

/// Mapper для конвертації між data model (Movie) та domain entity (MovieEntity)
class MovieMapper {
  /// Конвертує Movie (data model) в MovieEntity (domain entity)
  static MovieEntity toEntity(Movie movie) {
    return MovieEntity(
      id: movie.id,
      title: movie.title,
      overview: movie.overview,
      posterPath: movie.posterPath,
      voteAverage: movie.voteAverage,
    );
  }

  /// Конвертує список Movie в список MovieEntity
  static List<MovieEntity> toEntityList(List<Movie> movies) {
    return movies.map((movie) => toEntity(movie)).toList();
  }
}
