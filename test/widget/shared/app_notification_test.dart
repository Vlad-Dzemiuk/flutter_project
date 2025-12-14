import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project/shared/widgets/app_notification.dart';
import '../../unit/helpers/widget_test_helpers.dart';

void main() {
  group('AppNotification', () {
    testWidgets('shows success notification', (WidgetTester tester) async {
      await tester.pumpWidget(
        WidgetTestHelper.createTestApp(
          child: Builder(
            builder: (context) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () => AppNotification.showSuccess(
                    context,
                    'Success message',
                  ),
                  child: const Text('Show Success'),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show Success'));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Success message'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('shows error notification', (WidgetTester tester) async {
      await tester.pumpWidget(
        WidgetTestHelper.createTestApp(
          child: Builder(
            builder: (context) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () => AppNotification.showError(
                    context,
                    'Error message',
                  ),
                  child: const Text('Show Error'),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show Error'));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Error message'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('shows info notification', (WidgetTester tester) async {
      await tester.pumpWidget(
        WidgetTestHelper.createTestApp(
          child: Builder(
            builder: (context) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () => AppNotification.showInfo(
                    context,
                    'Info message',
                  ),
                  child: const Text('Show Info'),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show Info'));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Info message'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('shows warning notification', (WidgetTester tester) async {
      await tester.pumpWidget(
        WidgetTestHelper.createTestApp(
          child: Builder(
            builder: (context) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () => AppNotification.showWarning(
                    context,
                    'Warning message',
                  ),
                  child: const Text('Show Warning'),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show Warning'));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Warning message'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });

    testWidgets('shows notification with custom icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        WidgetTestHelper.createTestApp(
          child: Builder(
            builder: (context) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () => AppNotification.showSuccess(
                    context,
                    'Custom icon message',
                    icon: Icons.star,
                  ),
                  child: const Text('Show Custom Icon'),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show Custom Icon'));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Custom icon message'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('shows notification with custom duration', (WidgetTester tester) async {
      await tester.pumpWidget(
        WidgetTestHelper.createTestApp(
          child: Builder(
            builder: (context) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () => AppNotification.showSuccess(
                    context,
                    'Custom duration message',
                    duration: const Duration(seconds: 5),
                  ),
                  child: const Text('Show Custom Duration'),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show Custom Duration'));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Custom duration message'), findsOneWidget);
      
      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBar.duration, const Duration(seconds: 5));
    });

    testWidgets('shows notification with NotificationType.success', (WidgetTester tester) async {
      await tester.pumpWidget(
        WidgetTestHelper.createTestApp(
          child: Builder(
            builder: (context) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () => AppNotification.show(
                    context,
                    message: 'Type success message',
                    type: NotificationType.success,
                  ),
                  child: const Text('Show Type Success'),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show Type Success'));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Type success message'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('shows notification with NotificationType.error', (WidgetTester tester) async {
      await tester.pumpWidget(
        WidgetTestHelper.createTestApp(
          child: Builder(
            builder: (context) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () => AppNotification.show(
                    context,
                    message: 'Type error message',
                    type: NotificationType.error,
                  ),
                  child: const Text('Show Type Error'),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show Type Error'));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Type error message'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('shows notification with NotificationType.info', (WidgetTester tester) async {
      await tester.pumpWidget(
        WidgetTestHelper.createTestApp(
          child: Builder(
            builder: (context) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () => AppNotification.show(
                    context,
                    message: 'Type info message',
                    type: NotificationType.info,
                  ),
                  child: const Text('Show Type Info'),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show Type Info'));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Type info message'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('shows notification with NotificationType.warning', (WidgetTester tester) async {
      await tester.pumpWidget(
        WidgetTestHelper.createTestApp(
          child: Builder(
            builder: (context) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () => AppNotification.show(
                    context,
                    message: 'Type warning message',
                    type: NotificationType.warning,
                  ),
                  child: const Text('Show Type Warning'),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show Type Warning'));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Type warning message'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });

    testWidgets('notification has floating behavior', (WidgetTester tester) async {
      await tester.pumpWidget(
        WidgetTestHelper.createTestApp(
          child: Builder(
            builder: (context) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () => AppNotification.showSuccess(
                    context,
                    'Floating message',
                  ),
                  child: const Text('Show Floating'),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show Floating'));
      await tester.pump();

      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBar.behavior, SnackBarBehavior.floating);
    });

    testWidgets('notification has rounded corners', (WidgetTester tester) async {
      await tester.pumpWidget(
        WidgetTestHelper.createTestApp(
          child: Builder(
            builder: (context) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () => AppNotification.showSuccess(
                    context,
                    'Rounded message',
                  ),
                  child: const Text('Show Rounded'),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show Rounded'));
      await tester.pump();

      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBar.shape, isA<RoundedRectangleBorder>());
      
      final shape = snackBar.shape as RoundedRectangleBorder;
      expect(shape.borderRadius, BorderRadius.circular(12));
    });
  });
}

