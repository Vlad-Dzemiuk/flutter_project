import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:project/features/home/home_bloc.dart';
import 'package:project/features/home/home_event.dart';
import 'package:project/features/home/domain/usecases/get_popular_content_usecase.dart';
import 'package:project/features/home/domain/usecases/search_media_usecase.dart';
import '../../helpers/test_helpers.dart';

void main() {
  late HomeBloc homeBloc;
  late MockGetPopularContentUseCase mockGetPopularContentUseCase;
  late MockSearchMediaUseCase mockSearchMediaUseCase;

  setUpAll(() {
    // Register fallback values for mocktail
    registerFallbackValue(const GetPopularContentParams());
    registerFallbackValue(const SearchMediaParams());
  });

  setUp(() {
    mockGetPopularContentUseCase = MockGetPopularContentUseCase();
    mockSearchMediaUseCase = MockSearchMediaUseCase();
    // Mock the use cases to return default values to prevent errors during initialization
    when(() => mockGetPopularContentUseCase(any())).thenAnswer(
      (_) async => const PopularContentResult(
        popularMovies: [],
        popularTvShows: [],
        allMovies: [],
        allTvShows: [],
      ),
    );
    when(() => mockSearchMediaUseCase(any())).thenAnswer(
      (_) async => const SearchMediaResult(results: [], hasMore: false),
    );
    homeBloc = HomeBloc(
      getPopularContentUseCase: mockGetPopularContentUseCase,
      searchMediaUseCase: mockSearchMediaUseCase,
    );
  });

  tearDown(() {
    homeBloc.close();
  });

  group('HomeBloc', () {
    blocTest<HomeBloc, HomeState>(
      'emits loading then loaded state when LoadContentEvent is successful',
      build: () {
        final result = PopularContentResult(
          popularMovies: [],
          popularTvShows: [],
          allMovies: [],
          allTvShows: [],
        );
        when(
          () => mockGetPopularContentUseCase(any()),
        ).thenAnswer((_) async => result);
        return HomeBloc(
          getPopularContentUseCase: mockGetPopularContentUseCase,
          searchMediaUseCase: mockSearchMediaUseCase,
        );
      },
      wait: const Duration(
        milliseconds: 200,
      ), // Wait for initial LoadContentEvent to complete
      skip:
          2, // Skip initial LoadContentEvent states (loading: true, loading: false)
      act: (bloc) => bloc.add(const LoadContentEvent()),
      expect: () => [
        isA<HomeState>().having((s) => s.loading, 'loading', true),
        isA<HomeState>().having((s) => s.loading, 'loading', false),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'emits error state when LoadContentEvent fails',
      build: () {
        when(
          () => mockGetPopularContentUseCase(any()),
        ).thenThrow(Exception('Network error'));
        return HomeBloc(
          getPopularContentUseCase: mockGetPopularContentUseCase,
          searchMediaUseCase: mockSearchMediaUseCase,
        );
      },
      wait: const Duration(
        milliseconds: 200,
      ), // Wait for initial LoadContentEvent to complete
      skip: 2, // Skip initial LoadContentEvent states
      act: (bloc) => bloc.add(const LoadContentEvent()),
      expect: () => [
        isA<HomeState>().having((s) => s.loading, 'loading', true),
        isA<HomeState>()
            .having((s) => s.loading, 'loading', false)
            .having((s) => s.error, 'error', isNotEmpty),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'emits search results when SearchEvent is successful',
      build: () {
        final result = SearchMediaResult(
          results: [
            TestDataFactory.createHomeMediaItem(id: 1),
            TestDataFactory.createHomeMediaItem(id: 2),
          ],
          hasMore: false,
        );
        when(
          () => mockSearchMediaUseCase(any()),
        ).thenAnswer((_) async => result);
        return HomeBloc(
          getPopularContentUseCase: mockGetPopularContentUseCase,
          searchMediaUseCase: mockSearchMediaUseCase,
        );
      },
      wait: const Duration(
        milliseconds: 200,
      ), // Wait for initial LoadContentEvent to complete
      skip: 2, // Skip initial LoadContentEvent states
      act: (bloc) => bloc.add(const SearchEvent(query: 'test')),
      expect: () => [
        isA<HomeState>().having((s) => s.searching, 'searching', true),
        isA<HomeState>()
            .having((s) => s.searching, 'searching', false)
            .having((s) => s.searchResults.length, 'searchResults.length', 2),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'clears search results when ClearSearchEvent is emitted',
      build: () {
        return HomeBloc(
          getPopularContentUseCase: mockGetPopularContentUseCase,
          searchMediaUseCase: mockSearchMediaUseCase,
        );
      },
      wait: const Duration(
        milliseconds: 200,
      ), // Wait for initial LoadContentEvent to complete
      skip: 2, // Skip initial LoadContentEvent states
      seed: () => HomeState(
        searchResults: [TestDataFactory.createHomeMediaItem(id: 1)],
        searchQuery: 'test',
      ),
      act: (bloc) => bloc.add(const ClearSearchEvent()),
      expect: () => [
        isA<HomeState>()
            .having((s) => s.searchResults, 'searchResults', isEmpty)
            .having((s) => s.searchQuery, 'searchQuery', isNull),
      ],
    );
  });
}

class MockGetPopularContentUseCase extends Mock
    implements GetPopularContentUseCase {}

class MockSearchMediaUseCase extends Mock implements SearchMediaUseCase {}
