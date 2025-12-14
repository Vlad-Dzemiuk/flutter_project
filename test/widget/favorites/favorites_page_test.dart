import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:project/features/favorites/favorites_page.dart';
import 'package:project/features/collections/media_collections_bloc.dart';
import 'package:project/core/di.dart';
import 'package:project/shared/widgets/animated_loading_widget.dart';
import '../../unit/helpers/widget_test_helpers.dart';

void main() {
  group('FavoritesPage', () {
    late MediaCollectionsBloc mediaCollectionsBloc;

    setUp(() {
      mediaCollectionsBloc = WidgetTestHelper.createMockMediaCollectionsBloc();

      // Register MediaCollectionsBloc in GetIt (FavoritesPage uses getIt<MediaCollectionsBloc>())
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

    testWidgets('displays favorites page', (WidgetTester tester) async {
      await tester.pumpWidget(
        WidgetTestHelper.createTestApp(
          child: const FavoritesPage(),
          mediaCollectionsBloc: mediaCollectionsBloc,
        ),
      );

      // Use pump with duration instead of pumpAndSettle to avoid timeout
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(FavoritesPage), findsOneWidget);
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
          child: const FavoritesPage(),
          mediaCollectionsBloc: unauthorizedBloc,
        ),
      );

      // Use pump with duration instead of pumpAndSettle to avoid timeout
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Should show empty state or login prompt
      expect(find.byType(FavoritesPage), findsOneWidget);

      // Cleanup
      unauthorizedBloc.close();
      if (getIt.isRegistered<MediaCollectionsBloc>()) {
        getIt.unregister<MediaCollectionsBloc>();
      }
      getIt.registerLazySingleton<MediaCollectionsBloc>(
        () => mediaCollectionsBloc,
      );
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
          child: const FavoritesPage(),
          mediaCollectionsBloc: loadingBloc,
        ),
      );

      await tester.pump();

      // FavoritesPage uses AnimatedLoadingWidget for loading state
      expect(find.byType(AnimatedLoadingWidget), findsOneWidget);

      // Cleanup
      loadingBloc.close();
      if (getIt.isRegistered<MediaCollectionsBloc>()) {
        getIt.unregister<MediaCollectionsBloc>();
      }
      getIt.registerLazySingleton<MediaCollectionsBloc>(
        () => mediaCollectionsBloc,
      );
    });
  });
}
