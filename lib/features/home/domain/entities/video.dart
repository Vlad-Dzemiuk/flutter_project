/// Domain entity для відео
///
/// Це чиста domain entity без залежностей від data layer
class Video {
  final String id;
  final String key;
  final String name;
  final String site;
  final String type;
  final bool official;
  final String? publishedAt;

  const Video({
    required this.id,
    required this.key,
    required this.name,
    required this.site,
    required this.type,
    required this.official,
    this.publishedAt,
  });

  /// Перевіряє, чи є відео YouTube трейлером
  bool get isYouTubeTrailer {
    if (site != 'YouTube' || key.isEmpty) return false;
    // Приймаємо різні варіанти типів трейлерів
    final typeLower = type.toLowerCase();
    return typeLower == 'trailer' ||
        typeLower == 'teaser' ||
        type.isEmpty; // Якщо тип не вказано, але це YouTube - приймаємо
  }

  /// Перевіряє, чи є відео YouTube (будь-яке)
  bool get isYouTube {
    return site == 'YouTube' && key.isNotEmpty;
  }

  /// Створює Video з Map (з API відповіді)
  factory Video.fromJson(Map<String, dynamic> json) {
    // ID може бути String або int в залежності від API
    final idValue = json['id'];
    final id = idValue is String
        ? idValue
        : idValue is int
        ? idValue.toString()
        : '';

    final key = json['key'] as String? ?? '';
    final site = json['site'] as String? ?? '';
    final type = json['type'] as String? ?? '';
    final name = json['name'] as String? ?? '';
    final official = json['official'] as bool? ?? false;

    return Video(
      id: id,
      key: key,
      name: name,
      site: site,
      type: type,
      official: official,
      publishedAt: json['published_at'] as String?,
    );
  }
}
