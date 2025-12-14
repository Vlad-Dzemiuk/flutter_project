import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:project/features/home/media_list_page.dart';
import 'package:project/features/home/domain/usecases/get_popular_content_usecase.dart';
import 'package:project/features/collections/media_collections_bloc.dart';
import 'package:project/core/di.dart';
import '../../unit/helpers/widget_test_helpers.dart';
import '../../unit/helpers/test_helpers.dart';

void main() {
  group('MediaListPage', () {
    late MediaCollectionsBloc mediaCollectionsBloc;
    late MockGetPopularContentUseCase mockGetPopularContentUseCase;

    setUpAll(() {
      // Register fallback values for mocktail
      registerFallbackValue(const GetPopularContentParams());
    });

    setUp(() {
      mediaCollectionsBloc = WidgetTestHelper.createMockMediaCollectionsBloc();
      mockGetPopularContentUseCase = MockGetPopularContentUseCase();

      // Register dependencies in GetIt
      if (getIt.isRegistered<GetPopularContentUseCase>()) {
        getIt.unregister<GetPopularContentUseCase>();
      }
      if (getIt.isRegistered<MediaCollectionsBloc>()) {
        getIt.unregister<MediaCollectionsBloc>();
      }
      getIt.registerLazySingleton<GetPopularContentUseCase>(
        () => mockGetPopularContentUseCase,
      );
      getIt.registerLazySingleton<MediaCollectionsBloc>(
        () => mediaCollectionsBloc,
      );

      // Setup mock GetPopularContentUseCase
      when(() => mockGetPopularContentUseCase(any())).thenAnswer(
        (_) async => const PopularContentResult(
          popularMovies: [],
          popularTvShows: [],
          allMovies: [],
          allTvShows: [],
        ),
      );
    });

    tearDown(() {
      mediaCollectionsBloc.close();
      if (getIt.isRegistered<GetPopularContentUseCase>()) {
        getIt.unregister<GetPopularContentUseCase>();
      }
      if (getIt.isRegistered<MediaCollectionsBloc>()) {
        getIt.unregister<MediaCollectionsBloc>();
      }
    });

    testWidgets('displays media list page', (WidgetTester tester) async {
      await tester.pumpWidget(
        WidgetTestHelper.createTestApp(
          child: const MediaListPage(
            category: MediaListCategory.popularMovies,
            title: 'Popular Movies',
          ),
          mediaCollectionsBloc: mediaCollectionsBloc,
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(MediaListPage), findsOneWidget);
    });

    testWidgets('displays page title', (WidgetTester tester) async {
      await tester.pumpWidget(
        WidgetTestHelper.createTestApp(
          child: const MediaListPage(
            category: MediaListCategory.popularMovies,
            title: 'Popular Movies',
          ),
          mediaCollectionsBloc: mediaCollectionsBloc,
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Popular Movies'), findsOneWidget);
    });
  });
}
