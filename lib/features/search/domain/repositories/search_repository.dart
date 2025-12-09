import '../../../home/data/models/movie_model.dart';

/// Абстракція репозиторію для пошуку
abstract class SearchRepository {
  Future<List<Movie>> searchMovies({
    String? genreName,
    int? year,
    double? rating,
    int page = 1,
  });
}

