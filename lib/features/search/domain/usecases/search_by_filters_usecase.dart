import '../../../../core/domain/base_usecase.dart';
import '../../../home/data/models/movie_model.dart';
import '../repositories/search_repository.dart';

/// Параметри для SearchByFiltersUseCase
class SearchByFiltersParams {
  final String? genreName;
  final int? year;
  final double? rating;
  final int page;

  const SearchByFiltersParams({
    this.genreName,
    this.year,
    this.rating,
    this.page = 1,
  });
}

/// Use case для пошуку фільмів за фільтрами
///
/// Повертає список фільмів, що відповідають критеріям пошуку
class SearchByFiltersUseCase
    implements UseCase<List<Movie>, SearchByFiltersParams> {
  final SearchRepository repository;

  SearchByFiltersUseCase(this.repository);

  @override
  Future<List<Movie>> call(SearchByFiltersParams params) async {
    // Бізнес-логіка: валідація та пошук
    if (params.page < 1) {
      throw Exception('Номер сторінки повинен бути більше 0');
    }

    // Виклик репозиторію для пошуку
    final movies = await repository.searchMovies(
      genreName: params.genreName,
      year: params.year,
      rating: params.rating,
      page: params.page,
    );

    return movies;
  }
}
