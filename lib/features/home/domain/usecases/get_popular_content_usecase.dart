import 'package:project/core/domain/base_usecase.dart';
import '../../home_repository.dart';
import 'package:project/features/home/home_media_item.dart';
import 'package:project/features/home/data/models/movie_model.dart';
import 'package:project/features/home/data/models/tv_show_model.dart';

/// Параметри для GetPopularContentUseCase
class GetPopularContentParams {
  final int page;

  const GetPopularContentParams({this.page = 1});
}

/// Результат GetPopularContentUseCase
class PopularContentResult {
  final List<HomeMediaItem> popularMovies;
  final List<HomeMediaItem> popularTvShows;
  final List<HomeMediaItem> allMovies;
  final List<HomeMediaItem> allTvShows;

  const PopularContentResult({
    required this.popularMovies,
    required this.popularTvShows,
    required this.allMovies,
    required this.allTvShows,
  });
}

/// Use case для отримання популярного контенту (фільми та серіали)
class GetPopularContentUseCase
    implements UseCase<PopularContentResult, GetPopularContentParams> {
  final HomeRepository repository;

  GetPopularContentUseCase(this.repository);

  @override
  Future<PopularContentResult> call(GetPopularContentParams params) async {
    // Бізнес-логіка: завантаження та обробка популярного контенту
    final popularMovies = await repository.fetchPopularMovies(
      page: params.page,
    );
    final popularTv = await repository.fetchPopularTvShows(page: params.page);
    final catalogMovies = await repository.fetchAllMovies(page: params.page);
    final catalogTv = await repository.fetchAllTvShows(page: params.page);

    // Трансформація моделей даних в presentation models
    final List<HomeMediaItem> popularMoviesItems = popularMovies
        .map((m) => HomeMediaItem.fromMovie(m))
        .toList();
    final List<HomeMediaItem> popularTvItems = popularTv
        .map((t) => HomeMediaItem.fromTvShow(t))
        .toList();
    final List<HomeMediaItem> allMoviesItems = catalogMovies
        .map((m) => HomeMediaItem.fromMovie(m))
        .toList();
    final List<HomeMediaItem> allTvItems = catalogTv
        .map((t) => HomeMediaItem.fromTvShow(t))
        .toList();

    return PopularContentResult(
      popularMovies: popularMoviesItems,
      popularTvShows: popularTvItems,
      allMovies: allMoviesItems,
      allTvShows: allTvItems,
    );
  }
}
