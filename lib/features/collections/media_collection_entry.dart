import '../home/home_media_item.dart';

class MediaCollectionEntry {
  final String key;
  final int mediaId;
  final bool isMovie;
  final String title;
  final String overview;
  final String? posterPath;
  final double rating;
  final DateTime updatedAt;

  const MediaCollectionEntry({
    required this.key,
    required this.mediaId,
    required this.isMovie,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.rating,
    required this.updatedAt,
  });

  factory MediaCollectionEntry.fromHomeItem(
    HomeMediaItem item, {
    DateTime? updatedAt,
  }) {
    return MediaCollectionEntry(
      key: buildKey(isMovie: item.isMovie, id: item.id),
      mediaId: item.id,
      isMovie: item.isMovie,
      title: item.title,
      overview: item.overview,
      posterPath: item.posterPath,
      rating: item.rating,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  factory MediaCollectionEntry.fromJson(Map<String, dynamic> json) {
    return MediaCollectionEntry(
      key: json['key'] as String,
      mediaId: json['media_id'] as int,
      isMovie: json['is_movie'] as bool,
      title: json['title'] as String? ?? '',
      overview: json['overview'] as String? ?? '',
      posterPath: json['poster_path'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        json['updated_at'] as int? ?? 0,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'media_id': mediaId,
      'is_movie': isMovie,
      'title': title,
      'overview': overview,
      'poster_path': posterPath,
      'rating': rating,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  HomeMediaItem toHomeMediaItem() {
    return HomeMediaItem(
      id: mediaId,
      title: title,
      overview: overview,
      posterPath: posterPath,
      rating: rating,
      isMovie: isMovie,
    );
  }

  static String buildKey({required bool isMovie, required int id}) {
    return '${isMovie ? 'movie' : 'tv'}-$id';
  }
}
