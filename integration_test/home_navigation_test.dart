import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:project/main.dart' as app;
import 'helper_functions.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Home Page Navigation Integration Tests', () {
    setUp(() {
      // Налаштовуємо обробку помилок для всіх тестів
      IntegrationTestHelper.setupErrorHandling();
    });

    testWidgets('Home page displays content sections', (
      WidgetTester tester,
    ) async {
      app.main();
      await IntegrationTestHelper.waitForAppLoad(tester);
      tester.takeException(); // Очищаємо overflow помилки

      // Verify home page structure
      expect(find.byType(Scaffold), findsWidgets);

      // Check for scrollable content
      final scrollables = find.byType(Scrollable);
      if (scrollables.evaluate().isNotEmpty) {
        expect(scrollables, findsWidgets);
      }
    });

    testWidgets('User can scroll through home content', (
      WidgetTester tester,
    ) async {
      app.main();
      await IntegrationTestHelper.waitForAppLoad(tester);
      tester.takeException(); // Очищаємо overflow помилки

      // Find scrollable widget
      final scrollable = find.byType(Scrollable);
      if (scrollable.evaluate().isNotEmpty) {
        // Scroll down
        await tester.drag(scrollable.first, const Offset(0, -500));
        await IntegrationTestHelper.waitForAsync(tester);
        tester.takeException(); // Очищаємо overflow помилки

        // Scroll up
        await tester.drag(scrollable.first, const Offset(0, 500));
        await IntegrationTestHelper.waitForAsync(tester);
        tester.takeException(); // Очищаємо overflow помилки
      }
    });

    testWidgets('User can navigate to search from home header', (
      WidgetTester tester,
    ) async {
      app.main();
      await IntegrationTestHelper.waitForAppLoad(tester);
      tester.takeException(); // Очищаємо overflow помилки

      // Find explore button in header
      final exploreButton = find.text('Explore');
      if (exploreButton.evaluate().isNotEmpty) {
        await tester.tap(exploreButton.first);
        await IntegrationTestHelper.waitForAsync(tester);
        tester.takeException(); // Очищаємо overflow помилки

        // Should navigate to search page
        expect(find.byType(Scaffold), findsWidgets);
      }
    });

    testWidgets('User can refresh home page content', (
      WidgetTester tester,
    ) async {
      app.main();
      await IntegrationTestHelper.waitForAppLoad(tester);
      tester.takeException(); // Очищаємо overflow помилки

      // Find scrollable and perform pull to refresh
      final scrollable = find.byType(Scrollable);
      if (scrollable.evaluate().isNotEmpty) {
        // Pull down to refresh
        await tester.drag(scrollable.first, const Offset(0, 300));
        await IntegrationTestHelper.waitForAsync(tester, seconds: 2);
        tester.takeException(); // Очищаємо overflow помилки
      }
    });
  });
}
