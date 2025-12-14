import '../../../home/data/models/movie_model.dart';

/// Абстракція репозиторію для улюблених
abstract class FavoritesRepository {
  Future<List<Movie>> getFavoriteMovies(int accountId);
}
