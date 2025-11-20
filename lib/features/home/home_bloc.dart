import 'package:bloc/bloc.dart';
import 'home_repository.dart';
import 'movie_model.dart';

class HomeState {
  final List<Movie> popularMovies;
  final List<Movie> allMovies;
  final bool loading;
  final String error;

  HomeState({
    this.popularMovies = const [],
    this.allMovies = const [],
    this.loading = false,
    this.error = '',
  });

  HomeState copyWith({
    List<Movie>? popularMovies,
    List<Movie>? allMovies,
    bool? loading,
    String? error,
  }) {
    return HomeState(
      popularMovies: popularMovies ?? this.popularMovies,
      allMovies: allMovies ?? this.allMovies,
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
      final popular = await repository.fetchPopularMovies(page: 1);
      final catalog = await repository.fetchAllMovies(page: 1);
      emit(
        state.copyWith(
          popularMovies: popular,
          allMovies: catalog,
          loading: false,
          error: '',
        ),
      );
    } catch (e) {
      emit(state.copyWith(error: e.toString(), loading: false));
    }
  }
}
