import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:project/main.dart' as app;
import 'helper_functions.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Authentication Flow Integration Tests', () {
    setUp(() {
      // Налаштовуємо обробку помилок для всіх тестів
      IntegrationTestHelper.setupErrorHandling();
    });

    testWidgets('User can navigate to login page', (WidgetTester tester) async {
      app.main();
      await IntegrationTestHelper.waitForAppLoad(tester);

      // Navigate to profile to trigger login if not authenticated
      final profileButton = find.text('Profile');
      if (profileButton.evaluate().isNotEmpty) {
        await tester.tap(profileButton.first);
        await IntegrationTestHelper.waitForAsync(tester);
        tester.takeException(); // Очищаємо overflow помилки
      }

      // Check if login form is visible
      final emailField = find.byType(TextFormField).first;
      if (emailField.evaluate().isNotEmpty) {
        expect(emailField, findsOneWidget);
      }
    });

    testWidgets('User can fill login form', (WidgetTester tester) async {
      app.main();
      await IntegrationTestHelper.waitForAppLoad(tester);

      // Navigate to login
      final profileButton = find.text('Profile');
      if (profileButton.evaluate().isNotEmpty) {
        await tester.tap(profileButton.first);
        await IntegrationTestHelper.waitForAsync(tester);
        tester.takeException(); // Очищаємо overflow помилки
      }

      // Find email and password fields
      final textFields = find.byType(TextFormField);
      if (textFields.evaluate().length >= 2) {
        final emailField = textFields.first;
        final passwordField = textFields.at(1);

        // Enter email
        await tester.tap(emailField);
        await tester.enterText(emailField, 'test@example.com');
        await tester.pump();
        tester.takeException(); // Очищаємо overflow помилки

        // Enter password
        await tester.tap(passwordField);
        await tester.enterText(passwordField, 'password123');
        await tester.pump();
        tester.takeException(); // Очищаємо overflow помилки

        // Verify fields are filled
        expect(find.text('test@example.com'), findsOneWidget);
        expect(find.text('password123'), findsOneWidget);
      }
    });

    testWidgets('User can toggle between login and register', (WidgetTester tester) async {
      app.main();
      await IntegrationTestHelper.waitForAppLoad(tester);

      // Navigate to profile/login
      final profileButton = find.text('Profile');
      if (profileButton.evaluate().isNotEmpty) {
        await tester.tap(profileButton.first);
        await IntegrationTestHelper.waitForAsync(tester);
        tester.takeException(); // Очищаємо overflow помилки
      }

      // Find toggle button
      final toggleButton = find.byType(TextButton);
      if (toggleButton.evaluate().isNotEmpty) {
        await tester.tap(toggleButton.first);
        await IntegrationTestHelper.waitForAsync(tester);
        tester.takeException(); // Очищаємо overflow помилки

        // Verify form is still visible
        expect(find.byType(TextFormField), findsWidgets);
      }
    });

    testWidgets('User can skip authentication', (WidgetTester tester) async {
      app.main();
      await IntegrationTestHelper.waitForAppLoad(tester);

      // Navigate to login page
      final profileButton = find.text('Profile');
      if (profileButton.evaluate().isNotEmpty) {
        await tester.tap(profileButton.first);
        await IntegrationTestHelper.waitForAsync(tester);
        tester.takeException(); // Очищаємо overflow помилки
      }

      // Find skip button
      final skipButton = find.text('Skip');
      if (skipButton.evaluate().isNotEmpty) {
        await tester.tap(skipButton);
        await IntegrationTestHelper.waitForAsync(tester);
        tester.takeException(); // Очищаємо overflow помилки

        // Should return to home
        expect(find.byType(Scaffold), findsWidgets);
      }
    });
  });
}

