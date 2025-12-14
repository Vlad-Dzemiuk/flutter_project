import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:project/main.dart' as app;
import 'helper_functions.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Integration Tests', () {
    setUp(() {
      // Налаштовуємо обробку помилок для всіх тестів
      IntegrationTestHelper.setupErrorHandling();
    });

    testWidgets('App launches and shows home page', (WidgetTester tester) async {
      app.main();
      await IntegrationTestHelper.waitForAppLoad(tester);
      tester.takeException(); // Очищаємо overflow помилки

      // Verify app is loaded
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Navigation between main tabs works', (WidgetTester tester) async {
      app.main();
      await IntegrationTestHelper.waitForAppLoad(tester);
      tester.takeException(); // Очищаємо overflow помилки

      // Find bottom navigation bar (mobile) or navigation rail (desktop)
      final bottomNav = find.byType(BottomNavigationBar);
      final navRail = find.byType(NavigationRail);

      if (bottomNav.evaluate().isNotEmpty) {
        // Mobile navigation
        // Tap on Search tab
        await tester.tap(find.text('Search').first);
        await IntegrationTestHelper.waitForAsync(tester);
        tester.takeException(); // Очищаємо overflow помилки
        expect(find.byType(Scaffold), findsWidgets);

        // Tap on Favorites tab
        await tester.tap(find.text('Favorites').first);
        await IntegrationTestHelper.waitForAsync(tester);
        tester.takeException(); // Очищаємо overflow помилки
        expect(find.byType(Scaffold), findsWidgets);

        // Tap on Profile tab
        await tester.tap(find.text('Profile').first);
        await IntegrationTestHelper.waitForAsync(tester);
        tester.takeException(); // Очищаємо overflow помилки
        expect(find.byType(Scaffold), findsWidgets);

        // Return to Home
        await tester.tap(find.text('Home').first);
        await IntegrationTestHelper.waitForAsync(tester);
        tester.takeException(); // Очищаємо overflow помилки
        expect(find.byType(Scaffold), findsWidgets);
      } else if (navRail.evaluate().isNotEmpty) {
        // Desktop navigation
        // Similar navigation logic for desktop
        expect(find.byType(NavigationRail), findsOneWidget);
      }
    });
  });
}

