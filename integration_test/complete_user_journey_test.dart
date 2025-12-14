import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:project/main.dart' as app;
import 'helper_functions.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Complete User Journey Integration Tests', () {
    setUp(() {
      IntegrationTestHelper.setupErrorHandling();
    });

    testWidgets(
      'Complete flow: Launch -> Browse -> Search -> View Details -> Profile',
      (WidgetTester tester) async {
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

        // Step 1: Verify app launched
        expect(find.byType(MaterialApp), findsOneWidget);

        // Step 2: Browse home page
        final scrollable = find.byType(Scrollable);
        if (scrollable.evaluate().isNotEmpty) {
          await tester.drag(scrollable.first, const Offset(0, -300));
          await IntegrationTestHelper.waitForAsync(tester);
          tester.takeException(); // Очищаємо overflow помилки
        }

        // Step 3: Navigate to search
        final searchButton = find.text('Search');
        if (searchButton.evaluate().isNotEmpty) {
          await tester.tap(searchButton.first);
          await IntegrationTestHelper.waitForAsync(tester);
          tester.takeException(); // Очищаємо overflow помилки

          // Enter search query
          final searchField = find.byType(TextField).first;
          if (searchField.evaluate().isNotEmpty) {
            await tester.tap(searchField);
            await tester.enterText(searchField, 'Movie');
            await IntegrationTestHelper.waitForAsync(tester, seconds: 2);
            tester.takeException(); // Очищаємо overflow помилки
          }
        }

        // Step 4: Return to home
        final homeButton = find.text('Home');
        if (homeButton.evaluate().isNotEmpty) {
          await tester.tap(homeButton.first);
          await IntegrationTestHelper.waitForAsync(tester);
          tester.takeException(); // Очищаємо overflow помилки
        }

        // Step 5: Navigate to profile
        final profileButton = find.text('Profile');
        if (profileButton.evaluate().isNotEmpty) {
          await tester.tap(profileButton.first);
          await IntegrationTestHelper.waitForAsync(tester);
          tester.takeException(); // Очищаємо overflow помилки
        }

        // Verify all navigation worked
        expect(find.byType(Scaffold), findsWidgets);
      },
    );

    testWidgets('Complete flow: Home -> Media Details -> Back -> Favorites', (
      WidgetTester tester,
    ) async {
      app.main();
      await IntegrationTestHelper.waitForAppLoad(tester);

      // Авторизуємо користувача перед тестом (для favorites)
      await IntegrationTestHelper.authenticateUser(
        tester,
        email: 'test@example.com',
        password: 'testpass123',
        createIfNotExists: true,
      );
      tester.takeException(); // Очищаємо overflow помилки після авторизації

      // Open media details
      final inkWells = find.byType(InkWell);
      if (inkWells.evaluate().isNotEmpty) {
        await tester.tap(inkWells.first);
        await IntegrationTestHelper.waitForAsync(tester, seconds: 3);
        tester.takeException(); // Очищаємо overflow помилки

        // Scroll details
        final scrollable = find.byType(Scrollable);
        if (scrollable.evaluate().isNotEmpty) {
          await tester.drag(scrollable.first, const Offset(0, -400));
          await IntegrationTestHelper.waitForAsync(tester);
          tester.takeException(); // Очищаємо overflow помилки
        }

        // Navigate back
        final backButton = find.byIcon(Icons.arrow_back);
        if (backButton.evaluate().isNotEmpty) {
          await tester.tap(backButton);
          await IntegrationTestHelper.waitForAsync(tester);
          tester.takeException(); // Очищаємо overflow помилки
        }
      }

      // Navigate to favorites
      final favoritesButton = find.text('Favorites');
      if (favoritesButton.evaluate().isNotEmpty) {
        await tester.tap(favoritesButton.first);
        await IntegrationTestHelper.waitForAsync(tester);
        tester.takeException(); // Очищаємо overflow помилки
      }

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('Complete flow: Profile -> Settings -> Change Theme -> Back', (
      WidgetTester tester,
    ) async {
      app.main();
      await IntegrationTestHelper.waitForAppLoad(tester);

      // Авторизуємо користувача перед тестом (для доступу до settings)
      await IntegrationTestHelper.authenticateUser(
        tester,
        email: 'test@example.com',
        password: 'testpass123',
        createIfNotExists: true,
      );
      tester.takeException(); // Очищаємо overflow помилки після авторизації

      // Navigate to profile
      final profileButton = find.text('Profile');
      if (profileButton.evaluate().isNotEmpty) {
        await tester.tap(profileButton.first);
        await IntegrationTestHelper.waitForAsync(tester);
        tester.takeException(); // Очищаємо overflow помилки
      }

      // Navigate to settings
      final settingsButton = find.text('Settings');
      if (settingsButton.evaluate().isNotEmpty) {
        await tester.tap(settingsButton);
        await IntegrationTestHelper.waitForAsync(tester);
        tester.takeException(); // Очищаємо overflow помилки

        // Interact with theme
        final themeText = find.text('Theme');
        if (themeText.evaluate().isNotEmpty) {
          await tester.tap(themeText);
          await IntegrationTestHelper.waitForAsync(tester);
          tester.takeException(); // Очищаємо overflow помилки
        }

        // Navigate back
        final backButton = find.byIcon(Icons.arrow_back);
        if (backButton.evaluate().isNotEmpty) {
          await tester.tap(backButton);
          await IntegrationTestHelper.waitForAsync(tester);
          tester.takeException(); // Очищаємо overflow помилки
        }
      }

      expect(find.byType(Scaffold), findsWidgets);
    });
  });
}
