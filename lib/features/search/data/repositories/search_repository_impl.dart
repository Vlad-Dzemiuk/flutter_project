import '../../../home/data/models/movie_model.dart';
import '../../../home/home_api_service.dart';
import '../../domain/repositories/search_repository.dart';

/// Реалізація репозиторію для пошуку
class SearchRepositoryImpl implements SearchRepository {
  final HomeApiService apiService;

  SearchRepositoryImpl(this.apiService);

  @override
  Future<List<Movie>> searchMovies({
    String? genreName,
    int? year,
    double? rating,
    int page = 1,
  }) async {
    try {
      final result = await apiService.searchMovies(
        genreName: genreName,
        year: year,
        rating: rating,
        page: page,
      );
      final movies = (result['movies'] as List<dynamic>).cast<Movie>();
      return movies;
    } catch (e) {
      throw Exception('Помилка при пошуку фільмів: $e');
    }
  }
}

