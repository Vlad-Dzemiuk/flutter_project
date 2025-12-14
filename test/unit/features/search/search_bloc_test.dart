import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:project/features/search/search_bloc.dart';
import 'package:project/features/search/search_event.dart';
import 'package:project/features/search/search_state.dart';
import 'package:project/features/search/domain/usecases/search_by_filters_usecase.dart';
import 'package:project/features/home/data/models/movie_model.dart';
import '../../helpers/test_helpers.dart';

void main() {
  late SearchBloc searchBloc;
  late MockSearchByFiltersUseCase mockSearchByFiltersUseCase;

  setUpAll(() {
    // Register fallback value for SearchByFiltersParams
    registerFallbackValue(const SearchByFiltersParams());
  });

  setUp(() {
    mockSearchByFiltersUseCase = MockSearchByFiltersUseCase();
    searchBloc = SearchBloc(searchByFiltersUseCase: mockSearchByFiltersUseCase);
  });

  tearDown(() {
    searchBloc.close();
  });

  group('SearchBloc', () {
    test('initial state is SearchInitial', () {
      expect(searchBloc.state, isA<SearchInitial>());
    });

    blocTest<SearchBloc, SearchState>(
      'emits [SearchLoading, SearchLoaded] when SearchByFilters is successful',
      build: () {
        final movies = [
          TestDataFactory.createMovie(id: 1),
          TestDataFactory.createMovie(id: 2),
        ];
        when(
          () => mockSearchByFiltersUseCase(any()),
        ).thenAnswer((_) async => movies);
        return searchBloc;
      },
      act: (bloc) =>
          bloc.add(const SearchByFilters(genre: 'Action', year: 2020)),
      expect: () => [
        isA<SearchLoading>(),
        isA<SearchLoaded>().having((s) => s.movies.length, 'movies.length', 2),
      ],
    );

    blocTest<SearchBloc, SearchState>(
      'emits [SearchLoading, SearchError] when SearchByFilters fails',
      build: () {
        when(
          () => mockSearchByFiltersUseCase(any()),
        ).thenThrow(Exception('Network error'));
        return searchBloc;
      },
      act: (bloc) => bloc.add(const SearchByFilters(genre: 'Action')),
      expect: () => [isA<SearchLoading>(), isA<SearchError>()],
    );
  });
}

class MockSearchByFiltersUseCase extends Mock
    implements SearchByFiltersUseCase {}
