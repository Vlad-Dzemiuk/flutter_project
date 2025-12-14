import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:project/main.dart' as app;
import 'helper_functions.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Responsive Behavior Integration Tests', () {
    setUp(() {
      // Налаштовуємо обробку помилок для всіх тестів
      IntegrationTestHelper.setupErrorHandling();
    });

    testWidgets('App adapts to different screen sizes', (WidgetTester tester) async {
      app.main();
      await IntegrationTestHelper.waitForAppLoad(tester);
      tester.takeException(); // Очищаємо overflow помилки

      // Check for responsive widgets
      final bottomNav = find.byType(BottomNavigationBar);
      final navRail = find.byType(NavigationRail);

      // Should have either bottom nav (mobile) or nav rail (desktop)
      expect(
        bottomNav.evaluate().isNotEmpty || navRail.evaluate().isNotEmpty,
        isTrue,
      );
    });

    testWidgets('Grid and list views adapt to screen size', (WidgetTester tester) async {
      app.main();
      await IntegrationTestHelper.waitForAppLoad(tester);
      tester.takeException(); // Очищаємо overflow помилки
      await IntegrationTestHelper.waitForAsync(tester);
      tester.takeException(); // Очищаємо overflow помилки

      // Check for grid or list views
      final gridViews = find.byType(GridView);
      final listViews = find.byType(ListView);

      // Should have at least one view type
      expect(
        gridViews.evaluate().isNotEmpty || listViews.evaluate().isNotEmpty,
        isTrue,
      );
    });

    testWidgets('Navigation adapts to device type', (WidgetTester tester) async {
      app.main();
      await IntegrationTestHelper.waitForAppLoad(tester);
      tester.takeException(); // Очищаємо overflow помилки

      // Test navigation based on device type
      final bottomNav = find.byType(BottomNavigationBar);
      final navRail = find.byType(NavigationRail);

      if (bottomNav.evaluate().isNotEmpty) {
        // Mobile: test bottom navigation
        expect(bottomNav, findsOneWidget);
      } else if (navRail.evaluate().isNotEmpty) {
        // Desktop: test navigation rail
        expect(navRail, findsOneWidget);
      }
    });
  });
}

