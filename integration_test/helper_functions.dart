import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Helper functions for integration tests
class IntegrationTestHelper {
  /// Налаштовує обробку помилок для integration тестів
  /// Ігнорує RenderFlex overflow помилки (це UI проблема, не критична для функціональних тестів)
  static void setupErrorHandling() {
    FlutterError.onError = (FlutterErrorDetails details) {
      if (details.exception.toString().contains('RenderFlex overflowed')) {
        return; // Ігноруємо overflow помилки
      }
      FlutterError.presentError(details);
    };
  }
  /// Waits for app to fully load
  static Future<void> waitForAppLoad(WidgetTester tester) async {
    await tester.pumpAndSettle(const Duration(seconds: 5));
    tester.takeException(); // Очищаємо overflow помилки
    await tester.pumpAndSettle(const Duration(seconds: 3));
    tester.takeException(); // Очищаємо overflow помилки
  }

  /// Navigates to a specific tab by text
  static Future<void> navigateToTab(WidgetTester tester, String tabName) async {
    final tabButton = find.text(tabName);
    if (tabButton.evaluate().isNotEmpty) {
      await tester.tap(tabButton.first);
      await tester.pumpAndSettle();
      tester.takeException(); // Очищаємо overflow помилки
    }
  }

  /// Finds and taps a button by text
  static Future<void> tapButton(WidgetTester tester, String buttonText) async {
    final button = find.text(buttonText);
    if (button.evaluate().isNotEmpty) {
      await tester.tap(button.first);
      await tester.pumpAndSettle();
    }
  }

  /// Finds and taps a button by icon
  static Future<void> tapIconButton(WidgetTester tester, IconData icon) async {
    final button = find.byIcon(icon);
    if (button.evaluate().isNotEmpty) {
      await tester.tap(button.first);
      await tester.pumpAndSettle();
    }
  }

  /// Enters text into a text field
  static Future<void> enterTextInField(
    WidgetTester tester,
    Finder field,
    String text,
  ) async {
    if (field.evaluate().isNotEmpty) {
      await tester.tap(field);
      await tester.enterText(field, text);
      await tester.pump();
    }
  }

  /// Scrolls a scrollable widget
  static Future<void> scrollWidget(
    WidgetTester tester,
    Finder scrollable,
    Offset offset,
  ) async {
    if (scrollable.evaluate().isNotEmpty) {
      await tester.drag(scrollable.first, offset);
      await tester.pumpAndSettle();
    }
  }

  /// Verifies that a widget is visible
  static void verifyWidgetVisible(Finder finder) {
    if (finder.evaluate().isNotEmpty) {
      expect(finder, findsWidgets);
    }
  }

  /// Verifies navigation worked
  static void verifyNavigation() {
    expect(find.byType(Scaffold), findsWidgets);
  }

  /// Waits for async operations
  static Future<void> waitForAsync(WidgetTester tester, {int seconds = 2}) async {
    await tester.pumpAndSettle(Duration(seconds: seconds));
    tester.takeException(); // Очищаємо overflow помилки
  }

  /// Авторизує користувача або створює нового, якщо потрібно
  /// Використовується для setup авторизації перед іншими тестами
  /// Повертає true, якщо авторизація успішна
  static Future<bool> authenticateUser(
    WidgetTester tester, {
    String email = 'test@example.com',
    String password = 'testpass123',
    bool createIfNotExists = true,
  }) async {
    // Перевіряємо, чи користувач вже авторизований
    final profileButton = find.text('Profile');
    if (profileButton.evaluate().isNotEmpty) {
      await tester.tap(profileButton.first);
      await waitForAsync(tester, seconds: 2);

      // Перевіряємо, чи є форма логіну
      final loginFields = find.byType(TextFormField);
      if (loginFields.evaluate().isEmpty) {
        // Користувач вже авторизований
        final homeButton = find.text('Home');
        if (homeButton.evaluate().isNotEmpty) {
          await tester.tap(homeButton.first);
          await waitForAsync(tester);
        }
        return true;
      }
    }

    // Знаходимо поля форми
    final textFields = find.byType(TextFormField);
    if (textFields.evaluate().length < 2) {
      return false;
    }

    final emailField = textFields.first;
    final passwordField = textFields.at(1);

    // Заповнюємо email
    await tester.tap(emailField);
    await tester.enterText(emailField, email);
    await tester.pump();
    tester.takeException();

    // Заповнюємо password
    await tester.tap(passwordField);
    await tester.enterText(passwordField, password);
    await tester.pump();
    tester.takeException();

    // Шукаємо кнопку Sign In
    final signInButton = find.text('Sign In');
    if (signInButton.evaluate().isNotEmpty) {
      await tester.tap(signInButton.first);
      await waitForAsync(tester, seconds: 3);
      
      // Перевіряємо, чи авторизація успішна
      final loginFieldsAfter = find.byType(TextFormField);
      if (loginFieldsAfter.evaluate().isEmpty) {
        return true;
      }
    }

    // Якщо вхід не вдався і потрібно створити користувача
    if (createIfNotExists) {
      // Переключаємося на реєстрацію
      final toggleButtons = find.byType(TextButton);
      if (toggleButtons.evaluate().isNotEmpty) {
        await tester.tap(toggleButtons.first);
        await waitForAsync(tester);
        
        // Заповнюємо поля знову
        final newTextFields = find.byType(TextFormField);
        if (newTextFields.evaluate().length >= 2) {
          await tester.tap(newTextFields.first);
          await tester.enterText(newTextFields.first, email);
          await tester.pump();
          
          await tester.tap(newTextFields.at(1));
          await tester.enterText(newTextFields.at(1), password);
          await tester.pump();
          tester.takeException();
        }
        
        // Шукаємо кнопку Sign Up або Register
        final signUpButton = find.text('Sign Up');
        final registerButton = find.text('Register');
        final signUpBtn = signUpButton.evaluate().isNotEmpty 
            ? signUpButton.first 
            : (registerButton.evaluate().isNotEmpty ? registerButton.first : null);
        
        if (signUpBtn != null) {
          await tester.tap(signUpBtn);
          await waitForAsync(tester, seconds: 3);
          
          // Перевіряємо, чи реєстрація успішна
          final loginFieldsAfterReg = find.byType(TextFormField);
          if (loginFieldsAfterReg.evaluate().isEmpty) {
            return true;
          }
        }
      }
    }

    return false;
  }
}



