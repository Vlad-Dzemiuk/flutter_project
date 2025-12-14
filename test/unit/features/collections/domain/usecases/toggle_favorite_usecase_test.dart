import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:project/features/collections/domain/usecases/toggle_favorite_usecase.dart';
import 'package:project/features/collections/media_collection_entry.dart';
import '../../../../helpers/test_helpers.dart';

void main() {
  late ToggleFavoriteUseCase useCase;
  late MockMediaCollectionsRepository mockRepository;

  setUpAll(() {
    // Register fallback value for HomeMediaItem
    registerFallbackValue(TestDataFactory.createHomeMediaItem());
  });

  setUp(() {
    mockRepository = MockMediaCollectionsRepository();
    useCase = ToggleFavoriteUseCase(mockRepository);
  });

  group('ToggleFavoriteUseCase', () {
    test('should add to favorites when item is not favorite', () async {
      // Arrange
      final item = TestDataFactory.createHomeMediaItem(id: 1, isMovie: true);
      final emptyFavorites = <MediaCollectionEntry>[];
      final updatedFavorites = [
        TestDataFactory.createMediaCollectionEntry(
          key: 'movie_1',
          mediaId: 1,
          isMovie: true,
        ),
      ];

      when(
        () => mockRepository.fetchFavorites(),
      ).thenAnswer((_) async => emptyFavorites);
      when(
        () => mockRepository.toggleFavorite(any()),
      ).thenAnswer((_) async => Future.value());
      when(
        () => mockRepository.fetchFavorites(),
      ).thenAnswer((_) async => updatedFavorites);

      // Act
      final result = await useCase(ToggleFavoriteParams(item: item));

      // Assert
      expect(result.isFavorite, true);
      expect(result.favorites.length, 1);
      expect(result.favoriteKeys.contains('movie_1'), true);
      verify(() => mockRepository.toggleFavorite(item)).called(1);
    });

    test('should handle TV show items correctly', () async {
      // Arrange
      final item = TestDataFactory.createHomeMediaItem(id: 1, isMovie: false);
      final emptyFavorites = <MediaCollectionEntry>[];
      final updatedFavorites = [
        TestDataFactory.createMediaCollectionEntry(
          key: 'tv_1',
          mediaId: 1,
          isMovie: false,
        ),
      ];

      when(
        () => mockRepository.fetchFavorites(),
      ).thenAnswer((_) async => emptyFavorites);
      when(
        () => mockRepository.toggleFavorite(any()),
      ).thenAnswer((_) async => Future.value());
      when(
        () => mockRepository.fetchFavorites(),
      ).thenAnswer((_) async => updatedFavorites);

      // Act
      final result = await useCase(ToggleFavoriteParams(item: item));

      // Assert
      expect(result.favoriteKeys.contains('tv_1'), true);
    });
  });
}
