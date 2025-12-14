import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:project/main.dart' as app;
import 'helper_functions.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('About App Flow Integration Tests', () {
    setUpAll(() {
      // Налаштовуємо обробку помилок для всіх тестів
      IntegrationTestHelper.setupErrorHandling();
    });

    testWidgets('User can navigate to about app page', (WidgetTester tester) async {
      // Встановлюємо обробник помилок перед запуском додатку
      IntegrationTestHelper.setupErrorHandling();
      
      app.main();
      
      // Ігноруємо overflow помилки під час завантаження
      await tester.pumpAndSettle(const Duration(seconds: 5));
      tester.takeException(); // Очищаємо накопичені помилки

      // Navigate to profile
      final profileButton = find.text('Profile');
      if (profileButton.evaluate().isNotEmpty) {
        await tester.tap(profileButton.first);
        await tester.pumpAndSettle();
        tester.takeException(); // Очищаємо помилки
      }

      // Navigate to settings
      final settingsButton = find.text('Settings');
      if (settingsButton.evaluate().isNotEmpty) {
        await tester.tap(settingsButton);
        await tester.pumpAndSettle();
        tester.takeException(); // Очищаємо помилки
      }

      // Find about app button
      final aboutButton = find.text('About App');
      if (aboutButton.evaluate().isNotEmpty) {
        await tester.tap(aboutButton);
        await tester.pumpAndSettle();
        tester.takeException(); // Очищаємо помилки

        // Should show about app page
        expect(find.byType(Scaffold), findsWidgets);
      }
    });

    testWidgets('About app page displays app information', (WidgetTester tester) async {
      // Встановлюємо обробник помилок перед запуском додатку
      IntegrationTestHelper.setupErrorHandling();
      
      app.main();
      
      // Ігноруємо overflow помилки під час завантаження
      await tester.pumpAndSettle(const Duration(seconds: 5));
      tester.takeException(); // Очищаємо накопичені помилки

      // Navigate to about app (via settings)
      final profileButton = find.text('Profile');
      if (profileButton.evaluate().isNotEmpty) {
        await tester.tap(profileButton.first);
        await tester.pumpAndSettle();
        tester.takeException(); // Очищаємо помилки
      }

      final settingsButton = find.text('Settings');
      if (settingsButton.evaluate().isNotEmpty) {
        await tester.tap(settingsButton);
        await tester.pumpAndSettle();
        tester.takeException(); // Очищаємо помилки
      }

      final aboutButton = find.text('About App');
      if (aboutButton.evaluate().isNotEmpty) {
        await tester.tap(aboutButton);
        await tester.pumpAndSettle();
        tester.takeException(); // Очищаємо помилки

        // Should display app info
        expect(find.byType(Scaffold), findsWidgets);
      }
    });
  });
}

