import '../../../home/home_media_item.dart';
import '/core/domain/base_usecase.dart';
import '../../media_collections_repository.dart';
import '../../media_collection_entry.dart';

/// Параметри для AddToWatchlistUseCase
class AddToWatchlistParams {
  final HomeMediaItem item;

  const AddToWatchlistParams({required this.item});
}

/// Результат AddToWatchlistUseCase
class AddToWatchlistResult {
  final List<MediaCollectionEntry> watchlist;
  final Set<String> watchlistKeys;

  const AddToWatchlistResult({
    required this.watchlist,
    required this.watchlistKeys,
  });
}

/// Use case для додавання медіа до watchlist
/// 
/// Додає медіа елемент до списку для перегляду пізніше
class AddToWatchlistUseCase
    implements UseCase<AddToWatchlistResult, AddToWatchlistParams> {
  final MediaCollectionsRepository repository;

  AddToWatchlistUseCase(this.repository);

  @override
  Future<AddToWatchlistResult> call(AddToWatchlistParams params) async {
    // Бізнес-логіка: перевірка та додавання до watchlist
    final key = MediaCollectionEntry.buildKey(
      isMovie: params.item.isMovie,
      id: params.item.id,
    );

    // Перевірка, чи вже є в watchlist (бізнес-логіка)
    final currentWatchlist = await repository.fetchWatchlist();
    final alreadyInWatchlist = currentWatchlist.any((e) => e.key == key);

    if (alreadyInWatchlist) {
      // Якщо вже є, просто повертаємо поточний стан
      final watchlistKeys = currentWatchlist.map((e) => e.key).toSet();
      return AddToWatchlistResult(
        watchlist: currentWatchlist,
        watchlistKeys: watchlistKeys,
      );
    }

    // Додавання до watchlist
    await repository.addToWatchlist(params.item);

    // Оновлення списку після додавання
    final updatedWatchlist = await repository.fetchWatchlist();
    final watchlistKeys = updatedWatchlist.map((e) => e.key).toSet();

    return AddToWatchlistResult(
      watchlist: updatedWatchlist,
      watchlistKeys: watchlistKeys,
    );
  }
}

