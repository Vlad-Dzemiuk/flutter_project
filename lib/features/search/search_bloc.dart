import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project/features/favorites/favorites_repository.dart';
import 'search_event.dart';
import 'search_state.dart';
import 'search_repository.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchRepository repository;

  SearchBloc(this.repository) : super(SearchInitial()) {
    on<SearchByFilters>(_onSearchByFilters);
  }

  Future<void> _onSearchByFilters(
      SearchByFilters event,
      Emitter<SearchState> emit,
      ) async {
    emit(SearchLoading());
    try {
      final movies = await repository.searchMovies(
        genre: event.genre,
        year: event.year,
        rating: event.rating,
      );
      emit(SearchLoaded(movies.cast<Movie>()));
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }
}
