import 'package:flutter_bloc/flutter_bloc.dart';
import '../home/data/models/movie_model.dart';
import 'domain/usecases/get_favorites_usecase.dart';

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
  final GetFavoritesUseCase getFavoritesUseCase;

  FavoritesBloc({required this.getFavoritesUseCase}) : super(FavoritesState()) {
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    emit(state.copyWith(loading: true));
    try {
      // Використання use case замість прямого виклику репозиторію
      final movies = await getFavoritesUseCase(
        const GetFavoritesParams(accountId: 1),
      );
      emit(state.copyWith(loading: false, movies: movies));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }
}
