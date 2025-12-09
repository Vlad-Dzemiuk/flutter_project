import 'package:flutter_bloc/flutter_bloc.dart';
import '../home/data/models/movie_model.dart';
import 'search_event.dart';
import 'search_state.dart';
import 'domain/usecases/search_by_filters_usecase.dart';

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
      // Використання use case замість прямого виклику репозиторію
      final movies = await searchByFiltersUseCase(
        SearchByFiltersParams(
          genreName: event.genre,
          year: event.year,
          rating: event.rating,
        ),
      );
      emit(SearchLoaded(movies));
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }
}
