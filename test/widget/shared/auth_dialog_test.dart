import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project/shared/widgets/auth_dialog.dart';
import '../../unit/helpers/widget_test_helpers.dart';

void main() {
  group('AuthDialog', () {
    testWidgets('displays auth dialog', (WidgetTester tester) async {
      await tester.pumpWidget(
        WidgetTestHelper.createTestApp(
          child: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () => AuthDialog.show(
                  context,
                  title: 'Test Title',
                  message: 'Test Message',
                ),
                child: const Text('Show Dialog'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Test Title'), findsOneWidget);
      expect(find.text('Test Message'), findsOneWidget);
    });

    testWidgets('displays cancel button', (WidgetTester tester) async {
      await tester.pumpWidget(
        WidgetTestHelper.createTestApp(
          child: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () => AuthDialog.show(
                  context,
                  title: 'Test Title',
                  message: 'Test Message',
                ),
                child: const Text('Show Dialog'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('displays sign in button', (WidgetTester tester) async {
      await tester.pumpWidget(
        WidgetTestHelper.createTestApp(
          child: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () => AuthDialog.show(
                  context,
                  title: 'Test Title',
                  message: 'Test Message',
                ),
                child: const Text('Show Dialog'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('can close dialog with cancel button', (WidgetTester tester) async {
      await tester.pumpWidget(
        WidgetTestHelper.createTestApp(
          child: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () => AuthDialog.show(
                  context,
                  title: 'Test Title',
                  message: 'Test Message',
                ),
                child: const Text('Show Dialog'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Test Title'), findsNothing);
    });
  });
}

