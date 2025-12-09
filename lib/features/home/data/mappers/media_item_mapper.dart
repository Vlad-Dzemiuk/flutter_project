import '../../domain/entities/media_item.dart';
import '../../domain/entities/movie.dart';
import '../../domain/entities/tv_show.dart';

/// Mapper для конвертації між domain entities та MediaItemEntity
class MediaItemMapper {
  /// Конвертує MovieEntity в MediaItemEntity
  static MediaItemEntity fromMovieEntity(MovieEntity movie) {
    return MediaItemEntity(
      id: movie.id,
      title: movie.title,
      overview: movie.overview,
      posterPath: movie.posterPath,
      rating: movie.voteAverage,
      isMovie: true,
    );
  }

  /// Конвертує TvShowEntity в MediaItemEntity
  static MediaItemEntity fromTvShowEntity(TvShowEntity tvShow) {
    return MediaItemEntity(
      id: tvShow.id,
      title: tvShow.name,
      overview: tvShow.overview,
      posterPath: tvShow.posterPath,
      rating: tvShow.voteAverage,
      isMovie: false,
    );
  }

  /// Конвертує список MovieEntity в список MediaItemEntity
  static List<MediaItemEntity> fromMovieEntityList(List<MovieEntity> movies) {
    return movies.map((movie) => fromMovieEntity(movie)).toList();
  }

  /// Конвертує список TvShowEntity в список MediaItemEntity
  static List<MediaItemEntity> fromTvShowEntityList(List<TvShowEntity> tvShows) {
    return tvShows.map((tvShow) => fromTvShowEntity(tvShow)).toList();
  }
}


