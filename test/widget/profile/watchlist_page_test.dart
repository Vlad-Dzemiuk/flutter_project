import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:project/features/profile/watchlist_page.dart';
import 'package:project/features/collections/media_collections_bloc.dart';
import 'package:project/core/di.dart';
import 'package:project/shared/widgets/animated_loading_widget.dart';
import '../../unit/helpers/widget_test_helpers.dart';

void main() {
  group('WatchlistPage', () {
    late MediaCollectionsBloc mediaCollectionsBloc;

    setUp(() {
      mediaCollectionsBloc = WidgetTestHelper.createMockMediaCollectionsBloc();

      // Register MediaCollectionsBloc in GetIt
      if (getIt.isRegistered<MediaCollectionsBloc>()) {
        getIt.unregister<MediaCollectionsBloc>();
      }
      getIt.registerLazySingleton<MediaCollectionsBloc>(
        () => mediaCollectionsBloc,
      );
    });

    tearDown(() {
      mediaCollectionsBloc.close();
      if (getIt.isRegistered<MediaCollectionsBloc>()) {
        getIt.unregister<MediaCollectionsBloc>();
      }
    });

    testWidgets('displays watchlist page', (WidgetTester tester) async {
      await tester.pumpWidget(
        WidgetTestHelper.createTestApp(
          child: const WatchlistPage(),
          mediaCollectionsBloc: mediaCollectionsBloc,
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(WatchlistPage), findsOneWidget);
    });

    testWidgets('displays empty state when not authorized', (
      WidgetTester tester,
    ) async {
      final unauthorizedBloc = WidgetTestHelper.createMockMediaCollectionsBloc(
        isAuthorized: false,
      );

      // Register the unauthorized bloc in GetIt
      if (getIt.isRegistered<MediaCollectionsBloc>()) {
        getIt.unregister<MediaCollectionsBloc>();
      }
      getIt.registerLazySingleton<MediaCollectionsBloc>(() => unauthorizedBloc);

      await tester.pumpWidget(
        WidgetTestHelper.createTestApp(
          child: const WatchlistPage(),
          mediaCollectionsBloc: unauthorizedBloc,
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(WatchlistPage), findsOneWidget);

      // Cleanup
      if (getIt.isRegistered<MediaCollectionsBloc>()) {
        getIt.unregister<MediaCollectionsBloc>();
      }
      unauthorizedBloc.close();
    });

    testWidgets('displays loading state when loading', (
      WidgetTester tester,
    ) async {
      final loadingBloc = WidgetTestHelper.createMockMediaCollectionsBloc(
        isAuthorized: true,
      );
      when(() => loadingBloc.state).thenReturn(
        MediaCollectionsState(
          authorized: true,
          loading: true,
          favorites: [],
          watchlist: [],
        ),
      );

      // Register the loading bloc in GetIt
      if (getIt.isRegistered<MediaCollectionsBloc>()) {
        getIt.unregister<MediaCollectionsBloc>();
      }
      getIt.registerLazySingleton<MediaCollectionsBloc>(() => loadingBloc);

      await tester.pumpWidget(
        WidgetTestHelper.createTestApp(
          child: const WatchlistPage(),
          mediaCollectionsBloc: loadingBloc,
        ),
      );

      await tester.pump();

      // WatchlistPage uses AnimatedLoadingWidget for loading state
      expect(find.byType(AnimatedLoadingWidget), findsOneWidget);

      // Cleanup
      if (getIt.isRegistered<MediaCollectionsBloc>()) {
        getIt.unregister<MediaCollectionsBloc>();
      }
      loadingBloc.close();
    });
  });
}
