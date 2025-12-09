import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'favorites_event.dart';
import '../home/data/models/movie_model.dart';
import 'domain/usecases/get_favorites_usecase.dart';
import '../../../core/network/retry_helper.dart';

class FavoritesState extends Equatable {
  final bool loading;
  final String error;
  final List<Movie> movies;

  const FavoritesState({this.loading = false, this.error = '', this.movies = const []});

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

  @override
  List<Object?> get props => [loading, error, movies];
}

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final GetFavoritesUseCase getFavoritesUseCase;

  FavoritesBloc({required this.getFavoritesUseCase}) : super(const FavoritesState()) {
    on<LoadFavoritesEvent>(_onLoadFavorites);
    add(const LoadFavoritesEvent());
  }

  Future<void> _onLoadFavorites(
    LoadFavoritesEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(state.copyWith(loading: true, error: ''));
    try {
      // Використання use case з retry механізмом для мережевих помилок
      final movies = await RetryHelper.retry(
        operation: () => getFavoritesUseCase(
          const GetFavoritesParams(accountId: 1),
        ),
      );
      emit(state.copyWith(loading: false, movies: movies, error: ''));
    } catch (e) {
      final errorMessage = _getUserFriendlyError(e);
      emit(state.copyWith(loading: false, error: errorMessage));
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
    
    if (errorString.contains('unauthorized') || errorString.contains('permission')) {
      return 'Недостатньо прав доступу. Увійдіть в акаунт.';
    }
    
    // Для інших помилок повертаємо загальне повідомлення
    return 'Не вдалося завантажити вподобані. Спробуйте пізніше.';
  }
}
