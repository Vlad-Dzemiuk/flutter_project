import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:project/main.dart' as app;
import 'helper_functions.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Content Interaction Integration Tests', () {
    setUp(() {
      IntegrationTestHelper.setupErrorHandling();
    });

    testWidgets('User can interact with media cards on home page', (
      WidgetTester tester,
    ) async {
      app.main();
      await IntegrationTestHelper.waitForAppLoad(tester);

      // Авторизуємо користувача перед тестом (для додавання в favorites)
      await IntegrationTestHelper.authenticateUser(
        tester,
        email: 'test@example.com',
        password: 'testpass123',
        createIfNotExists: true,
      );

      // Find interactive elements
      final inkWells = find.byType(InkWell);
      final gestureDetectors = find.byType(GestureDetector);

      if (inkWells.evaluate().isNotEmpty) {
        // Tap on a media card
        await tester.tap(inkWells.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));
      } else if (gestureDetectors.evaluate().isNotEmpty) {
        await tester.tap(gestureDetectors.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }
    });

    testWidgets('User can scroll through media sections', (
      WidgetTester tester,
    ) async {
      app.main();
      await IntegrationTestHelper.waitForAppLoad(tester);

      // Авторизуємо користувача перед тестом
      await IntegrationTestHelper.authenticateUser(
        tester,
        email: 'test@example.com',
        password: 'testpass123',
        createIfNotExists: true,
      );

      // Find horizontal scrollable lists
      final listViews = find.byType(ListView);
      if (listViews.evaluate().isNotEmpty) {
        // Scroll horizontally if it's a horizontal list
        for (var i = 0; i < listViews.evaluate().length && i < 3; i++) {
          final listView = listViews.at(i);
          await tester.drag(listView, const Offset(-200, 0));
          await tester.pumpAndSettle();
        }
      }
    });

    testWidgets('User can view "See More" for different categories', (
      WidgetTester tester,
    ) async {
      app.main();
      await IntegrationTestHelper.waitForAppLoad(tester);

      // Авторизуємо користувача перед тестом
      await IntegrationTestHelper.authenticateUser(
        tester,
        email: 'test@example.com',
        password: 'testpass123',
        createIfNotExists: true,
      );

      // Find all "More" buttons
      final moreButtons = find.text('More');
      if (moreButtons.evaluate().isNotEmpty) {
        // Tap first "More" button
        await tester.tap(moreButtons.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Should show list page
        expect(find.byType(Scaffold), findsWidgets);

        // Navigate back
        final backButton = find.byIcon(Icons.arrow_back);
        if (backButton.evaluate().isNotEmpty) {
          await tester.tap(backButton);
          await tester.pumpAndSettle();
        }
      }
    });

    testWidgets('User can refresh content with pull-to-refresh', (
      WidgetTester tester,
    ) async {
      app.main();
      await IntegrationTestHelper.waitForAppLoad(tester);

      // Авторизуємо користувача перед тестом
      await IntegrationTestHelper.authenticateUser(
        tester,
        email: 'test@example.com',
        password: 'testpass123',
        createIfNotExists: true,
      );

      // Find RefreshIndicator
      final refreshIndicator = find.byType(RefreshIndicator);
      if (refreshIndicator.evaluate().isNotEmpty) {
        // Perform pull to refresh
        final scrollable = find.byType(Scrollable);
        if (scrollable.evaluate().isNotEmpty) {
          await tester.drag(scrollable.first, const Offset(0, 300));
          await tester.pumpAndSettle(const Duration(seconds: 2));
        }
      }
    });

    testWidgets('User can view media in grid and list views', (
      WidgetTester tester,
    ) async {
      app.main();
      await IntegrationTestHelper.waitForAppLoad(tester);

      // Авторизуємо користувача перед тестом
      await IntegrationTestHelper.authenticateUser(
        tester,
        email: 'test@example.com',
        password: 'testpass123',
        createIfNotExists: true,
      );

      // Check for grid views
      final gridViews = find.byType(GridView);
      if (gridViews.evaluate().isNotEmpty) {
        // Scroll grid
        await tester.drag(gridViews.first, const Offset(0, -300));
        await tester.pumpAndSettle();
      }

      // Check for list views
      final listViews = find.byType(ListView);
      if (listViews.evaluate().isNotEmpty) {
        // Scroll list
        await tester.drag(listViews.first, const Offset(0, -300));
        await tester.pumpAndSettle();
      }
    });
  });
}
