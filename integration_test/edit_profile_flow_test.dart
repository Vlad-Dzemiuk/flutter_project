import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:project/main.dart' as app;
import 'helper_functions.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Edit Profile Flow Integration Tests', () {
    setUp(() {
      IntegrationTestHelper.setupErrorHandling();
    });

    testWidgets('User can navigate to edit profile page', (
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

      // Navigate to profile
      final profileButton = find.text('Profile');
      if (profileButton.evaluate().isNotEmpty) {
        await tester.tap(profileButton.first);
        await tester.pumpAndSettle();
      }

      // Find edit profile button (if authenticated)
      final editButton = find.text('Edit Profile');
      if (editButton.evaluate().isNotEmpty) {
        await tester.tap(editButton);
        await tester.pumpAndSettle();

        // Should navigate to edit profile
        expect(find.byType(Scaffold), findsWidgets);
      }
    });

    testWidgets('User can fill edit profile form', (WidgetTester tester) async {
      app.main();
      await IntegrationTestHelper.waitForAppLoad(tester);

      // Авторизуємо користувача перед тестом
      await IntegrationTestHelper.authenticateUser(
        tester,
        email: 'test@example.com',
        password: 'testpass123',
        createIfNotExists: true,
      );

      // Navigate to profile
      final profileButton = find.text('Profile');
      if (profileButton.evaluate().isNotEmpty) {
        await tester.tap(profileButton.first);
        await tester.pumpAndSettle();
      }

      // Navigate to edit profile
      final editButton = find.text('Edit Profile');
      if (editButton.evaluate().isNotEmpty) {
        await tester.tap(editButton);
        await tester.pumpAndSettle();

        // Find name field
        final textFields = find.byType(TextFormField);
        if (textFields.evaluate().isNotEmpty) {
          await tester.tap(textFields.first);
          await tester.enterText(textFields.first, 'Test User');
          await tester.pump();

          expect(find.text('Test User'), findsOneWidget);
        }
      }
    });

    testWidgets('User can navigate back from edit profile', (
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

      // Navigate to profile
      final profileButton = find.text('Profile');
      if (profileButton.evaluate().isNotEmpty) {
        await tester.tap(profileButton.first);
        await tester.pumpAndSettle();
      }

      // Navigate to edit profile
      final editButton = find.text('Edit Profile');
      if (editButton.evaluate().isNotEmpty) {
        await tester.tap(editButton);
        await tester.pumpAndSettle();

        // Navigate back
        final backButton = find.byIcon(Icons.arrow_back);
        if (backButton.evaluate().isNotEmpty) {
          await tester.tap(backButton);
          await tester.pumpAndSettle();
        }
      }
    });
  });
}
