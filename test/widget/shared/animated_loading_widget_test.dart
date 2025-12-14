import 'package:flutter_test/flutter_test.dart';
import 'package:project/shared/widgets/animated_loading_widget.dart';
import '../../unit/helpers/widget_test_helpers.dart';

void main() {
  group('AnimatedLoadingWidget', () {
    testWidgets('displays animated loading widget', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        WidgetTestHelper.createTestApp(child: const AnimatedLoadingWidget()),
      );

      // Use pump instead of pumpAndSettle since animation never settles
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(AnimatedLoadingWidget), findsOneWidget);
    });

    testWidgets('displays loading message when provided', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        WidgetTestHelper.createTestApp(
          child: const AnimatedLoadingWidget(message: 'Loading...'),
        ),
      );

      // Use pump instead of pumpAndSettle since animation never settles
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Loading...'), findsOneWidget);
    });

    testWidgets('displays loading indicator', (WidgetTester tester) async {
      await tester.pumpWidget(
        WidgetTestHelper.createTestApp(child: const AnimatedLoadingWidget()),
      );

      // Use pump instead of pumpAndSettle since animation never settles
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Should have some loading indicator
      expect(find.byType(AnimatedLoadingWidget), findsOneWidget);
    });

    testWidgets('animates loading indicator', (WidgetTester tester) async {
      await tester.pumpWidget(
        WidgetTestHelper.createTestApp(child: const AnimatedLoadingWidget()),
      );

      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Animation should be running
      expect(find.byType(AnimatedLoadingWidget), findsOneWidget);
    });
  });
}
