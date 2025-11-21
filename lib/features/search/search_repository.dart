import '../home/home_api_service.dart';
import '../home/movie_model.dart';

class SearchRepository {
  final HomeApiService apiService;

  SearchRepository(this.apiService);

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
