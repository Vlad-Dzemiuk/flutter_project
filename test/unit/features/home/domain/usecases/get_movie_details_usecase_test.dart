import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:project/features/home/domain/usecases/get_movie_details_usecase.dart';
import 'package:project/features/home/home_repository.dart';
import '../../../../helpers/test_helpers.dart';

void main() {
  late GetMovieDetailsUseCase useCase;
  late MockHomeRepository mockRepository;

  setUp(() {
    mockRepository = MockHomeRepository();
    useCase = GetMovieDetailsUseCase(mockRepository);
  });

  group('GetMovieDetailsUseCase', () {
    test('should return combined movie details', () async {
      // Arrange
      final details = {'id': 1, 'title': 'Test Movie'};
      final videos = [
        {'id': '1', 'key': 'abc123'},
      ];
      final reviews = [
        {'id': '1', 'content': 'Great movie'},
      ];
      final recommendations = [
        TestDataFactory.createMovie(id: 2, title: 'Recommended Movie'),
      ];

      when(
        () => mockRepository.fetchMovieDetails(any()),
      ).thenAnswer((_) async => details);
      when(
        () => mockRepository.fetchMovieVideos(any()),
      ).thenAnswer((_) async => videos);
      when(
        () => mockRepository.fetchMovieReviews(any()),
      ).thenAnswer((_) async => reviews);
      when(
        () => mockRepository.fetchMovieRecommendations(any()),
      ).thenAnswer((_) async => recommendations);

      // Act
      final result = await useCase(const GetMovieDetailsParams(movieId: 1));

      // Assert
      expect(result, isA<Map<String, dynamic>>());
      expect(result['details'], details);
      expect(result['videos'], videos);
      expect(result['reviews'], reviews);
      expect(result['recommendations'], recommendations);
      verify(() => mockRepository.fetchMovieDetails(1)).called(1);
      verify(() => mockRepository.fetchMovieVideos(1)).called(1);
      verify(() => mockRepository.fetchMovieReviews(1)).called(1);
      verify(() => mockRepository.fetchMovieRecommendations(1)).called(1);
    });

    test('should throw exception when movieId is invalid', () async {
      // Act & Assert
      expect(
        () => useCase(const GetMovieDetailsParams(movieId: 0)),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Невірний ID фільму'),
          ),
        ),
      );
      expect(
        () => useCase(const GetMovieDetailsParams(movieId: -1)),
        throwsA(isA<Exception>()),
      );
      verifyNever(() => mockRepository.fetchMovieDetails(any()));
    });
  });
}
