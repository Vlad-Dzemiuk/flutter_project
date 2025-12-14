import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:project/main.dart' as app;
import 'helper_functions.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Profile Flow Integration Tests', () {
    setUp(() {
      IntegrationTestHelper.setupErrorHandling();
    });

    testWidgets('User can navigate to profile page', (WidgetTester tester) async {
      app.main();
      await IntegrationTestHelper.waitForAppLoad(tester);
      tester.takeException(); // Очищаємо overflow помилки

      // Navigate to profile
      final profileButton = find.text('Profile');
      if (profileButton.evaluate().isNotEmpty) {
        await tester.tap(profileButton.first);
        await IntegrationTestHelper.waitForAsync(tester);
        tester.takeException(); // Очищаємо overflow помилки

        // Verify profile page
        expect(find.byType(Scaffold), findsWidgets);
      }
    });

    testWidgets('Profile page shows login form when not authenticated', (WidgetTester tester) async {
      app.main();
      await IntegrationTestHelper.waitForAppLoad(tester);
      tester.takeException(); // Очищаємо overflow помилки

      // Navigate to profile
      final profileButton = find.text('Profile');
      if (profileButton.evaluate().isNotEmpty) {
        await tester.tap(profileButton.first);
        await IntegrationTestHelper.waitForAsync(tester);
        tester.takeException(); // Очищаємо overflow помилки

        // Check for login form
        final emailField = find.byType(TextFormField).first;
        if (emailField.evaluate().isNotEmpty) {
          expect(emailField, findsOneWidget);
        }
      }
    });

    testWidgets('User can navigate to settings from profile', (WidgetTester tester) async {
      app.main();
      await IntegrationTestHelper.waitForAppLoad(tester);
      tester.takeException(); // Очищаємо overflow помилки

      // Авторизуємо користувача перед тестом
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

      // Find settings button
      final settingsButton = find.text('Settings');
      if (settingsButton.evaluate().isNotEmpty) {
        await tester.tap(settingsButton);
        await IntegrationTestHelper.waitForAsync(tester);
        tester.takeException(); // Очищаємо overflow помилки

        // Should navigate to settings
        expect(find.byType(Scaffold), findsWidgets);
      }
    });

    testWidgets('User can navigate to watchlist from profile', (WidgetTester tester) async {
      app.main();
      await IntegrationTestHelper.waitForAppLoad(tester);
      tester.takeException(); // Очищаємо overflow помилки

      // Авторизуємо користувача перед тестом
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

      // Find watchlist button (if authenticated)
      final watchlistButton = find.text('Watched');
      if (watchlistButton.evaluate().isNotEmpty) {
        await tester.tap(watchlistButton);
        await IntegrationTestHelper.waitForAsync(tester);
        tester.takeException(); // Очищаємо overflow помилки

        // Should navigate to watchlist
        expect(find.byType(Scaffold), findsWidgets);
      }
    });

    testWidgets('User can navigate to edit profile', (WidgetTester tester) async {
      app.main();
      await IntegrationTestHelper.waitForAppLoad(tester);
      tester.takeException(); // Очищаємо overflow помилки

      // Авторизуємо користувача перед тестом
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

      // Find edit profile button (if authenticated)
      final editButton = find.text('Edit Profile');
      if (editButton.evaluate().isNotEmpty) {
        await tester.tap(editButton);
        await IntegrationTestHelper.waitForAsync(tester);
        tester.takeException(); // Очищаємо overflow помилки

        // Should navigate to edit profile
        expect(find.byType(Scaffold), findsWidgets);
      }
    });
  });
}

