import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:project/features/collections/domain/usecases/add_to_watchlist_usecase.dart';
import 'package:project/features/collections/domain/repositories/media_collections_repository.dart';
import 'package:project/features/home/home_media_item.dart';
import 'package:project/features/collections/media_collection_entry.dart';
import '../../../../helpers/test_helpers.dart';

void main() {
  late AddToWatchlistUseCase useCase;
  late MockMediaCollectionsRepository mockRepository;

  setUpAll(() {
    // Register fallback value for HomeMediaItem
    registerFallbackValue(TestDataFactory.createHomeMediaItem());
  });

  setUp(() {
    mockRepository = MockMediaCollectionsRepository();
    useCase = AddToWatchlistUseCase(mockRepository);
  });

  group('AddToWatchlistUseCase', () {
    test('should add item to watchlist when not already in watchlist', () async {
      // Arrange
      final item = TestDataFactory.createHomeMediaItem(id: 1, isMovie: true);
      final emptyWatchlist = <MediaCollectionEntry>[];
      final updatedWatchlist = [
        TestDataFactory.createMediaCollectionEntry(
          key: 'movie_1',
          mediaId: 1,
          isMovie: true,
        ),
      ];

      var fetchCallCount = 0;
      when(() => mockRepository.fetchWatchlist())
          .thenAnswer((_) async {
            fetchCallCount++;
            return fetchCallCount == 1 ? emptyWatchlist : updatedWatchlist;
          });
      when(() => mockRepository.addToWatchlist(any()))
          .thenAnswer((_) async {});

      // Act
      final result = await useCase(AddToWatchlistParams(item: item));

      // Assert
      expect(result.watchlist.length, 1);
      expect(result.watchlistKeys.contains('movie_1'), true);
      verify(() => mockRepository.addToWatchlist(item)).called(1);
    });
  });
}

