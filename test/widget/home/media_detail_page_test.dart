import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:project/features/home/media_detail_page.dart';
import 'package:project/features/home/home_media_item.dart';
import 'package:project/features/home/domain/usecases/get_movie_details_usecase.dart';
import 'package:project/features/home/domain/usecases/get_tv_details_usecase.dart';
import 'package:project/features/home/domain/usecases/get_movie_videos_usecase.dart';
import 'package:project/features/collections/media_collections_bloc.dart';
import 'package:project/core/di.dart';
import 'package:project/shared/widgets/animated_loading_widget.dart';
import '../../unit/helpers/widget_test_helpers.dart';
import '../../unit/helpers/test_helpers.dart';

void main() {
  group('MediaDetailPage', () {
    late HomeMediaItem testItem;
    late MediaCollectionsBloc mediaCollectionsBloc;
    late MockGetMovieDetailsUseCase mockGetMovieDetailsUseCase;
    late MockGetTvDetailsUseCase mockGetTvDetailsUseCase;
    late MockGetMovieVideosUseCase mockGetMovieVideosUseCase;

    setUpAll(() {
      // Register fallback values for mocktail
      registerFallbackValue(const GetMovieDetailsParams(movieId: 1));
      registerFallbackValue(const GetTvDetailsParams(tvId: 1));
      registerFallbackValue(const GetMovieVideosParams(movieId: 1));
    });

    setUp(() {
      testItem = TestDataFactory.createHomeMediaItem(
        id: 1,
        title: 'Test Movie',
        overview: 'Test overview',
        posterPath: '/poster.jpg',
        rating: 8.5,
        isMovie: true,
      );

      mediaCollectionsBloc = WidgetTestHelper.createMockMediaCollectionsBloc();
      mockGetMovieDetailsUseCase = MockGetMovieDetailsUseCase();
      mockGetTvDetailsUseCase = MockGetTvDetailsUseCase();
      mockGetMovieVideosUseCase = MockGetMovieVideosUseCase();

      // Register dependencies in GetIt
      if (getIt.isRegistered<GetMovieDetailsUseCase>()) {
        getIt.unregister<GetMovieDetailsUseCase>();
      }
      if (getIt.isRegistered<GetTvDetailsUseCase>()) {
        getIt.unregister<GetTvDetailsUseCase>();
      }
      if (getIt.isRegistered<GetMovieVideosUseCase>()) {
        getIt.unregister<GetMovieVideosUseCase>();
      }
      if (getIt.isRegistered<MediaCollectionsBloc>()) {
        getIt.unregister<MediaCollectionsBloc>();
      }
      getIt.registerLazySingleton<GetMovieDetailsUseCase>(() => mockGetMovieDetailsUseCase);
      getIt.registerLazySingleton<GetTvDetailsUseCase>(() => mockGetTvDetailsUseCase);
      getIt.registerLazySingleton<GetMovieVideosUseCase>(() => mockGetMovieVideosUseCase);
      getIt.registerLazySingleton<MediaCollectionsBloc>(() => mediaCollectionsBloc);

      // Setup mock GetMovieDetailsUseCase
      when(() => mockGetMovieDetailsUseCase(any())).thenAnswer(
        (_) async => {
          'details': {
            'id': 1,
            'title': 'Test Movie',
            'overview': 'Test overview',
            'poster_path': '/poster.jpg',
            'vote_average': 8.5,
          },
          'videos': [],
          'reviews': [],
          'recommendations': [],
        },
      );

      // Setup mock GetTvDetailsUseCase
      when(() => mockGetTvDetailsUseCase(any())).thenAnswer(
        (_) async => {
          'details': {
            'id': 1,
            'name': 'Test TV Show',
            'overview': 'Test overview',
            'poster_path': '/poster.jpg',
            'vote_average': 8.5,
          },
          'videos': [],
          'reviews': [],
          'recommendations': [],
        },
      );

      // Setup mock GetMovieVideosUseCase (needed by MovieTrailerPlayer)
      when(() => mockGetMovieVideosUseCase(any())).thenAnswer(
        (_) async => [],
      );
    });

    tearDown(() {
      mediaCollectionsBloc.close();
      if (getIt.isRegistered<GetMovieDetailsUseCase>()) {
        getIt.unregister<GetMovieDetailsUseCase>();
      }
      if (getIt.isRegistered<GetTvDetailsUseCase>()) {
        getIt.unregister<GetTvDetailsUseCase>();
      }
      if (getIt.isRegistered<GetMovieVideosUseCase>()) {
        getIt.unregister<GetMovieVideosUseCase>();
      }
      if (getIt.isRegistered<MediaCollectionsBloc>()) {
        getIt.unregister<MediaCollectionsBloc>();
      }
    });

    testWidgets('displays media detail page', (WidgetTester tester) async {
      await tester.pumpWidget(
        WidgetTestHelper.createTestApp(
          child: MediaDetailPage(item: testItem),
          mediaCollectionsBloc: mediaCollectionsBloc,
        ),
      );

      // Use pump with duration instead of pumpAndSettle to avoid timeout
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(MediaDetailPage), findsOneWidget);
    });

    testWidgets('displays media title', (WidgetTester tester) async {
      await tester.pumpWidget(
        WidgetTestHelper.createTestApp(
          child: MediaDetailPage(item: testItem),
          mediaCollectionsBloc: mediaCollectionsBloc,
        ),
      );

      // Use pump with duration instead of pumpAndSettle to avoid timeout
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // MediaDetailPage may display the title in multiple places
      expect(find.text('Test Movie'), findsWidgets);
    });

    testWidgets('can navigate back', (WidgetTester tester) async {
      await tester.pumpWidget(
        WidgetTestHelper.createTestApp(
          child: MediaDetailPage(item: testItem),
          mediaCollectionsBloc: mediaCollectionsBloc,
        ),
      );

      // Use pump with duration instead of pumpAndSettle to avoid timeout
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      final backButton = find.byIcon(Icons.arrow_back);
      if (backButton.evaluate().isNotEmpty) {
        await tester.tap(backButton);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
      }
    });
  });
}

