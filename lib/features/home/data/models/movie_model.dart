/// Data model для фільму (для API відповідей)
///
/// Це модель даних, яка відповідає структурі API відповіді
class Movie {
  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final double voteAverage;

  Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.voteAverage,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: (json['id'] as int?) ?? 0,
      title: (json['title'] as String?) ?? '',
      overview: (json['overview'] as String?) ?? '',
      posterPath: json['poster_path'] as String?,
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
