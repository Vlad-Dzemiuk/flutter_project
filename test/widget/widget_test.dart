import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:project/core/theme.dart';

void main() {
  testWidgets('ThemeControllerScope provides controller', (
    WidgetTester tester,
  ) async {
    final controller = ThemeController(ThemeMode.light);

    await tester.pumpWidget(
      ThemeControllerScope(
        controller: controller,
        child: MaterialApp(
          themeMode: controller.mode,
          home: const Scaffold(body: Text('Hello')),
        ),
      ),
    );

    final textElement = tester.element(find.text('Hello'));
    expect(find.text('Hello'), findsOneWidget);
    expect(ThemeControllerScope.of(textElement), same(controller));
  });
}
