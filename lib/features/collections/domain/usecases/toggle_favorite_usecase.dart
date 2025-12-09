import '../../../home/home_media_item.dart';
import '/core/domain/base_usecase.dart';
import '../../media_collections_repository.dart';
import '../../media_collection_entry.dart';

/// Параметри для ToggleFavoriteUseCase
class ToggleFavoriteParams {
  final HomeMediaItem item;

  const ToggleFavoriteParams({required this.item});
}

/// Результат ToggleFavoriteUseCase
class ToggleFavoriteResult {
  final List<MediaCollectionEntry> favorites;
  final Set<String> favoriteKeys;
  final bool isFavorite;

  const ToggleFavoriteResult({
    required this.favorites,
    required this.favoriteKeys,
    required this.isFavorite,
  });
}

/// Use case для додавання/видалення медіа з улюблених
/// 
/// Перемикає стан "улюблене" для медіа елемента
class ToggleFavoriteUseCase
    implements UseCase<ToggleFavoriteResult, ToggleFavoriteParams> {
  final MediaCollectionsRepository repository;

  ToggleFavoriteUseCase(this.repository);

  @override
  Future<ToggleFavoriteResult> call(ToggleFavoriteParams params) async {
    // Бізнес-логіка: перевірка та перемикання стану улюбленого
    final key = MediaCollectionEntry.buildKey(
      isMovie: params.item.isMovie,
      id: params.item.id,
    );

    // Перевірка поточного стану перед перемиканням
    final currentFavorites = await repository.fetchFavorites();
    final isCurrentlyFavorite = currentFavorites.any((e) => e.key == key);

    // Перемикання стану
    await repository.toggleFavorite(params.item);

    // Оновлення списку після змін
    final updatedFavorites = await repository.fetchFavorites();
    final favoriteKeys = updatedFavorites.map((e) => e.key).toSet();

    return ToggleFavoriteResult(
      favorites: updatedFavorites,
      favoriteKeys: favoriteKeys,
      isFavorite: !isCurrentlyFavorite,
    );
  }
}

