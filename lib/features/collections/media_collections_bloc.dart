import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../auth/auth_repository.dart';
import '../auth/data/models/local_user.dart';
import 'package:project/features/home/home_media_item.dart';
import 'media_collections_event.dart';
import 'media_collection_entry.dart';
import 'domain/usecases/get_media_collections_usecase.dart';
import 'domain/usecases/toggle_favorite_usecase.dart';
import 'domain/usecases/add_to_watchlist_usecase.dart';
import 'package:project/core/network/retry_helper.dart';

class MediaCollectionsState extends Equatable {
  final bool loading;
  final bool authorized;
  final String error;
  final List<MediaCollectionEntry> favorites;
  final List<MediaCollectionEntry> watchlist;
  final Set<String> favoriteKeys;
  final Set<String> watchlistKeys;

  const MediaCollectionsState({
    this.loading = false,
    this.authorized = false,
    this.error = '',
    this.favorites = const [],
    this.watchlist = const [],
    this.favoriteKeys = const <String>{},
    this.watchlistKeys = const <String>{},
  });

  MediaCollectionsState copyWith({
    bool? loading,
    bool? authorized,
    String? error,
    List<MediaCollectionEntry>? favorites,
    List<MediaCollectionEntry>? watchlist,
    Set<String>? favoriteKeys,
    Set<String>? watchlistKeys,
  }) {
    return MediaCollectionsState(
      loading: loading ?? this.loading,
      authorized: authorized ?? this.authorized,
      error: error ?? this.error,
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

  @override
  List<Object?> get props => [
        loading,
        authorized,
        error,
        favorites,
        watchlist,
        favoriteKeys,
        watchlistKeys,
      ];
}

class MediaCollectionsBloc
    extends Bloc<MediaCollectionsEvent, MediaCollectionsState> {
  MediaCollectionsBloc({
    required GetMediaCollectionsUseCase getMediaCollectionsUseCase,
    required ToggleFavoriteUseCase toggleFavoriteUseCase,
    required AddToWatchlistUseCase addToWatchlistUseCase,
    required AuthRepository authRepository,
  })  : _getMediaCollectionsUseCase = getMediaCollectionsUseCase,
        _toggleFavoriteUseCase = toggleFavoriteUseCase,
        _addToWatchlistUseCase = addToWatchlistUseCase,
        _authRepository = authRepository,
        super(
          authRepository.currentUser != null
              ? const MediaCollectionsState(loading: true)
              : const MediaCollectionsState(loading: false, authorized: false),
        ) {
    on<LoadCollectionsEvent>(_onLoadCollections);
    on<ToggleFavoriteEvent>(_onToggleFavorite);
    on<RecordWatchEvent>(_onRecordWatch);

    _authSubscription = _authRepository.authStateChanges().listen((user) {
      if (user == null) {
        add(const LoadCollectionsEvent());
      } else {
        add(const LoadCollectionsEvent());
      }
    });

    // Завантажуємо колекції при ініціалізації
    if (_authRepository.currentUser != null) {
      add(const LoadCollectionsEvent());
    }
  }

  final GetMediaCollectionsUseCase _getMediaCollectionsUseCase;
  final ToggleFavoriteUseCase _toggleFavoriteUseCase;
  final AddToWatchlistUseCase _addToWatchlistUseCase;
  final AuthRepository _authRepository;
  StreamSubscription<LocalUser?>? _authSubscription;

  Future<void> _onLoadCollections(
    LoadCollectionsEvent event,
    Emitter<MediaCollectionsState> emit,
  ) async {
    final user = _authRepository.currentUser;
    if (user == null) {
      emit(const MediaCollectionsState(loading: false, authorized: false));
      return;
    }

    emit(state.copyWith(loading: true, authorized: true, error: ''));
    try {
      // Використання use case з retry механізмом для мережевих помилок
      final result = await RetryHelper.retry(
        operation: () =>
            _getMediaCollectionsUseCase(const GetMediaCollectionsParams()),
      );
      emit(
        state.copyWith(
          loading: false,
          authorized: true,
          favorites: result.favorites,
          watchlist: result.watchlist,
          favoriteKeys: result.favoriteKeys,
          watchlistKeys: result.watchlistKeys,
          error: '',
        ),
      );
    } catch (e) {
      final errorMessage = _getUserFriendlyError(e);
      emit(
        state.copyWith(loading: false, authorized: false, error: errorMessage),
      );
    }
  }

  Future<void> _onToggleFavorite(
    ToggleFavoriteEvent event,
    Emitter<MediaCollectionsState> emit,
  ) async {
    if (!state.authorized) return;
    emit(state.copyWith(error: ''));
    try {
      // Використання use case з retry механізмом для мережевих помилок
      final result = await RetryHelper.retry(
        operation: () =>
            _toggleFavoriteUseCase(ToggleFavoriteParams(item: event.item)),
      );
      emit(
        state.copyWith(
          favorites: result.favorites,
          favoriteKeys: result.favoriteKeys,
          error: '',
        ),
      );
    } catch (e) {
      final errorMessage = _getUserFriendlyError(e);
      emit(state.copyWith(error: errorMessage));
    }
  }

  Future<void> _onRecordWatch(
    RecordWatchEvent event,
    Emitter<MediaCollectionsState> emit,
  ) async {
    if (!state.authorized) return;
    emit(state.copyWith(error: ''));
    try {
      // Використання use case з retry механізмом для мережевих помилок
      final result = await RetryHelper.retry(
        operation: () =>
            _addToWatchlistUseCase(AddToWatchlistParams(item: event.item)),
      );
      emit(
        state.copyWith(
          watchlist: result.watchlist,
          watchlistKeys: result.watchlistKeys,
          error: '',
        ),
      );
    } catch (e) {
      final errorMessage = _getUserFriendlyError(e);
      emit(state.copyWith(error: errorMessage));
    }
  }

  String _getUserFriendlyError(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('socketexception') ||
        errorString.contains('failed host lookup') ||
        errorString.contains('no address associated with hostname')) {
      return 'Немає інтернет-з\'єднання. Перевірте підключення до мережі.';
    }

    if (errorString.contains('timeout') || errorString.contains('timed out')) {
      return 'Час очікування вичерпано. Перевірте інтернет-з\'єднання.';
    }

    if (errorString.contains('connection') || errorString.contains('network')) {
      return 'Помилка підключення до сервера. Спробуйте пізніше.';
    }

    if (errorString.contains('unauthorized') ||
        errorString.contains('permission')) {
      return 'Недостатньо прав доступу. Увійдіть в акаунт.';
    }

    // Для інших помилок повертаємо загальне повідомлення
    return 'Не вдалося виконати операцію. Спробуйте пізніше.';
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
