import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:project/features/collections/domain/usecases/get_media_collections_usecase.dart';
import 'package:project/features/collections/media_collection_entry.dart';
import '../../../../helpers/test_helpers.dart';

void main() {
  late GetMediaCollectionsUseCase useCase;
  late MockMediaCollectionsRepository mockRepository;

  setUp(() {
    mockRepository = MockMediaCollectionsRepository();
    useCase = GetMediaCollectionsUseCase(mockRepository);
  });

  group('GetMediaCollectionsUseCase', () {
    test(
      'should return collections with favorite and watchlist keys',
      () async {
        // Arrange
        final favorites = [
          TestDataFactory.createMediaCollectionEntry(
            key: 'movie_1',
            mediaId: 1,
            isMovie: true,
          ),
          TestDataFactory.createMediaCollectionEntry(
            key: 'tv_1',
            mediaId: 1,
            isMovie: false,
          ),
        ];
        final watchlist = [
          TestDataFactory.createMediaCollectionEntry(
            key: 'movie_2',
            mediaId: 2,
            isMovie: true,
          ),
        ];

        when(
          () => mockRepository.fetchFavorites(),
        ).thenAnswer((_) async => favorites);
        when(
          () => mockRepository.fetchWatchlist(),
        ).thenAnswer((_) async => watchlist);

        // Act
        final result = await useCase(const GetMediaCollectionsParams());

        // Assert
        expect(result.favorites.length, 2);
        expect(result.watchlist.length, 1);
        expect(result.favoriteKeys.length, 2);
        expect(result.watchlistKeys.length, 1);
        expect(result.favoriteKeys.contains('movie_1'), true);
        expect(result.favoriteKeys.contains('tv_1'), true);
        expect(result.watchlistKeys.contains('movie_2'), true);
      },
    );

    test('should return empty collections when no data', () async {
      // Arrange
      when(
        () => mockRepository.fetchFavorites(),
      ).thenAnswer((_) async => <MediaCollectionEntry>[]);
      when(
        () => mockRepository.fetchWatchlist(),
      ).thenAnswer((_) async => <MediaCollectionEntry>[]);

      // Act
      final result = await useCase(const GetMediaCollectionsParams());

      // Assert
      expect(result.favorites, isEmpty);
      expect(result.watchlist, isEmpty);
      expect(result.favoriteKeys, isEmpty);
      expect(result.watchlistKeys, isEmpty);
    });
  });
}
