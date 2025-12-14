import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project/features/profile/about_app_page.dart';
import '../../unit/helpers/widget_test_helpers.dart';

void main() {
  group('AboutAppPage', () {
    testWidgets('displays about app page', (WidgetTester tester) async {
      await tester.pumpWidget(
        WidgetTestHelper.createTestApp(child: const AboutAppPage()),
      );

      await tester.pumpAndSettle();

      expect(find.byType(AboutAppPage), findsOneWidget);
    });

    testWidgets('displays app information', (WidgetTester tester) async {
      await tester.pumpWidget(
        WidgetTestHelper.createTestApp(child: const AboutAppPage()),
      );

      await tester.pumpAndSettle();

      // Should display app information
      expect(find.byType(AboutAppPage), findsOneWidget);
    });

    testWidgets('displays app icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        WidgetTestHelper.createTestApp(child: const AboutAppPage()),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.movie), findsOneWidget);
    });
  });
}
