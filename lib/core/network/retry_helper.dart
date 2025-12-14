import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

/// Утиліта для повторних спроб мережевих операцій
///
/// Надає механізм автоматичного повтору операцій при мережевих помилках
/// з експоненційним backoff
class RetryHelper {
  static final Logger _logger = Logger();

  /// Виконує операцію з повторними спробами при мережевих помилках
  ///
  /// [operation] - функція, яку потрібно виконати
  /// [maxRetries] - максимальна кількість спроб (за замовчуванням 3)
  /// [initialDelay] - початкова затримка між спробами (за замовчуванням 1 секунда)
  /// [maxDelay] - максимальна затримка між спробами (за замовчуванням 10 секунд)
  ///
  /// Повертає результат операції або кидає останню помилку
  static Future<T> retry<T>({
    required Future<T> Function() operation,
    int maxRetries = 3,
    Duration initialDelay = const Duration(seconds: 1),
    Duration maxDelay = const Duration(seconds: 10),
  }) async {
    int attempt = 0;
    Exception? lastException;

    while (attempt < maxRetries) {
      try {
        return await operation();
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());

        // Перевіряємо, чи це мережева помилка, яку можна повторити
        if (!_isRetryableError(e)) {
          _logger.w('Non-retryable error: $e');
          rethrow;
        }

        attempt++;

        // Якщо це остання спроба, кидаємо помилку
        if (attempt >= maxRetries) {
          _logger.e('Max retries ($maxRetries) reached. Last error: $e');
          rethrow;
        }

        // Експоненційний backoff: delay = initialDelay * 2^(attempt-1)
        final delay = Duration(
          milliseconds: (initialDelay.inMilliseconds * (1 << (attempt - 1)))
              .clamp(0, maxDelay.inMilliseconds),
        );

        _logger.w(
          'Network error on attempt $attempt/$maxRetries. '
          'Retrying in ${delay.inSeconds}s... Error: $e',
        );

        await Future.delayed(delay);
      }
    }

    // Це не повинно статися, але для безпеки
    throw lastException ?? Exception('Unknown error during retry');
  }

  /// Перевіряє, чи можна повторити операцію при даній помилці
  static bool _isRetryableError(dynamic error) {
    // SocketException - немає інтернет-з'єднання
    if (error is SocketException) {
      return true;
    }

    // DioException - помилки HTTP клієнта
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.connectionError:
        case DioExceptionType.badResponse:
          // Для badResponse перевіряємо статус код
          if (error.response != null) {
            final statusCode = error.response!.statusCode;
            // Повторюємо тільки для серверних помилок (5xx) та деяких клієнтських (408, 429)
            return statusCode != null &&
                (statusCode >= 500 ||
                    statusCode == 408 || // Request Timeout
                    statusCode == 429); // Too Many Requests
          }
          return true;
        case DioExceptionType.unknown:
          // Перевіряємо, чи це мережева помилка
          final errorString = error.toString().toLowerCase();
          return errorString.contains('socketexception') ||
              errorString.contains('failed host lookup') ||
              errorString.contains('network is unreachable') ||
              errorString.contains('connection refused') ||
              errorString.contains('connection reset');
        default:
          return false;
      }
    }

    // Перевіряємо рядкове представлення помилки
    final errorString = error.toString().toLowerCase();
    return errorString.contains('socketexception') ||
        errorString.contains('failed host lookup') ||
        errorString.contains('no address associated with hostname') ||
        errorString.contains('network is unreachable') ||
        errorString.contains('connection refused') ||
        errorString.contains('connection reset') ||
        errorString.contains('connection timed out') ||
        (errorString.contains('timeout') &&
            !errorString.contains('authentication'));
  }
}
