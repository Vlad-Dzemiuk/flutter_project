import 'package:bloc/bloc.dart';
import 'home_media_item.dart';
import 'home_repository.dart';

class HomeState {
  final List<HomeMediaItem> popularMovies;
  final List<HomeMediaItem> popularTvShows;
  final List<HomeMediaItem> allMovies;
  final List<HomeMediaItem> allTvShows;
  final bool loading;
  final String error;

  HomeState({
    this.popularMovies = const [],
    this.popularTvShows = const [],
    this.allMovies = const [],
    this.allTvShows = const [],
    this.loading = false,
    this.error = '',
  });

  HomeState copyWith({
    List<HomeMediaItem>? popularMovies,
    List<HomeMediaItem>? popularTvShows,
    List<HomeMediaItem>? allMovies,
    List<HomeMediaItem>? allTvShows,
    bool? loading,
    String? error,
  }) {
    return HomeState(
      popularMovies: popularMovies ?? this.popularMovies,
      popularTvShows: popularTvShows ?? this.popularTvShows,
      allMovies: allMovies ?? this.allMovies,
      allTvShows: allTvShows ?? this.allTvShows,
      loading: loading ?? this.loading,
      error: error ?? this.error,
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
}
