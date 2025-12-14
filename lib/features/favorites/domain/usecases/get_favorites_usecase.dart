import '../../../../core/domain/base_usecase.dart';
import '../../../home/data/models/movie_model.dart';
import '../repositories/favorites_repository.dart';

/// Параметри для GetFavoritesUseCase
class GetFavoritesParams {
  final int accountId;

  const GetFavoritesParams({required this.accountId});
}

/// Use case для отримання списку улюблених фільмів
///
/// Валідує accountId та завантажує улюблені фільми
class GetFavoritesUseCase implements UseCase<List<Movie>, GetFavoritesParams> {
  final FavoritesRepository repository;

  GetFavoritesUseCase(this.repository);

  @override
  Future<List<Movie>> call(GetFavoritesParams params) async {
    // Бізнес-логіка: валідація та завантаження улюблених
    if (params.accountId <= 0) {
      throw Exception('Невірний ID акаунта');
    }

    // Виклик репозиторію для отримання улюблених фільмів
    final favorites = await repository.getFavoriteMovies(params.accountId);

    // Сортування за назвою (бізнес-логіка)
    favorites.sort((a, b) => a.title.compareTo(b.title));

    return favorites;
  }
}
