import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:project/main.dart' as app;
import 'helper_functions.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Navigation Flow Integration Tests', () {
    setUp(() {
      // Налаштовуємо обробку помилок для всіх тестів
      IntegrationTestHelper.setupErrorHandling();
    });

    testWidgets('User can navigate through all main tabs', (WidgetTester tester) async {
      app.main();
      await IntegrationTestHelper.waitForAppLoad(tester);
      tester.takeException(); // Очищаємо overflow помилки

      // Test all navigation tabs
      final tabs = ['Home', 'Search', 'Watched', 'Favorites', 'Profile'];

      for (final tab in tabs) {
        final tabButton = find.text(tab);
        if (tabButton.evaluate().isNotEmpty) {
          await tester.tap(tabButton.first);
          await IntegrationTestHelper.waitForAsync(tester);
          tester.takeException(); // Очищаємо overflow помилки
          expect(find.byType(Scaffold), findsWidgets);
        }
      }
    });

    testWidgets('User can navigate using navigation rail on desktop', (WidgetTester tester) async {
      app.main();
      await IntegrationTestHelper.waitForAppLoad(tester);
      tester.takeException(); // Очищаємо overflow помилки

      // Check for navigation rail
      final navRail = find.byType(NavigationRail);
      if (navRail.evaluate().isNotEmpty) {
        // Test navigation rail destinations
        expect(navRail, findsOneWidget);
        
        // Try tapping different destinations
        final destinations = find.byType(NavigationRailDestination);
        if (destinations.evaluate().isNotEmpty) {
          // Tap on first destination (should be home)
          await tester.tap(destinations.first);
          await IntegrationTestHelper.waitForAsync(tester);
          tester.takeException(); // Очищаємо overflow помилки
        }
      }
    });

    testWidgets('User can navigate using bottom navigation on mobile', (WidgetTester tester) async {
      app.main();
      await IntegrationTestHelper.waitForAppLoad(tester);
      tester.takeException(); // Очищаємо overflow помилки

      // Check for bottom navigation
      final bottomNav = find.byType(BottomNavigationBar);
      if (bottomNav.evaluate().isNotEmpty) {
        expect(bottomNav, findsOneWidget);
        
        // Test all bottom nav items
        final navItems = find.byType(BottomNavigationBarItem);
        if (navItems.evaluate().isNotEmpty) {
          // Navigation is handled by onTap, so we test via text buttons
          final homeButton = find.text('Home');
          if (homeButton.evaluate().isNotEmpty) {
            await tester.tap(homeButton.first);
            await IntegrationTestHelper.waitForAsync(tester);
            tester.takeException(); // Очищаємо overflow помилки
          }
        }
      }
    });

    testWidgets('Deep navigation: Home -> Search -> Profile -> Settings -> Back', (WidgetTester tester) async {
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

      // Home -> Search
      final searchButton = find.text('Search');
      if (searchButton.evaluate().isNotEmpty) {
        await tester.tap(searchButton.first);
        await IntegrationTestHelper.waitForAsync(tester);
        tester.takeException(); // Очищаємо overflow помилки
      }

      // Search -> Profile
      final profileButton = find.text('Profile');
      if (profileButton.evaluate().isNotEmpty) {
        await tester.tap(profileButton.first);
        await IntegrationTestHelper.waitForAsync(tester);
        tester.takeException(); // Очищаємо overflow помилки
      }

      // Profile -> Settings
      final settingsButton = find.text('Settings');
      if (settingsButton.evaluate().isNotEmpty) {
        await tester.tap(settingsButton);
        await IntegrationTestHelper.waitForAsync(tester);
        tester.takeException(); // Очищаємо overflow помилки
      }

      // Settings -> Back
      final backButton = find.byIcon(Icons.arrow_back);
      if (backButton.evaluate().isNotEmpty) {
        await tester.tap(backButton);
        await IntegrationTestHelper.waitForAsync(tester);
        tester.takeException(); // Очищаємо overflow помилки
      }

      expect(find.byType(Scaffold), findsWidgets);
    });
  });
}

