import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:project/features/home/domain/usecases/search_by_name_usecase.dart';
import '../../../../helpers/test_helpers.dart';

void main() {
  late SearchByNameUseCase useCase;
  late MockHomeRepository mockRepository;

  setUp(() {
    mockRepository = MockHomeRepository();
    useCase = SearchByNameUseCase(mockRepository);
  });

  group('SearchByNameUseCase', () {
    test('should return search results when query is valid', () async {
      // Arrange
      final result = {
        'movies': [TestDataFactory.createMovie()],
        'tvShows': [TestDataFactory.createTvShow()],
        'hasMore': false,
      };

      when(
        () => mockRepository.searchByName(any(), page: any(named: 'page')),
      ).thenAnswer((_) async => result);

      // Act
      final searchResult = await useCase(
        SearchByNameParams(query: 'test', page: 1),
      );

      // Assert
      expect(searchResult, result);
      verify(() => mockRepository.searchByName('test', page: 1)).called(1);
    });

    test('should throw exception when query is empty', () async {
      // Act & Assert
      expect(
        () => useCase(SearchByNameParams(query: '')),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Пошуковий запит не може бути порожнім'),
          ),
        ),
      );
    });

    test('should throw exception when query is only whitespace', () async {
      // Act & Assert
      expect(
        () => useCase(SearchByNameParams(query: '   ')),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw exception when page is less than 1', () async {
      // Act & Assert
      expect(
        () => useCase(SearchByNameParams(query: 'test', page: 0)),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Номер сторінки повинен бути більше 0'),
          ),
        ),
      );
    });

    test('should use default page 1 when not specified', () async {
      // Arrange
      when(
        () => mockRepository.searchByName(any(), page: any(named: 'page')),
      ).thenAnswer((_) async => {});

      // Act
      await useCase(SearchByNameParams(query: 'test'));

      // Assert
      verify(() => mockRepository.searchByName('test', page: 1)).called(1);
    });
  });
}
