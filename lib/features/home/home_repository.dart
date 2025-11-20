import 'home_api_service.dart';
import 'movie_model.dart';

abstract class HomeRepository {
  Future<List<Movie>> fetchPopularMovies({int page = 1});
  Future<List<Movie>> fetchAllMovies({int page = 1});
}

class HomeRepositoryImpl implements HomeRepository {
  final HomeApiService apiService = HomeApiService();

  @override
  Future<List<Movie>> fetchPopularMovies({int page = 1}) {
    return apiService.fetchPopularMovies(page: page);
  }

  @override
  Future<List<Movie>> fetchAllMovies({int page = 1}) {
    return apiService.fetchAllMovies(page: page);
  }
}
