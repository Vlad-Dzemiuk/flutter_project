import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:project/features/favorites/favorites_bloc.dart';
import 'package:project/features/favorites/favorites_event.dart';
import 'package:project/features/favorites/domain/usecases/get_favorites_usecase.dart';
import 'package:project/features/home/data/models/movie_model.dart';
import '../../helpers/test_helpers.dart';

void main() {
  late FavoritesBloc favoritesBloc;
  late MockGetFavoritesUseCase mockGetFavoritesUseCase;

  setUpAll(() {
    // Register fallback value for GetFavoritesParams
    registerFallbackValue(const GetFavoritesParams(accountId: 1));
  });

  setUp(() {
    mockGetFavoritesUseCase = MockGetFavoritesUseCase();
    // Mock the use case to return a default value to prevent errors during initialization
    when(() => mockGetFavoritesUseCase(any()))
        .thenAnswer((_) async => <Movie>[]);
    favoritesBloc = FavoritesBloc(
      getFavoritesUseCase: mockGetFavoritesUseCase,
    );
  });

  tearDown(() {
    favoritesBloc.close();
  });

  group('FavoritesBloc', () {
    blocTest<FavoritesBloc, FavoritesState>(
      'emits loading then loaded state when LoadFavoritesEvent is successful',
      build: () {
        final movies = [
          TestDataFactory.createMovie(id: 1),
          TestDataFactory.createMovie(id: 2),
        ];
        when(() => mockGetFavoritesUseCase(any()))
            .thenAnswer((_) async => movies);
        return FavoritesBloc(
          getFavoritesUseCase: mockGetFavoritesUseCase,
        );
      },
      wait: const Duration(milliseconds: 200), // Wait for initial LoadFavoritesEvent to complete
      skip: 2, // Skip initial LoadFavoritesEvent states (loading: true, loading: false)
      act: (bloc) => bloc.add(const LoadFavoritesEvent()),
      expect: () => [
        isA<FavoritesState>().having((s) => s.loading, 'loading', true),
        isA<FavoritesState>().having(
          (s) => s.loading,
          'loading',
          false,
        ).having(
          (s) => s.movies.length,
          'movies.length',
          2,
        ),
      ],
    );

    blocTest<FavoritesBloc, FavoritesState>(
      'emits error state when LoadFavoritesEvent fails',
      build: () {
        when(() => mockGetFavoritesUseCase(any()))
            .thenThrow(Exception('Network error'));
        return FavoritesBloc(
          getFavoritesUseCase: mockGetFavoritesUseCase,
        );
      },
      wait: const Duration(milliseconds: 200), // Wait for initial LoadFavoritesEvent to complete
      skip: 2, // Skip initial LoadFavoritesEvent states
      act: (bloc) => bloc.add(const LoadFavoritesEvent()),
      expect: () => [
        isA<FavoritesState>().having((s) => s.loading, 'loading', true),
        isA<FavoritesState>().having(
          (s) => s.loading,
          'loading',
          false,
        ).having(
          (s) => s.error,
          'error',
          isNotEmpty,
        ),
      ],
    );
  });
}

class MockGetFavoritesUseCase extends Mock implements GetFavoritesUseCase {}

