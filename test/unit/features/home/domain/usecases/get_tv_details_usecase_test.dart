import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:project/features/home/domain/usecases/get_tv_details_usecase.dart';
import 'package:project/features/home/home_repository.dart';
import '../../../../helpers/test_helpers.dart';

void main() {
  late GetTvDetailsUseCase useCase;
  late MockHomeRepository mockRepository;

  setUp(() {
    mockRepository = MockHomeRepository();
    useCase = GetTvDetailsUseCase(mockRepository);
  });

  group('GetTvDetailsUseCase', () {
    test('should return combined TV details', () async {
      // Arrange
      final details = {'id': 1, 'name': 'Test TV Show'};
      final videos = [
        {'id': '1', 'key': 'abc123'},
      ];
      final reviews = [
        {'id': '1', 'content': 'Great show'},
      ];
      final recommendations = [
        TestDataFactory.createTvShow(id: 2, name: 'Recommended Show'),
      ];

      when(
        () => mockRepository.fetchTvDetails(any()),
      ).thenAnswer((_) async => details);
      when(
        () => mockRepository.fetchTvVideos(any()),
      ).thenAnswer((_) async => videos);
      when(
        () => mockRepository.fetchTvReviews(any()),
      ).thenAnswer((_) async => reviews);
      when(
        () => mockRepository.fetchTvRecommendations(any()),
      ).thenAnswer((_) async => recommendations);

      // Act
      final result = await useCase(const GetTvDetailsParams(tvId: 1));

      // Assert
      expect(result, isA<Map<String, dynamic>>());
      expect(result['details'], details);
      expect(result['videos'], videos);
      expect(result['reviews'], reviews);
      expect(result['recommendations'], recommendations);
      verify(() => mockRepository.fetchTvDetails(1)).called(1);
      verify(() => mockRepository.fetchTvVideos(1)).called(1);
      verify(() => mockRepository.fetchTvReviews(1)).called(1);
      verify(() => mockRepository.fetchTvRecommendations(1)).called(1);
    });

    test('should throw exception when tvId is invalid', () async {
      // Act & Assert
      expect(
        () => useCase(const GetTvDetailsParams(tvId: 0)),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Невірний ID серіалу'),
          ),
        ),
      );
      expect(
        () => useCase(const GetTvDetailsParams(tvId: -1)),
        throwsA(isA<Exception>()),
      );
      verifyNever(() => mockRepository.fetchTvDetails(any()));
    });
  });
}
