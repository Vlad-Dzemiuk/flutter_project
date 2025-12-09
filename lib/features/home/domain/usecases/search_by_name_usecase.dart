import '../../../../core/domain/base_usecase.dart';
import '../../home_repository.dart';

/// Параметри для SearchByNameUseCase
class SearchByNameParams {
  final String query;
  final int page;

  const SearchByNameParams({
    required this.query,
    this.page = 1,
  });
}

/// Use case для пошуку медіа за назвою
/// 
/// Шукає фільми та серіали за назвою
class SearchByNameUseCase
    implements UseCase<Map<String, dynamic>, SearchByNameParams> {
  final HomeRepository repository;

  SearchByNameUseCase(this.repository);

  @override
  Future<Map<String, dynamic>> call(SearchByNameParams params) async {
    // Бізнес-логіка: валідація та пошук
    if (params.query.trim().isEmpty) {
      throw Exception('Пошуковий запит не може бути порожнім');
    }

    if (params.page < 1) {
      throw Exception('Номер сторінки повинен бути більше 0');
    }

    // Виклик репозиторію для пошуку
    final result = await repository.searchByName(
      params.query,
      page: params.page,
    );

    return result;
  }
}

