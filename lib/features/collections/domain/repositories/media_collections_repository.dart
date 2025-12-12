import '../../../../core/storage/media_collections_storage.dart';
import '../../../home/home_media_item.dart';
import '../../media_collection_entry.dart';

class MediaCollectionsRepository {
  MediaCollectionsRepository(this._storage);

  final MediaCollectionsStorage _storage;

  Future<List<MediaCollectionEntry>> fetchFavorites() async {
    final data = await _storage.readFavorites();
    return _mapAndSort(data);
  }

  Future<List<MediaCollectionEntry>> fetchWatchlist() async {
    final data = await _storage.readWatchlist();
    return _mapAndSort(data);
  }

  Future<void> toggleFavorite(HomeMediaItem item) async {
    final favorites = await _storage.readFavorites();
    final key = MediaCollectionEntry.buildKey(
      isMovie: item.isMovie,
      id: item.id,
    );
    if (favorites.containsKey(key)) {
      favorites.remove(key);
    } else {
      favorites[key] = MediaCollectionEntry.fromHomeItem(item).toJson();
    }
    await _storage.writeFavorites(favorites);
  }

  Future<void> addToWatchlist(HomeMediaItem item) async {
    final watchlist = await _storage.readWatchlist();
    final entry = MediaCollectionEntry.fromHomeItem(
      item,
      updatedAt: DateTime.now(),
    );
    watchlist[entry.key] = entry.toJson();
    await _storage.writeWatchlist(watchlist);
  }

  List<MediaCollectionEntry> _mapAndSort(
    Map<String, Map<String, dynamic>> data,
  ) {
    final entries = data.values
        .map((json) => MediaCollectionEntry.fromJson(json))
        .toList();
    entries.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return entries;
  }
}
