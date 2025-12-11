import '../../../../core/domain/base_usecase.dart';
import '../../home_repository.dart';
import '../entities/video.dart';

/// Параметри для GetMovieVideosUseCase
class GetMovieVideosParams {
  final int movieId;

  const GetMovieVideosParams({required this.movieId});
}

/// Use case для отримання відео фільму
/// 
/// Завантажує список відео (трейлери, тизери тощо) для фільму
class GetMovieVideosUseCase
    implements UseCase<List<Video>, GetMovieVideosParams> {
  final HomeRepository repository;

  GetMovieVideosUseCase(this.repository);

  @override
  Future<List<Video>> call(GetMovieVideosParams params) async {
    // Бізнес-логіка: валідація та завантаження відео
    if (params.movieId <= 0) {
      throw Exception('Невірний ID фільму');
    }

    // Завантаження відео
    final videosData = await repository.fetchMovieVideos(params.movieId);

    // Конвертація в domain entities
    final videos = videosData
        .map((videoJson) {
          try {
            return Video.fromJson(videoJson as Map<String, dynamic>);
          } catch (e) {
            rethrow;
          }
        })
        .toList();

    return videos;
  }
}

