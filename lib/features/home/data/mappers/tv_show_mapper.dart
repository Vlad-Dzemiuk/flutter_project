import '../../domain/entities/tv_show.dart';
import '../models/tv_show_model.dart';

/// Mapper для конвертації між data model (TvShow) та domain entity (TvShowEntity)
class TvShowMapper {
  /// Конвертує TvShow (data model) в TvShowEntity (domain entity)
  static TvShowEntity toEntity(TvShow tvShow) {
    return TvShowEntity(
      id: tvShow.id,
      name: tvShow.name,
      overview: tvShow.overview,
      posterPath: tvShow.posterPath,
      voteAverage: tvShow.voteAverage,
    );
  }

  /// Конвертує список TvShow в список TvShowEntity
  static List<TvShowEntity> toEntityList(List<TvShow> tvShows) {
    return tvShows.map((tvShow) => toEntity(tvShow)).toList();
  }
}


