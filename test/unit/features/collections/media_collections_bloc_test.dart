import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:project/features/collections/media_collections_bloc.dart';
import 'package:project/features/collections/media_collections_event.dart';
import 'package:project/features/collections/domain/usecases/get_media_collections_usecase.dart';
import 'package:project/features/collections/domain/usecases/toggle_favorite_usecase.dart';
import 'package:project/features/collections/domain/usecases/add_to_watchlist_usecase.dart';
import 'package:project/features/auth/auth_repository.dart';
import 'package:project/features/home/home_media_item.dart';
import 'package:project/features/collections/media_collection_entry.dart';
import '../../helpers/test_helpers.dart';

void main() {
  late MediaCollectionsBloc bloc;
  late MockGetMediaCollectionsUseCase mockGetMediaCollectionsUseCase;
  late MockToggleFavoriteUseCase mockToggleFavoriteUseCase;
  late MockAddToWatchlistUseCase mockAddToWatchlistUseCase;
  late MockAuthRepository mockAuthRepository;

  setUpAll(() {
    registerFallbackValue(const GetMediaCollectionsParams());
  });

  setUp(() {
    mockGetMediaCollectionsUseCase = MockGetMediaCollectionsUseCase();
    mockToggleFavoriteUseCase = MockToggleFavoriteUseCase();
    mockAddToWatchlistUseCase = MockAddToWatchlistUseCase();
    mockAuthRepository = MockAuthRepository();
    
    when(() => mockAuthRepository.currentUser).thenReturn(null);
    when(() => mockAuthRepository.authStateChanges())
        .thenAnswer((_) => Stream.value(null));
    
    bloc = MediaCollectionsBloc(
      getMediaCollectionsUseCase: mockGetMediaCollectionsUseCase,
      toggleFavoriteUseCase: mockToggleFavoriteUseCase,
      addToWatchlistUseCase: mockAddToWatchlistUseCase,
      authRepository: mockAuthRepository,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('MediaCollectionsBloc', () {
    test('initial state has authorized false when user is not authenticated', () {
      expect(bloc.state.authorized, false);
      expect(bloc.state.loading, false);
    });

    blocTest<MediaCollectionsBloc, MediaCollectionsState>(
      'emits collections when LoadCollectionsEvent is successful',
      build: () {
        final result = MediaCollectionsResult(
          favorites: [
            TestDataFactory.createMediaCollectionEntry(key: 'movie_1'),
          ],
          watchlist: [
            TestDataFactory.createMediaCollectionEntry(key: 'movie_2'),
          ],
          favoriteKeys: {'movie_1'},
          watchlistKeys: {'movie_2'},
        );
        when(() => mockGetMediaCollectionsUseCase(any()))
            .thenAnswer((_) async => result);
        when(() => mockAuthRepository.currentUser)
            .thenReturn(TestDataFactory.createLocalUser());
        // Мокуємо authStateChanges як пустий Stream, щоб уникнути автоматичних подій
        when(() => mockAuthRepository.authStateChanges())
            .thenAnswer((_) => const Stream.empty());
        // Створюємо новий BLoC з авторизованим користувачем
        return MediaCollectionsBloc(
          getMediaCollectionsUseCase: mockGetMediaCollectionsUseCase,
          toggleFavoriteUseCase: mockToggleFavoriteUseCase,
          addToWatchlistUseCase: mockAddToWatchlistUseCase,
          authRepository: mockAuthRepository,
        );
      },
      // Пропускаємо початкові стани (автоматичне завантаження при ініціалізації)
      skip: 2,
      act: (bloc) => bloc.add(const LoadCollectionsEvent()),
      expect: () => [
        isA<MediaCollectionsState>().having((s) => s.loading, 'loading', true),
        isA<MediaCollectionsState>()
            .having((s) => s.favorites.length, 'favorites.length', 1)
            .having((s) => s.watchlist.length, 'watchlist.length', 1),
      ],
    );
  });
}

class MockGetMediaCollectionsUseCase extends Mock
    implements GetMediaCollectionsUseCase {}
class MockToggleFavoriteUseCase extends Mock implements ToggleFavoriteUseCase {}
class MockAddToWatchlistUseCase extends Mock implements AddToWatchlistUseCase {}

