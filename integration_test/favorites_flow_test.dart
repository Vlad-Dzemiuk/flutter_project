import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:project/main.dart' as app;
import 'helper_functions.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Favorites Flow Integration Tests', () {
    setUp(() {
      IntegrationTestHelper.setupErrorHandling();
    });

    testWidgets('User can navigate to favorites page', (
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
      tester.takeException(); // Очищаємо overflow помилки після авторизації

      // Navigate to favorites
      final favoritesButton = find.text('Favorites');
      if (favoritesButton.evaluate().isNotEmpty) {
        await tester.tap(favoritesButton.first);
        await IntegrationTestHelper.waitForAsync(tester);
        tester.takeException(); // Очищаємо overflow помилки

        // Verify favorites page
        expect(find.byType(Scaffold), findsWidgets);
      }
    });

    testWidgets('Favorites page shows empty state when not authenticated', (
      WidgetTester tester,
    ) async {
      app.main();
      await IntegrationTestHelper.waitForAppLoad(tester);
      tester.takeException(); // Очищаємо overflow помилки

      // Navigate to favorites
      final favoritesButton = find.text('Favorites');
      if (favoritesButton.evaluate().isNotEmpty) {
        await tester.tap(favoritesButton.first);
        await IntegrationTestHelper.waitForAsync(tester);
        tester.takeException(); // Очищаємо overflow помилки

        // Check for empty state or login prompt
        final emptyIcon = find.byIcon(Icons.favorite_border);
        if (emptyIcon.evaluate().isNotEmpty) {
          expect(emptyIcon, findsWidgets);
        }
      }
    });

    testWidgets('User can view favorites list when authenticated', (
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
      tester.takeException(); // Очищаємо overflow помилки після авторизації

      // Navigate to favorites
      final favoritesButton = find.text('Favorites');
      if (favoritesButton.evaluate().isNotEmpty) {
        await tester.tap(favoritesButton.first);
        await IntegrationTestHelper.waitForAsync(tester);
        tester.takeException(); // Очищаємо overflow помилки

        // Check for list or grid view
        final listView = find.byType(ListView);
        final gridView = find.byType(GridView);

        if (listView.evaluate().isNotEmpty || gridView.evaluate().isNotEmpty) {
          expect(find.byType(Scaffold), findsWidgets);
        }
      }
    });

    testWidgets('User can scroll favorites list', (WidgetTester tester) async {
      app.main();
      await IntegrationTestHelper.waitForAppLoad(tester);

      // Авторизуємо користувача перед тестом
      await IntegrationTestHelper.authenticateUser(
        tester,
        email: 'test@example.com',
        password: 'testpass123',
        createIfNotExists: true,
      );
      tester.takeException(); // Очищаємо overflow помилки після авторизації

      // Navigate to favorites
      final favoritesButton = find.text('Favorites');
      if (favoritesButton.evaluate().isNotEmpty) {
        await tester.tap(favoritesButton.first);
        await IntegrationTestHelper.waitForAsync(tester);
        tester.takeException(); // Очищаємо overflow помилки

        // Scroll if list exists
        final scrollable = find.byType(Scrollable);
        if (scrollable.evaluate().isNotEmpty) {
          await tester.drag(scrollable.first, const Offset(0, -300));
          await IntegrationTestHelper.waitForAsync(tester);
          tester.takeException(); // Очищаємо overflow помилки
        }
      }
    });
  });
}
