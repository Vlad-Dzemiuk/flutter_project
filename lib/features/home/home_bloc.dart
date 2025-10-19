import 'package:bloc/bloc.dart';
import 'home_repository.dart';
import 'movie_model.dart';

class HomeState {
  final List<Movie> movies;
  final bool loading;
  final String error;

  HomeState({this.movies = const [], this.loading = false, this.error = ''});

  HomeState copyWith({List<Movie>? movies, bool? loading, String? error}) {
    return HomeState(
      movies: movies ?? this.movies,
      loading: loading ?? this.loading,
      error: error ?? this.error,
    );
  }
}

class HomeBloc extends Cubit<HomeState> {
  final HomeRepository repository;

  HomeBloc({required this.repository}) : super(HomeState()) {
    loadMovies();
  }

  Future<void> loadMovies() async {
    emit(state.copyWith(loading: true));
    try {
      final movies = await repository.fetchMovies();
      emit(state.copyWith(movies: movies, loading: false));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), loading: false));
    }
  }
}
