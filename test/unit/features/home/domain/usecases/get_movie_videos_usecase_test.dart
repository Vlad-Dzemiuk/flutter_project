import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:project/features/home/domain/usecases/get_movie_videos_usecase.dart';
import '../../../../helpers/test_helpers.dart';

void main() {
  late GetMovieVideosUseCase useCase;
  late MockHomeRepository mockRepository;

  setUp(() {
    mockRepository = MockHomeRepository();
    useCase = GetMovieVideosUseCase(mockRepository);
  });

  group('GetMovieVideosUseCase', () {
    test('should return list of videos when successful', () async {
      // Arrange
      final videosData = [
        {'id': '1', 'key': 'abc123', 'name': 'Trailer', 'type': 'Trailer'},
        {'id': '2', 'key': 'def456', 'name': 'Teaser', 'type': 'Teaser'},
      ];

      when(
        () => mockRepository.fetchMovieVideos(any()),
      ).thenAnswer((_) async => videosData);

      // Act
      final result = await useCase(const GetMovieVideosParams(movieId: 1));

      // Assert
      expect(result.length, 2);
      expect(result[0].key, 'abc123');
      expect(result[1].key, 'def456');
      verify(() => mockRepository.fetchMovieVideos(1)).called(1);
    });

    test('should throw exception when movieId is invalid', () async {
      // Act & Assert
      expect(
        () => useCase(const GetMovieVideosParams(movieId: 0)),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Невірний ID фільму'),
          ),
        ),
      );
      expect(
        () => useCase(const GetMovieVideosParams(movieId: -1)),
        throwsA(isA<Exception>()),
      );
      verifyNever(() => mockRepository.fetchMovieVideos(any()));
    });
  });
}
