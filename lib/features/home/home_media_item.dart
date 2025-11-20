import 'movie_model.dart';
import 'tv_show_model.dart';

class HomeMediaItem {
  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final double rating;

  const HomeMediaItem({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.rating,
  });

  factory HomeMediaItem.fromMovie(Movie movie) {
    return HomeMediaItem(
      id: movie.id,
      title: movie.title,
      overview: movie.overview,
      posterPath: movie.posterPath,
      rating: movie.voteAverage,
    );
  }

  factory HomeMediaItem.fromTvShow(TvShow show) {
    return HomeMediaItem(
      id: show.id,
      title: show.name,
      overview: show.overview,
      posterPath: show.posterPath,
      rating: show.voteAverage,
    );
  }
}

