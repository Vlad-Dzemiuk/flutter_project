/// Domain entity для фільму
/// 
/// Це чиста domain entity без залежностей від data layer
class MovieEntity {
  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final double voteAverage;
  final String? releaseDate;
  final List<int>? genreIds;

  const MovieEntity({
    required this.id,
    required this.title,
    required this.overview,
    this.posterPath,
    required this.voteAverage,
    this.releaseDate,
    this.genreIds,
  });

  String get fullPosterUrl {
    if (posterPath == null || posterPath!.isEmpty) {
      return '';
    }
    return 'https://image.tmdb.org/t/p/w500$posterPath';
  }

  bool get hasPoster => posterPath != null && posterPath!.isNotEmpty;
}


