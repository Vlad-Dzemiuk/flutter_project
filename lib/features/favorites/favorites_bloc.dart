import 'package:flutter_bloc/flutter_bloc.dart';
import 'favorites_repository.dart';

class FavoritesState {
  final bool loading;
  final String error;
  final List<Movie> movies;

  FavoritesState({this.loading = false, this.error = '', this.movies = const []});

  FavoritesState copyWith({
    bool? loading,
    String? error,
    List<Movie>? movies,
  }) {
    return FavoritesState(
      loading: loading ?? this.loading,
      error: error ?? this.error,
      movies: movies ?? this.movies,
    );
  }
}

class FavoritesBloc extends Cubit<FavoritesState> {
  final FavoritesRepository repository;

  FavoritesBloc({required this.repository}) : super(FavoritesState()) {
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    emit(state.copyWith(loading: true));
    try {
      final movies = await repository.getFavoriteMovies(1);
      emit(state.copyWith(loading: false, movies: movies));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }
}
