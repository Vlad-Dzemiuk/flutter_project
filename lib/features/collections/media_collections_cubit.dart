import 'dart:async';

import 'package:bloc/bloc.dart';

import '../auth/auth_repository.dart';
import '../auth/data/models/local_user.dart';
import '../home/home_media_item.dart';
import 'media_collection_entry.dart';
import 'domain/usecases/get_media_collections_usecase.dart';
import 'domain/usecases/toggle_favorite_usecase.dart';
import 'domain/usecases/add_to_watchlist_usecase.dart';

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
    required GetMediaCollectionsUseCase getMediaCollectionsUseCase,
    required ToggleFavoriteUseCase toggleFavoriteUseCase,
    required AddToWatchlistUseCase addToWatchlistUseCase,
    required AuthRepository authRepository,
  }) : _getMediaCollectionsUseCase = getMediaCollectionsUseCase,
       _toggleFavoriteUseCase = toggleFavoriteUseCase,
       _addToWatchlistUseCase = addToWatchlistUseCase,
       _authRepository = authRepository,
       super(const MediaCollectionsState(loading: true)) {
    _authSubscription = _authRepository.authStateChanges().listen(
      _handleAuthChange,
    );
    _handleAuthChange(_authRepository.currentUser);
  }

  final GetMediaCollectionsUseCase _getMediaCollectionsUseCase;
  final ToggleFavoriteUseCase _toggleFavoriteUseCase;
  final AddToWatchlistUseCase _addToWatchlistUseCase;
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
    try {
      // Використання use case замість прямого виклику репозиторію
      final result = await _getMediaCollectionsUseCase(
        const GetMediaCollectionsParams(),
      );
      emit(
        state.copyWith(
          loading: false,
          authorized: true,
          favorites: result.favorites,
          watchlist: result.watchlist,
          favoriteKeys: result.favoriteKeys,
          watchlistKeys: result.watchlistKeys,
        ),
      );
    } catch (e) {
      emit(state.copyWith(loading: false, authorized: false));
    }
  }

  Future<void> toggleFavorite(HomeMediaItem item) async {
    if (!state.authorized) return;
    try {
      // Використання use case замість прямого виклику репозиторію
      final result = await _toggleFavoriteUseCase(
        ToggleFavoriteParams(item: item),
      );
      emit(
        state.copyWith(
          favorites: result.favorites,
          favoriteKeys: result.favoriteKeys,
        ),
      );
    } catch (e) {
      // Обробка помилки (можна додати error state)
    }
  }

  Future<void> recordWatch(HomeMediaItem item) async {
    if (!state.authorized) return;
    try {
      // Використання use case замість прямого виклику репозиторію
      final result = await _addToWatchlistUseCase(
        AddToWatchlistParams(item: item),
      );
      emit(
        state.copyWith(
          watchlist: result.watchlist,
          watchlistKeys: result.watchlistKeys,
        ),
      );
    } catch (e) {
      // Обробка помилки (можна додати error state)
    }
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
