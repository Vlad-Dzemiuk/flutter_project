import 'dart:async';

import 'package:bloc/bloc.dart';

import '../auth/auth_repository.dart';
import '../home/home_media_item.dart';
import 'media_collection_entry.dart';
import 'media_collections_repository.dart';

class MediaCollectionsState {
  final bool loading;
  final bool authorized;
  final List<MediaCollectionEntry> favorites;
  final List<MediaCollectionEntry> watchlist;
  final Set<String> favoriteKeys;
  final Set<String> watchlistKeys;

  const MediaCollectionsState({
    this.loading = false,
    this.authorized = false,
    this.favorites = const [],
    this.watchlist = const [],
    this.favoriteKeys = const <String>{},
    this.watchlistKeys = const <String>{},
  });

  MediaCollectionsState copyWith({
    bool? loading,
    bool? authorized,
    List<MediaCollectionEntry>? favorites,
    List<MediaCollectionEntry>? watchlist,
    Set<String>? favoriteKeys,
    Set<String>? watchlistKeys,
  }) {
    return MediaCollectionsState(
      loading: loading ?? this.loading,
      authorized: authorized ?? this.authorized,
      favorites: favorites ?? this.favorites,
      watchlist: watchlist ?? this.watchlist,
      favoriteKeys: favoriteKeys ?? this.favoriteKeys,
      watchlistKeys: watchlistKeys ?? this.watchlistKeys,
    );
  }

  bool isFavorite(HomeMediaItem item) {
    return favoriteKeys.contains(
      MediaCollectionEntry.buildKey(isMovie: item.isMovie, id: item.id),
    );
  }
}

class MediaCollectionsCubit extends Cubit<MediaCollectionsState> {
  MediaCollectionsCubit({
    required MediaCollectionsRepository repository,
    required AuthRepository authRepository,
  }) : _repository = repository,
       _authRepository = authRepository,
       super(const MediaCollectionsState(loading: true)) {
    _authSubscription = _authRepository.authStateChanges().listen(
      _handleAuthChange,
    );
    _handleAuthChange(_authRepository.currentUser);
  }

  final MediaCollectionsRepository _repository;
  final AuthRepository _authRepository;
  StreamSubscription<LocalUser?>? _authSubscription;

  Future<void> _handleAuthChange(LocalUser? user) async {
    if (user == null) {
      emit(const MediaCollectionsState(loading: false, authorized: false));
      return;
    }
    await _loadAll();
  }

  Future<void> _loadAll() async {
    emit(state.copyWith(loading: true, authorized: true));
    final favorites = await _repository.fetchFavorites();
    final watchlist = await _repository.fetchWatchlist();
    emit(
      state.copyWith(
        loading: false,
        authorized: true,
        favorites: favorites,
        watchlist: watchlist,
        favoriteKeys: favorites.map((e) => e.key).toSet(),
        watchlistKeys: watchlist.map((e) => e.key).toSet(),
      ),
    );
  }

  Future<void> toggleFavorite(HomeMediaItem item) async {
    if (!state.authorized) return;
    await _repository.toggleFavorite(item);
    final favorites = await _repository.fetchFavorites();
    emit(
      state.copyWith(
        favorites: favorites,
        favoriteKeys: favorites.map((e) => e.key).toSet(),
      ),
    );
  }

  Future<void> recordWatch(HomeMediaItem item) async {
    if (!state.authorized) return;
    await _repository.addToWatchlist(item);
    final watchlist = await _repository.fetchWatchlist();
    emit(
      state.copyWith(
        watchlist: watchlist,
        watchlistKeys: watchlist.map((e) => e.key).toSet(),
      ),
    );
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
