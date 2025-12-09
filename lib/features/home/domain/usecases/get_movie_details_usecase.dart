import '../../../../core/domain/base_usecase.dart';
import '../../home_repository.dart';

/// Параметри для GetMovieDetailsUseCase
class GetMovieDetailsParams {
  final int movieId;

  const GetMovieDetailsParams({required this.movieId});
}

/// Use case для отримання детальної інформації про фільм
/// 
/// Завантажує деталі фільму, включаючи відео, відгуки та рекомендації
class GetMovieDetailsUseCase
    implements UseCase<Map<String, dynamic>, GetMovieDetailsParams> {
  final HomeRepository repository;

  GetMovieDetailsUseCase(this.repository);

  @override
  Future<Map<String, dynamic>> call(GetMovieDetailsParams params) async {
    // Бізнес-логіка: валідація та завантаження деталей
    if (params.movieId <= 0) {
      throw Exception('Невірний ID фільму');
    }

    // Завантаження деталей фільму
    final details = await repository.fetchMovieDetails(params.movieId);

    // Завантаження додаткових даних (бізнес-логіка: об'єднання даних)
    final videos = await repository.fetchMovieVideos(params.movieId);
    final reviews = await repository.fetchMovieReviews(params.movieId);
    final recommendations = await repository.fetchMovieRecommendations(params.movieId);

    // Об'єднання всіх даних в один результат
    return {
      'details': details,
      'videos': videos,
      'reviews': reviews,
      'recommendations': recommendations,
    };
  }
}

