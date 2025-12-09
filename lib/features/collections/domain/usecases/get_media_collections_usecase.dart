import '/core/domain/base_usecase.dart';
import '../../media_collections_repository.dart';
import '../../media_collection_entry.dart';

/// Параметри для GetMediaCollectionsUseCase
class GetMediaCollectionsParams {
  const GetMediaCollectionsParams();
}

/// Результат GetMediaCollectionsUseCase
class MediaCollectionsResult {
  final List<MediaCollectionEntry> favorites;
  final List<MediaCollectionEntry> watchlist;
  final Set<String> favoriteKeys;
  final Set<String> watchlistKeys;

  const MediaCollectionsResult({
    required this.favorites,
    required this.watchlist,
    required this.favoriteKeys,
    required this.watchlistKeys,
  });
}

/// Use case для отримання всіх колекцій медіа (favorites + watchlist)
/// 
/// Завантажує та обробляє favorites та watchlist
class GetMediaCollectionsUseCase
    implements UseCase<MediaCollectionsResult, GetMediaCollectionsParams> {
  final MediaCollectionsRepository repository;

  GetMediaCollectionsUseCase(this.repository);

  @override
  Future<MediaCollectionsResult> call(GetMediaCollectionsParams params) async {
    // Бізнес-логіка: завантаження та обробка колекцій
    final favorites = await repository.fetchFavorites();
    final watchlist = await repository.fetchWatchlist();

    // Створення наборів ключів для швидкого пошуку (бізнес-логіка)
    final favoriteKeys = favorites.map((e) => e.key).toSet();
    final watchlistKeys = watchlist.map((e) => e.key).toSet();

    return MediaCollectionsResult(
      favorites: favorites,
      watchlist: watchlist,
      favoriteKeys: favoriteKeys,
      watchlistKeys: watchlistKeys,
    );
  }
}

