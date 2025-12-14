import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project/shared/widgets/loading_wrapper.dart';
import 'package:project/core/loading_state.dart';
import 'package:project/core/di.dart';
import 'package:project/core/constants.dart';
import '../../unit/helpers/widget_test_helpers.dart';

void main() {
  setUp(() {
    // Initialize GetIt for LoadingStateService before each test
    if (!getIt.isRegistered<LoadingStateService>()) {
      getIt.registerLazySingleton<LoadingStateService>(
        () => LoadingStateService(),
      );
    }
  });

  tearDown(() {
    // Reset loading state after each test
    getIt<LoadingStateService>().reset();
  });

  group('LoadingWrapper', () {
    testWidgets('displays child when home page is loaded', (
      WidgetTester tester,
    ) async {
      const childText = 'Test Content';

      await tester.pumpWidget(
        WidgetTestHelper.createTestApp(
          child: const LoadingWrapper(child: Text(childText)),
          setHomePageLoaded: true,
        ),
      );

      expect(find.text(childText), findsOneWidget);
    });

    testWidgets('displays loading when home page is not loaded', (
      WidgetTester tester,
    ) async {
      const childText = 'Test Content';

      await tester.pumpWidget(
        WidgetTestHelper.createTestApp(
          child: const LoadingWrapper(child: Text(childText)),
          setHomePageLoaded: false,
        ),
      );

      // Should show loading widget
      expect(find.text(childText), findsNothing);
      expect(find.text('Завантаження...'), findsOneWidget);
    });

    testWidgets('shows child for auth page even when not loaded', (
      WidgetTester tester,
    ) async {
      const childText = 'Login Page';

      // Initialize GetIt for this test
      if (!getIt.isRegistered<LoadingStateService>()) {
        getIt.registerLazySingleton<LoadingStateService>(
          () => LoadingStateService(),
        );
      }
      getIt<LoadingStateService>().reset(); // Ensure not loaded

      await tester.pumpWidget(
        MaterialApp(
          initialRoute: AppConstants.loginRoute,
          routes: {
            AppConstants.loginRoute: (context) =>
                const LoadingWrapper(child: Text(childText)),
          },
        ),
      );

      await tester.pumpAndSettle();

      // For auth pages, should show child even if not loaded
      expect(find.byType(LoadingWrapper), findsOneWidget);
      expect(find.text(childText), findsOneWidget);
    });
  });
}
