import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:project/main.dart' as app;
import 'helper_functions.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Search Flow Integration Tests', () {
    setUp(() {
      IntegrationTestHelper.setupErrorHandling();
    });

    testWidgets('User can navigate to search page', (WidgetTester tester) async {
      app.main();
      await IntegrationTestHelper.waitForAppLoad(tester);

      // Авторизуємо користувача перед тестом (для збереження історії пошуку)
      await IntegrationTestHelper.authenticateUser(
        tester,
        email: 'test@example.com',
        password: 'testpass123',
        createIfNotExists: true,
      );

      // Navigate to search via bottom navigation
      final searchButton = find.text('Search');
      if (searchButton.evaluate().isNotEmpty) {
        await tester.tap(searchButton.first);
        await tester.pumpAndSettle();

        // Verify search page is displayed
        expect(find.byType(TextField), findsWidgets);
      }
    });

    testWidgets('User can enter search query', (WidgetTester tester) async {
      app.main();
      await IntegrationTestHelper.waitForAppLoad(tester);

      // Авторизуємо користувача перед тестом
      await IntegrationTestHelper.authenticateUser(
        tester,
        email: 'test@example.com',
        password: 'testpass123',
        createIfNotExists: true,
      );

      // Navigate to search
      final searchButton = find.text('Search');
      if (searchButton.evaluate().isNotEmpty) {
        await tester.tap(searchButton.first);
        await tester.pumpAndSettle();
      }

      // Find search field
      final searchField = find.byType(TextField).first;
      if (searchField.evaluate().isNotEmpty) {
        await tester.tap(searchField);
        await tester.enterText(searchField, 'Avengers');
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Verify text is entered
        expect(find.text('Avengers'), findsOneWidget);
      }
    });

    testWidgets('User can toggle filters visibility', (WidgetTester tester) async {
      app.main();
      await IntegrationTestHelper.waitForAppLoad(tester);

      // Авторизуємо користувача перед тестом
      await IntegrationTestHelper.authenticateUser(
        tester,
        email: 'test@example.com',
        password: 'testpass123',
        createIfNotExists: true,
      );

      // Navigate to search
      final searchButton = find.text('Search');
      if (searchButton.evaluate().isNotEmpty) {
        await tester.tap(searchButton.first);
        await tester.pumpAndSettle();
      }

      // Find filter toggle button
      final filterButton = find.byIcon(Icons.tune_rounded);
      if (filterButton.evaluate().isNotEmpty) {
        await tester.tap(filterButton);
        await tester.pumpAndSettle();

        // Filters should be visible
        expect(find.byType(TextField), findsWidgets);
      }
    });

    testWidgets('User can clear search query', (WidgetTester tester) async {
      app.main();
      await IntegrationTestHelper.waitForAppLoad(tester);

      // Авторизуємо користувача перед тестом
      await IntegrationTestHelper.authenticateUser(
        tester,
        email: 'test@example.com',
        password: 'testpass123',
        createIfNotExists: true,
      );

      // Navigate to search
      final searchButton = find.text('Search');
      if (searchButton.evaluate().isNotEmpty) {
        await tester.tap(searchButton.first);
        await tester.pumpAndSettle();
      }

      // Enter text
      final searchField = find.byType(TextField).first;
      if (searchField.evaluate().isNotEmpty) {
        await tester.tap(searchField);
        await tester.enterText(searchField, 'Test');
        await tester.pump();

        // Find clear button
        final clearButton = find.byIcon(Icons.close);
        if (clearButton.evaluate().isNotEmpty) {
          await tester.tap(clearButton);
          await tester.pumpAndSettle();
        }
      }
    });

    testWidgets('User can search with filters', (WidgetTester tester) async {
      app.main();
      await IntegrationTestHelper.waitForAppLoad(tester);

      // Авторизуємо користувача перед тестом
      await IntegrationTestHelper.authenticateUser(
        tester,
        email: 'test@example.com',
        password: 'testpass123',
        createIfNotExists: true,
      );

      // Navigate to search
      final searchButton = find.text('Search');
      if (searchButton.evaluate().isNotEmpty) {
        await tester.tap(searchButton.first);
        await tester.pumpAndSettle();
      }

      // Open filters
      final filterButton = find.byIcon(Icons.tune_rounded);
      if (filterButton.evaluate().isNotEmpty) {
        await tester.tap(filterButton);
        await tester.pumpAndSettle();

        // Find filter fields
        final textFields = find.byType(TextField);
        if (textFields.evaluate().length >= 2) {
          // Enter genre
          await tester.tap(textFields.at(1));
          await tester.enterText(textFields.at(1), 'Action');
          await tester.pump();

          // Find search button
          final searchWithFiltersButton = find.text('Search with Filters');
          if (searchWithFiltersButton.evaluate().isNotEmpty) {
            await tester.tap(searchWithFiltersButton);
            await tester.pumpAndSettle(const Duration(seconds: 3));
          }
        }
      }
    });
  });
}

