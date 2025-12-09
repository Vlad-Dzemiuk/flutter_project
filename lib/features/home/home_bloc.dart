import 'package:bloc/bloc.dart';
import 'home_media_item.dart';
import 'domain/usecases/get_popular_content_usecase.dart';
import 'domain/usecases/search_media_usecase.dart';

class HomeState {
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

  HomeState({
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
      searchQuery: searchQuery ?? this.searchQuery,
      hasMoreResults: hasMoreResults ?? this.hasMoreResults,
    );
  }
}

class HomeBloc extends Cubit<HomeState> {
  final GetPopularContentUseCase getPopularContentUseCase;
  final SearchMediaUseCase searchMediaUseCase;

  HomeBloc({
    required this.getPopularContentUseCase,
    required this.searchMediaUseCase,
  }) : super(HomeState()) {
    loadContent();
  }

  Future<void> loadContent() async {
    if (isClosed) return;
    emit(state.copyWith(loading: true));
    try {
      // Використання use case замість прямого виклику репозиторію
      final result = await getPopularContentUseCase(
        const GetPopularContentParams(page: 1),
      );
      
      if (!isClosed) {
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
      }
    } catch (e) {
      if (!isClosed) {
        final errorMessage = _getUserFriendlyError(e);
        emit(state.copyWith(error: errorMessage, loading: false));
      }
    }
  }

  Future<void> search({
    String? query,
    String? genreName,
    int? year,
    double? rating,
    bool loadMore = false,
  }) async {
    if (isClosed) return;
    if (loadMore) {
      emit(state.copyWith(loadingMore: true));
    } else {
      emit(state.copyWith(searching: true, error: '', searchResults: []));
    }
    
    try {
      int currentPage = loadMore ? (state.searchResults.length ~/ 20) + 1 : 1;
      
      // Використання use case замість прямого виклику репозиторію
      final result = await searchMediaUseCase(
        SearchMediaParams(
          query: query,
          genreName: genreName,
          year: year,
          rating: rating,
          page: currentPage,
          loadMore: loadMore,
        ),
      );
      
      final allResults = loadMore 
          ? [...state.searchResults, ...result.results] 
          : result.results;
      
      if (!isClosed) {
        emit(
          state.copyWith(
            searchResults: allResults,
            searching: false,
            loadingMore: false,
            searchQuery: query,
            hasMoreResults: result.hasMore,
            error: '',
          ),
        );
      }
    } catch (e) {
      if (!isClosed) {
        final errorMessage = _getUserFriendlyError(e);
        emit(state.copyWith(error: errorMessage, searching: false, loadingMore: false));
      }
    }
  }

  void clearSearch() {
    emit(state.copyWith(searchResults: [], searchQuery: null, hasMoreResults: false));
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
