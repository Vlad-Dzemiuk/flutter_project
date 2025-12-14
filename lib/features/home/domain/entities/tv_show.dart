/// Domain entity для серіалу
///
/// Це чиста domain entity без залежностей від data layer
class TvShowEntity {
  final int id;
  final String name;
  final String overview;
  final String? posterPath;
  final double voteAverage;
  final String? firstAirDate;
  final List<int>? genreIds;

  const TvShowEntity({
    required this.id,
    required this.name,
    required this.overview,
    this.posterPath,
    required this.voteAverage,
    this.firstAirDate,
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
