import 'package:bloc/bloc.dart';
import 'home_media_item.dart';
import 'home_repository.dart';
import 'movie_model.dart';
import 'tv_show_model.dart';

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
  final HomeRepository repository;

  HomeBloc({required this.repository}) : super(HomeState()) {
    loadContent();
  }

  Future<void> loadContent() async {
    emit(state.copyWith(loading: true));
    try {
      final popularMovies = await repository.fetchPopularMovies(page: 1);
      final popularTv = await repository.fetchPopularTvShows(page: 1);
      final catalogMovies = await repository.fetchAllMovies(page: 1);
      final catalogTv = await repository.fetchAllTvShows(page: 1);
      
      final List<HomeMediaItem> popularMoviesItems = popularMovies.map((m) => HomeMediaItem.fromMovie(m)).toList();
      final List<HomeMediaItem> popularTvItems = popularTv.map((t) => HomeMediaItem.fromTvShow(t)).toList();
      final List<HomeMediaItem> allMoviesItems = catalogMovies.map((m) => HomeMediaItem.fromMovie(m)).toList();
      final List<HomeMediaItem> allTvItems = catalogTv.map((t) => HomeMediaItem.fromTvShow(t)).toList();
      
      emit(
        state.copyWith(
          popularMovies: popularMoviesItems,
          popularTvShows: popularTvItems,
          allMovies: allMoviesItems,
          allTvShows: allTvItems,
          loading: false,
          error: '',
        ),
      );
    } catch (e) {
      emit(state.copyWith(error: e.toString(), loading: false));
    }
  }

  Future<void> search({
    String? query,
    String? genreName,
    int? year,
    double? rating,
    bool loadMore = false,
  }) async {
    if (loadMore) {
      emit(state.copyWith(loadingMore: true));
    } else {
      emit(state.copyWith(searching: true, error: '', searchResults: []));
    }
    
    try {
      int currentPage = loadMore ? (state.searchResults.length ~/ 20) + 1 : 1;
      List<HomeMediaItem> newResults = [];
      bool hasMore = false;
      
      if (query != null && query.isNotEmpty) {
        // Пошук за назвою
        final searchData = await repository.searchByName(query, page: currentPage);
        final movies = (searchData['movies'] as List<dynamic>).cast<Movie>().map((m) => HomeMediaItem.fromMovie(m)).toList();
        final tvShows = (searchData['tvShows'] as List<dynamic>).cast<TvShow>().map((t) => HomeMediaItem.fromTvShow(t)).toList();
        newResults = [...movies, ...tvShows];
        hasMore = searchData['hasMore'] as bool? ?? false;
      } else {
        // Пошук за фільтрами
        final moviesData = await repository.searchMovies(
          genreName: genreName,
          year: year,
          rating: rating,
          page: currentPage,
        );
        final tvShowsData = await repository.searchTvShows(
          genreName: genreName,
          year: year,
          rating: rating,
          page: currentPage,
        );
        
        final movies = (moviesData['movies'] as List<dynamic>).cast<Movie>().map((m) => HomeMediaItem.fromMovie(m)).toList();
        final tvShows = (tvShowsData['tvShows'] as List<dynamic>).cast<TvShow>().map((t) => HomeMediaItem.fromTvShow(t)).toList();
        newResults = [...movies, ...tvShows];
        
        final moviesHasMore = moviesData['hasMore'] as bool? ?? false;
        final tvHasMore = tvShowsData['hasMore'] as bool? ?? false;
        hasMore = moviesHasMore || tvHasMore;
      }
      
      final allResults = loadMore ? [...state.searchResults, ...newResults] : newResults;
      
      emit(
        state.copyWith(
          searchResults: allResults,
          searching: false,
          loadingMore: false,
          searchQuery: query,
          hasMoreResults: hasMore,
          error: '',
        ),
      );
    } catch (e) {
      emit(state.copyWith(error: e.toString(), searching: false, loadingMore: false));
    }
  }

  void clearSearch() {
    emit(state.copyWith(searchResults: [], searchQuery: null, hasMoreResults: false));
  }
}
