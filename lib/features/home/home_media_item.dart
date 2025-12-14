import 'package:project/features/home/data/models/movie_model.dart';
import 'package:project/features/home/data/models/tv_show_model.dart';

class HomeMediaItem {
  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final double rating;
  final bool isMovie;

  const HomeMediaItem({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.rating,
    required this.isMovie,
  });

  factory HomeMediaItem.fromMovie(Movie movie) {
    return HomeMediaItem(
      id: movie.id,
      title: movie.title,
      overview: movie.overview,
      posterPath: movie.posterPath,
      rating: movie.voteAverage,
      isMovie: true,
    );
  }

  factory HomeMediaItem.fromTvShow(TvShow show) {
    return HomeMediaItem(
      id: show.id,
      title: show.name,
      overview: show.overview,
      posterPath: show.posterPath,
      rating: show.voteAverage,
      isMovie: false,
    );
  }
}

