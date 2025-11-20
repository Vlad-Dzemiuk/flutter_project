import 'home_api_service.dart';
import 'movie_model.dart';
import 'tv_show_model.dart';

abstract class HomeRepository {
  Future<List<Movie>> fetchPopularMovies({int page = 1});
  Future<List<Movie>> fetchAllMovies({int page = 1});
  Future<List<TvShow>> fetchPopularTvShows({int page = 1});
  Future<List<TvShow>> fetchAllTvShows({int page = 1});
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

  @override
  Future<List<TvShow>> fetchPopularTvShows({int page = 1}) {
    return apiService.fetchPopularTvShows(page: page);
  }

  @override
  Future<List<TvShow>> fetchAllTvShows({int page = 1}) {
    return apiService.fetchAllTvShows(page: page);
  }
}
