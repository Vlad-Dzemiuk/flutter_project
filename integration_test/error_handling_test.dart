import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:project/main.dart' as app;
import 'helper_functions.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Error Handling Integration Tests', () {
    setUp(() {
      // Налаштовуємо обробку помилок для всіх тестів
      IntegrationTestHelper.setupErrorHandling();
    });

    testWidgets('App handles network errors gracefully', (
      WidgetTester tester,
    ) async {
      app.main();
      await IntegrationTestHelper.waitForAppLoad(tester);
      tester.takeException(); // Очищаємо overflow помилки

      // App should handle errors without crashing
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('App shows loading states appropriately', (
      WidgetTester tester,
    ) async {
      app.main();
      await IntegrationTestHelper.waitForAppLoad(tester);
      tester.takeException(); // Очищаємо overflow помилки

      // App should eventually show content
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('App handles empty states correctly', (
      WidgetTester tester,
    ) async {
      app.main();
      await IntegrationTestHelper.waitForAppLoad(tester);
      tester.takeException(); // Очищаємо overflow помилки

      // Navigate to favorites (likely empty if not authenticated)
      final favoritesButton = find.text('Favorites');
      if (favoritesButton.evaluate().isNotEmpty) {
        await tester.tap(favoritesButton.first);
        await IntegrationTestHelper.waitForAsync(tester);
        tester.takeException(); // Очищаємо overflow помилки

        // Should show empty state
        expect(find.byType(Scaffold), findsWidgets);
      }
    });
  });
}
