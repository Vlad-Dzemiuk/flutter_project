import '../../../../core/domain/base_usecase.dart';
import '../../home_repository.dart';
import '../../home_media_item.dart';
import '../../data/models/movie_model.dart';
import '../../data/models/tv_show_model.dart';

/// Параметри для SearchMediaUseCase
class SearchMediaParams {
  final String? query;
  final String? genreName;
  final int? year;
  final double? rating;
  final int page;
  final bool loadMore;

  const SearchMediaParams({
    this.query,
    this.genreName,
    this.year,
    this.rating,
    this.page = 1,
    this.loadMore = false,
  });
}

/// Результат SearchMediaUseCase
class SearchMediaResult {
  final List<HomeMediaItem> results;
  final bool hasMore;

  const SearchMediaResult({
    required this.results,
    required this.hasMore,
  });
}

/// Use case для пошуку медіа контенту
class SearchMediaUseCase
    implements UseCase<SearchMediaResult, SearchMediaParams> {
  final HomeRepository repository;

  SearchMediaUseCase(this.repository);

  @override
  Future<SearchMediaResult> call(SearchMediaParams params) async {
    // Бізнес-логіка: визначення стратегії пошуку та обробка результатів
    List<HomeMediaItem> newResults = [];
    bool hasMore = false;

    if (params.query != null && params.query!.isNotEmpty) {
      // Пошук за назвою
      final searchData = await repository.searchByName(
        params.query!,
        page: params.page,
      );
      final movies = (searchData['movies'] as List<dynamic>)
          .cast<Movie>()
          .map((m) => HomeMediaItem.fromMovie(m))
          .toList();
      final tvShows = (searchData['tvShows'] as List<dynamic>)
          .cast<TvShow>()
          .map((t) => HomeMediaItem.fromTvShow(t))
          .toList();
      newResults = [...movies, ...tvShows];
      hasMore = searchData['hasMore'] as bool? ?? false;
    } else {
      // Пошук за фільтрами (жанр, рік, рейтинг)
      final moviesData = await repository.searchMovies(
        genreName: params.genreName,
        year: params.year,
        rating: params.rating,
        page: params.page,
      );
      final tvShowsData = await repository.searchTvShows(
        genreName: params.genreName,
        year: params.year,
        rating: params.rating,
        page: params.page,
      );

      final movies = (moviesData['movies'] as List<dynamic>)
          .cast<Movie>()
          .map((m) => HomeMediaItem.fromMovie(m))
          .toList();
      final tvShows = (tvShowsData['tvShows'] as List<dynamic>)
          .cast<TvShow>()
          .map((t) => HomeMediaItem.fromTvShow(t))
          .toList();
      newResults = [...movies, ...tvShows];

      final moviesHasMore = moviesData['hasMore'] as bool? ?? false;
      final tvHasMore = tvShowsData['hasMore'] as bool? ?? false;
      hasMore = moviesHasMore || tvHasMore;
    }

    return SearchMediaResult(
      results: newResults,
      hasMore: hasMore,
    );
  }
}

