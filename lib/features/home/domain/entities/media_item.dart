/// Domain entity для медіа елемента (універсальний для фільмів та серіалів)
/// 
/// Це чиста domain entity без залежностей від data layer
class MediaItemEntity {
  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final double rating;
  final bool isMovie;

  const MediaItemEntity({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.rating,
    required this.isMovie,
  });

  String get fullPosterUrl {
    if (posterPath == null || posterPath!.isEmpty) {
      return '';
    }
    return 'https://image.tmdb.org/t/p/w500$posterPath';
  }

  bool get hasPoster => posterPath != null && posterPath!.isNotEmpty;
}


