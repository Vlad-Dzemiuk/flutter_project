import 'home_api_service.dart';
import 'movie_model.dart';
import 'tv_show_model.dart';
import 'genre_model.dart';

abstract class HomeRepository {
  Future<List<Movie>> fetchPopularMovies({int page = 1});
  Future<List<Movie>> fetchAllMovies({int page = 1});
  Future<List<TvShow>> fetchPopularTvShows({int page = 1});
  Future<List<TvShow>> fetchAllTvShows({int page = 1});
  
  // Пошук
  Future<List<Genre>> fetchMovieGenres();
  Future<List<Genre>> fetchTvGenres();
  Future<Map<String, dynamic>> searchByName(String query, {int page = 1});
  Future<Map<String, dynamic>> searchMovies({
    String? query,
    String? genreName,
    int? year,
    double? rating,
    int page = 1,
  });
  Future<Map<String, dynamic>> searchTvShows({
    String? query,
    String? genreName,
    int? year,
    double? rating,
    int page = 1,
  });
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

  @override
  Future<List<Genre>> fetchMovieGenres() {
    return apiService.fetchMovieGenres();
  }

  @override
  Future<List<Genre>> fetchTvGenres() {
    return apiService.fetchTvGenres();
  }

  @override
  Future<Map<String, dynamic>> searchByName(String query, {int page = 1}) {
    return apiService.searchByName(query, page: page);
  }

  @override
  Future<Map<String, dynamic>> searchMovies({
    String? query,
    String? genreName,
    int? year,
    double? rating,
    int page = 1,
  }) {
    return apiService.searchMovies(
      query: query,
      genreName: genreName,
      year: year,
      rating: rating,
      page: page,
    );
  }

  @override
  Future<Map<String, dynamic>> searchTvShows({
    String? query,
    String? genreName,
    int? year,
    double? rating,
    int page = 1,
  }) {
    return apiService.searchTvShows(
      query: query,
      genreName: genreName,
      year: year,
      rating: rating,
      page: page,
    );
  }
}
