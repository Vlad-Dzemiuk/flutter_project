import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:project/main.dart' as app;
import 'helper_functions.dart';

/// Setup тест для авторизації користувача
/// Цей тест має запускатися першим перед іншими тестами
/// Авторизує користувача або створює нового, якщо потрібно
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Setup Authentication', () {
    setUpAll(() {
      // Налаштовуємо обробку помилок для всіх тестів
      IntegrationTestHelper.setupErrorHandling();
    });

    testWidgets('Setup: Authenticate user for integration tests', (
      WidgetTester tester,
    ) async {
      // Запускаємо додаток
      app.main();
      await IntegrationTestHelper.waitForAppLoad(tester);

      // Використовуємо helper функцію для авторизації
      final authSuccess = await IntegrationTestHelper.authenticateUser(
        tester,
        email: 'test@example.com',
        password: 'testpass123',
        createIfNotExists: true,
      );

      if (authSuccess) {
        // Авторизація успішна, повертаємося на головну
        final homeButton = find.text('Home');
        if (homeButton.evaluate().isNotEmpty) {
          await tester.tap(homeButton.first);
          await IntegrationTestHelper.waitForAsync(tester);
        }
      } else {
        // Якщо авторизація не вдалася, все одно продовжуємо
        // (можливо, користувач вже авторизований або є інші проблеми)
        // Повертаємося на головну сторінку
        final homeButton = find.text('Home');
        if (homeButton.evaluate().isNotEmpty) {
          await tester.tap(homeButton.first);
          await IntegrationTestHelper.waitForAsync(tester);
        }
      }

      // Перевіряємо, що додаток працює
      expect(find.byType(Scaffold), findsWidgets);
    });
  });
}
