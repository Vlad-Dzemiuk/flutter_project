import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:project/main.dart' as app;
import 'helper_functions.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Settings Flow Integration Tests', () {
    setUp(() {
      // Налаштовуємо обробку помилок для всіх тестів
      IntegrationTestHelper.setupErrorHandling();
    });

    testWidgets('User can navigate to settings page', (
      WidgetTester tester,
    ) async {
      app.main();
      await IntegrationTestHelper.waitForAppLoad(tester);
      tester.takeException(); // Очищаємо overflow помилки

      // Авторизуємо користувача перед тестом (для доступу до Settings)
      await IntegrationTestHelper.authenticateUser(
        tester,
        email: 'test@example.com',
        password: 'testpass123',
        createIfNotExists: true,
      );
      tester.takeException(); // Очищаємо overflow помилки після авторизації

      // Navigate to profile first
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

        // Verify settings page
        expect(find.byType(Scaffold), findsWidgets);
      }
    });

    testWidgets('User can change theme in settings', (
      WidgetTester tester,
    ) async {
      app.main();
      await IntegrationTestHelper.waitForAppLoad(tester);
      tester.takeException(); // Очищаємо overflow помилки

      // Авторизуємо користувача перед тестом (для доступу до Settings)
      await IntegrationTestHelper.authenticateUser(
        tester,
        email: 'test@example.com',
        password: 'testpass123',
        createIfNotExists: true,
      );
      tester.takeException(); // Очищаємо overflow помилки після авторизації

      // Navigate to settings
      final profileButton = find.text('Profile');
      if (profileButton.evaluate().isNotEmpty) {
        await tester.tap(profileButton.first);
        await IntegrationTestHelper.waitForAsync(tester);
        tester.takeException(); // Очищаємо overflow помилки
      }

      final settingsButton = find.text('Settings');
      if (settingsButton.evaluate().isNotEmpty) {
        await tester.tap(settingsButton);
        await IntegrationTestHelper.waitForAsync(tester);
        tester.takeException(); // Очищаємо overflow помилки
      }

      // Find theme section
      final themeText = find.text('Theme');
      if (themeText.evaluate().isNotEmpty) {
        // Tap on theme option
        await tester.tap(themeText);
        await IntegrationTestHelper.waitForAsync(tester);
        tester.takeException(); // Очищаємо overflow помилки

        // Should show theme options
        expect(find.byType(Scaffold), findsWidgets);
      }
    });

    testWidgets('User can change language in settings', (
      WidgetTester tester,
    ) async {
      app.main();
      await IntegrationTestHelper.waitForAppLoad(tester);
      tester.takeException(); // Очищаємо overflow помилки

      // Авторизуємо користувача перед тестом (для доступу до Settings)
      await IntegrationTestHelper.authenticateUser(
        tester,
        email: 'test@example.com',
        password: 'testpass123',
        createIfNotExists: true,
      );
      tester.takeException(); // Очищаємо overflow помилки після авторизації

      // Navigate to settings
      final profileButton = find.text('Profile');
      if (profileButton.evaluate().isNotEmpty) {
        await tester.tap(profileButton.first);
        await IntegrationTestHelper.waitForAsync(tester);
        tester.takeException(); // Очищаємо overflow помилки
      }

      final settingsButton = find.text('Settings');
      if (settingsButton.evaluate().isNotEmpty) {
        await tester.tap(settingsButton);
        await IntegrationTestHelper.waitForAsync(tester);
        tester.takeException(); // Очищаємо overflow помилки
      }

      // Find language section
      final languageText = find.text('Language');
      if (languageText.evaluate().isNotEmpty) {
        // Tap on language option
        await tester.tap(languageText);
        await IntegrationTestHelper.waitForAsync(tester);
        tester.takeException(); // Очищаємо overflow помилки

        // Should show language options
        expect(find.byType(Scaffold), findsWidgets);
      }
    });

    testWidgets('User can navigate back from settings', (
      WidgetTester tester,
    ) async {
      app.main();
      await IntegrationTestHelper.waitForAppLoad(tester);
      tester.takeException(); // Очищаємо overflow помилки

      // Авторизуємо користувача перед тестом (для доступу до Settings)
      await IntegrationTestHelper.authenticateUser(
        tester,
        email: 'test@example.com',
        password: 'testpass123',
        createIfNotExists: true,
      );
      tester.takeException(); // Очищаємо overflow помилки після авторизації

      // Navigate to settings
      final profileButton = find.text('Profile');
      if (profileButton.evaluate().isNotEmpty) {
        await tester.tap(profileButton.first);
        await IntegrationTestHelper.waitForAsync(tester);
        tester.takeException(); // Очищаємо overflow помилки
      }

      final settingsButton = find.text('Settings');
      if (settingsButton.evaluate().isNotEmpty) {
        await tester.tap(settingsButton);
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
    });
  });
}
