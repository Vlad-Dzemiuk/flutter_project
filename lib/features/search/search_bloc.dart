import 'package:flutter_bloc/flutter_bloc.dart';
import 'search_event.dart';
import 'search_state.dart';
import 'domain/usecases/search_by_filters_usecase.dart';
import '../../../core/network/retry_helper.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchByFiltersUseCase searchByFiltersUseCase;

  SearchBloc({required this.searchByFiltersUseCase}) : super(SearchInitial()) {
    on<SearchByFilters>(_onSearchByFilters);
  }

  Future<void> _onSearchByFilters(
      SearchByFilters event,
      Emitter<SearchState> emit,
      ) async {
    emit(SearchLoading());
    try {
      // Використання use case з retry механізмом для мережевих помилок
      final movies = await RetryHelper.retry(
        operation: () => searchByFiltersUseCase(
          SearchByFiltersParams(
            genreName: event.genre,
            year: event.year,
            rating: event.rating,
          ),
        ),
      );
      emit(SearchLoaded(movies));
    } catch (e) {
      final errorMessage = _getUserFriendlyError(e);
      emit(SearchError(errorMessage));
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
    
    if (errorString.contains('not found') || errorString.contains('404')) {
      return 'Нічого не знайдено за заданими фільтрами. Спробуйте інші параметри пошуку.';
    }
    
    // Для інших помилок повертаємо загальне повідомлення
    return 'Не вдалося виконати пошук. Спробуйте пізніше.';
  }
}
