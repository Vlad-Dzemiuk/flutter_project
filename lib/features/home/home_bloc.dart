import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'home_event.dart';
import 'package:project/features/home/home_media_item.dart';
import 'domain/usecases/get_popular_content_usecase.dart';
import 'domain/usecases/search_media_usecase.dart';
import 'package:project/core/network/retry_helper.dart';

class HomeState extends Equatable {
  final List<HomeMediaItem> popularMovies;
  final List<HomeMediaItem> popularTvShows;
  final List<HomeMediaItem> allMovies;
  final List<HomeMediaItem> allTvShows;
  final List<HomeMediaItem> searchResults;
  final bool loading;
  final bool searching;
  final bool loadingMore;
  final String error;
  final String? searchQuery;
  final bool hasMoreResults;

  const HomeState({
    this.popularMovies = const [],
    this.popularTvShows = const [],
    this.allMovies = const [],
    this.allTvShows = const [],
    this.searchResults = const [],
    this.loading = false,
    this.searching = false,
    this.loadingMore = false,
    this.error = '',
    this.searchQuery,
    this.hasMoreResults = false,
  });

  HomeState copyWith({
    List<HomeMediaItem>? popularMovies,
    List<HomeMediaItem>? popularTvShows,
    List<HomeMediaItem>? allMovies,
    List<HomeMediaItem>? allTvShows,
    List<HomeMediaItem>? searchResults,
    bool? loading,
    bool? searching,
    bool? loadingMore,
    String? error,
    String? searchQuery,
    bool? hasMoreResults,
    bool clearSearchQuery = false,
  }) {
    return HomeState(
      popularMovies: popularMovies ?? this.popularMovies,
      popularTvShows: popularTvShows ?? this.popularTvShows,
      allMovies: allMovies ?? this.allMovies,
      allTvShows: allTvShows ?? this.allTvShows,
      searchResults: searchResults ?? this.searchResults,
      loading: loading ?? this.loading,
      searching: searching ?? this.searching,
      loadingMore: loadingMore ?? this.loadingMore,
      error: error ?? this.error,
      searchQuery: clearSearchQuery ? null : (searchQuery ?? this.searchQuery),
      hasMoreResults: hasMoreResults ?? this.hasMoreResults,
    );
  }

  @override
  List<Object?> get props => [
    popularMovies,
    popularTvShows,
    allMovies,
    allTvShows,
    searchResults,
    loading,
    searching,
    loadingMore,
    error,
    searchQuery,
    hasMoreResults,
  ];
}

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetPopularContentUseCase getPopularContentUseCase;
  final SearchMediaUseCase searchMediaUseCase;

  HomeBloc({
    required this.getPopularContentUseCase,
    required this.searchMediaUseCase,
  }) : super(const HomeState()) {
    on<LoadContentEvent>(_onLoadContent);
    on<SearchEvent>(_onSearch);
    on<ClearSearchEvent>(_onClearSearch);
    add(const LoadContentEvent());
  }

  Future<void> _onLoadContent(
    LoadContentEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(loading: true));
    try {
      // Використання use case з retry механізмом для мережевих помилок
      final result = await RetryHelper.retry(
        operation: () =>
            getPopularContentUseCase(const GetPopularContentParams(page: 1)),
      );

      emit(
        state.copyWith(
          popularMovies: result.popularMovies,
          popularTvShows: result.popularTvShows,
          allMovies: result.allMovies,
          allTvShows: result.allTvShows,
          loading: false,
          error: '',
        ),
      );
    } catch (e) {
      final errorMessage = _getUserFriendlyError(e);
      emit(state.copyWith(error: errorMessage, loading: false));
    }
  }

  Future<void> _onSearch(SearchEvent event, Emitter<HomeState> emit) async {
    if (event.loadMore) {
      emit(state.copyWith(loadingMore: true));
    } else {
      emit(state.copyWith(searching: true, error: '', searchResults: []));
    }

    try {
      int currentPage = event.loadMore
          ? (state.searchResults.length ~/ 20) + 1
          : 1;

      // Використання use case з retry механізмом для мережевих помилок
      final result = await RetryHelper.retry(
        operation: () => searchMediaUseCase(
          SearchMediaParams(
            query: event.query,
            genreName: event.genreName,
            year: event.year,
            rating: event.rating,
            page: currentPage,
            loadMore: event.loadMore,
          ),
        ),
      );

      final allResults = event.loadMore
          ? [...state.searchResults, ...result.results]
          : result.results;

      emit(
        state.copyWith(
          searchResults: allResults,
          searching: false,
          loadingMore: false,
          searchQuery: event.query,
          hasMoreResults: result.hasMore,
          error: '',
        ),
      );
    } catch (e) {
      final errorMessage = _getUserFriendlyError(e);
      emit(
        state.copyWith(
          error: errorMessage,
          searching: false,
          loadingMore: false,
        ),
      );
    }
  }

  void _onClearSearch(ClearSearchEvent event, Emitter<HomeState> emit) {
    emit(
      state.copyWith(
        searchResults: [],
        clearSearchQuery: true,
        hasMoreResults: false,
      ),
    );
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

    // Для інших помилок повертаємо загальне повідомлення
    return 'Не вдалося завантажити дані. Спробуйте пізніше.';
  }
}
