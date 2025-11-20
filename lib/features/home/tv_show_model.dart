class TvShow {
  final int id;
  final String name;
  final String overview;
  final String? posterPath;
  final double voteAverage;

  TvShow({
    required this.id,
    required this.name,
    required this.overview,
    required this.posterPath,
    required this.voteAverage,
  });

  factory TvShow.fromJson(Map<String, dynamic> json) {
    return TvShow(
      id: (json['id'] as int?) ?? 0,
      name: (json['name'] as String?) ?? '',
      overview: (json['overview'] as String?) ?? '',
      posterPath: json['poster_path'] as String?,
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

