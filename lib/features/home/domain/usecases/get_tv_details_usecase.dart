import '../../../../core/domain/base_usecase.dart';
import '../../home_repository.dart';
import '../../data/models/tv_show_model.dart';

/// Параметри для GetTvDetailsUseCase
class GetTvDetailsParams {
  final int tvId;

  const GetTvDetailsParams({required this.tvId});
}

/// Use case для отримання детальної інформації про серіал
/// 
/// Завантажує деталі серіалу, включаючи відео, відгуки та рекомендації
class GetTvDetailsUseCase
    implements UseCase<Map<String, dynamic>, GetTvDetailsParams> {
  final HomeRepository repository;

  GetTvDetailsUseCase(this.repository);

  @override
  Future<Map<String, dynamic>> call(GetTvDetailsParams params) async {
    // Бізнес-логіка: валідація та завантаження деталей
    if (params.tvId <= 0) {
      throw Exception('Невірний ID серіалу');
    }

    // Завантаження деталей серіалу
    final details = await repository.fetchTvDetails(params.tvId);

    // Завантаження додаткових даних (бізнес-логіка: об'єднання даних)
    final videos = await repository.fetchTvVideos(params.tvId);
    final reviews = await repository.fetchTvReviews(params.tvId);
    final recommendations = await repository.fetchTvRecommendations(params.tvId);

    // Об'єднання всіх даних в один результат
    return {
      'details': details,
      'videos': videos,
      'reviews': reviews,
      'recommendations': recommendations,
    };
  }
}


