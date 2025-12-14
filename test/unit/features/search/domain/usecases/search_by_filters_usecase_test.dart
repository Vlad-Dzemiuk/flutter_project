import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:project/features/search/domain/usecases/search_by_filters_usecase.dart';
import 'package:project/features/search/domain/repositories/search_repository.dart';
import 'package:project/features/home/data/models/movie_model.dart';
import '../../../../helpers/test_helpers.dart';

void main() {
  late SearchByFiltersUseCase useCase;
  late MockSearchRepository mockRepository;

  setUp(() {
    mockRepository = MockSearchRepository();
    useCase = SearchByFiltersUseCase(mockRepository);
  });

  group('SearchByFiltersUseCase', () {
    test('should return list of movies when search is successful', () async {
      // Arrange
      final movies = [
        TestDataFactory.createMovie(id: 1),
        TestDataFactory.createMovie(id: 2),
      ];

      when(() => mockRepository.searchMovies(
        genreName: any(named: 'genreName'),
        year: any(named: 'year'),
        rating: any(named: 'rating'),
        page: any(named: 'page'),
      )).thenAnswer((_) async => movies);

      // Act
      final result = await useCase(
        SearchByFiltersParams(
          genreName: 'Action',
          year: 2020,
          rating: 8.0,
          page: 1,
        ),
      );

      // Assert
      expect(result.length, 2);
      verify(() => mockRepository.searchMovies(
        genreName: 'Action',
        year: 2020,
        rating: 8.0,
        page: 1,
      )).called(1);
    });

    test('should throw exception when page is less than 1', () async {
      // Act & Assert
      expect(
        () => useCase(SearchByFiltersParams(page: 0)),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Номер сторінки повинен бути більше 0'),
        )),
      );
    });

    test('should use default page 1 when not specified', () async {
      // Arrange
      when(() => mockRepository.searchMovies(
        genreName: any(named: 'genreName'),
        year: any(named: 'year'),
        rating: any(named: 'rating'),
        page: any(named: 'page'),
      )).thenAnswer((_) async => []);

      // Act
      await useCase(const SearchByFiltersParams());

      // Assert
      verify(() => mockRepository.searchMovies(
        genreName: null,
        year: null,
        rating: null,
        page: 1,
      )).called(1);
    });
  });
}

