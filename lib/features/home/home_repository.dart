import 'home_api_service.dart';
import 'package:project/features/home/data/models/movie_model.dart';
import 'package:project/features/home/data/models/tv_show_model.dart';
import 'package:project/features/home/data/models/genre_model.dart';

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

  // Деталі / відео / відгуки / рекомендації
  Future<Map<String, dynamic>> fetchMovieDetails(int movieId);
  Future<Map<String, dynamic>> fetchTvDetails(int tvId);
  Future<List<dynamic>> fetchMovieVideos(int movieId);
  Future<List<dynamic>> fetchTvVideos(int tvId);
  Future<List<dynamic>> fetchMovieReviews(int movieId);
  Future<List<dynamic>> fetchTvReviews(int tvId);
  Future<List<Movie>> fetchMovieRecommendations(int movieId);
  Future<List<TvShow>> fetchTvRecommendations(int tvId);
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

  @override
  Future<Map<String, dynamic>> fetchMovieDetails(int movieId) {
    return apiService.fetchMovieDetails(movieId);
  }

  @override
  Future<Map<String, dynamic>> fetchTvDetails(int tvId) {
    return apiService.fetchTvDetails(tvId);
  }

  @override
  Future<List<dynamic>> fetchMovieVideos(int movieId) {
    return apiService.fetchMovieVideos(movieId);
  }

  @override
  Future<List<dynamic>> fetchTvVideos(int tvId) {
    return apiService.fetchTvVideos(tvId);
  }

  @override
  Future<List<dynamic>> fetchMovieReviews(int movieId) {
    return apiService.fetchMovieReviews(movieId);
  }

  @override
  Future<List<dynamic>> fetchTvReviews(int tvId) {
    return apiService.fetchTvReviews(tvId);
  }

  @override
  Future<List<Movie>> fetchMovieRecommendations(int movieId) {
    return apiService.fetchMovieRecommendations(movieId);
  }

  @override
  Future<List<TvShow>> fetchTvRecommendations(int tvId) {
    return apiService.fetchTvRecommendations(tvId);
  }
}
