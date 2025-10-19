import 'home_api_service.dart';
import 'movie_model.dart';

abstract class HomeRepository {
  Future<List<Movie>> fetchMovies();
}

class HomeRepositoryImpl implements HomeRepository {
  final HomeApiService apiService = HomeApiService();

  @override
  Future<List<Movie>> fetchMovies() async {
    return await apiService.fetchPopularMovies();
  }
}
