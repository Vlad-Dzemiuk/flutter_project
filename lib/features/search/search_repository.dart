import '../home/home_api_service.dart';
import '../home/movie_model.dart';

class SearchRepository {
  final HomeApiService apiService;

  SearchRepository(this.apiService);

  Future<List<Movie>> searchMovies({
    String? genre,
    int? year,
    double? rating,
  }) async {
    try {
      final results = await apiService.searchMovies(
        genre: genre,
        year: year,
        rating: rating,
      );
      return results;
    } catch (e) {
      throw Exception('Помилка при пошуку фільмів: $e');
    }
  }
}
