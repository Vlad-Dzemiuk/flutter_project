import 'package:flutter_test/flutter_test.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:project/core/network/retry_helper.dart';

void main() {
  group('RetryHelper', () {
    test('should return result on first attempt when operation succeeds', () async {
      // Arrange
      var attemptCount = 0;
      Future<String> operation() async {
        attemptCount++;
        return 'success';
      }

      // Act
      final result = await RetryHelper.retry(operation: operation);

      // Assert
      expect(result, 'success');
      expect(attemptCount, 1);
    });

    test('should retry on SocketException', () async {
      // Arrange
      var attemptCount = 0;
      Future<String> operation() async {
        attemptCount++;
        if (attemptCount < 2) {
          throw SocketException('Connection failed');
        }
        return 'success';
      }

      // Act
      final result = await RetryHelper.retry(
        operation: operation,
        maxRetries: 3,
        initialDelay: const Duration(milliseconds: 10),
      );

      // Assert
      expect(result, 'success');
      expect(attemptCount, 2);
    });

    test('should throw exception after max retries', () async {
      // Arrange
      Future<String> operation() async {
        throw SocketException('Connection failed');
      }

      // Act & Assert
      expect(
        () => RetryHelper.retry(
          operation: operation,
          maxRetries: 2,
          initialDelay: const Duration(milliseconds: 10),
        ),
        throwsA(isA<SocketException>()),
      );
    });

    test('should not retry on non-retryable errors', () async {
      // Arrange
      var attemptCount = 0;
      Future<String> operation() async {
        attemptCount++;
        throw Exception('Non-retryable error');
      }

      // Act & Assert
      expect(
        () => RetryHelper.retry(
          operation: operation,
          maxRetries: 3,
        ),
        throwsA(isA<Exception>()),
      );
      expect(attemptCount, 1);
    });

    test('should retry on DioException connection timeout', () async {
      // Arrange
      var attemptCount = 0;
      Future<String> operation() async {
        attemptCount++;
        if (attemptCount < 2) {
          throw DioException(
            requestOptions: RequestOptions(path: '/'),
            type: DioExceptionType.connectionTimeout,
          );
        }
        return 'success';
      }

      // Act
      final result = await RetryHelper.retry(
        operation: operation,
        maxRetries: 3,
        initialDelay: const Duration(milliseconds: 10),
      );

      // Assert
      expect(result, 'success');
      expect(attemptCount, 2);
    });

    test('should retry on DioException with 500 status code', () async {
      // Arrange
      var attemptCount = 0;
      Future<String> operation() async {
        attemptCount++;
        if (attemptCount < 2) {
          throw DioException(
            requestOptions: RequestOptions(path: '/'),
            type: DioExceptionType.badResponse,
            response: Response(
              requestOptions: RequestOptions(path: '/'),
              statusCode: 500,
            ),
          );
        }
        return 'success';
      }

      // Act
      final result = await RetryHelper.retry(
        operation: operation,
        maxRetries: 3,
        initialDelay: const Duration(milliseconds: 10),
      );

      // Assert
      expect(result, 'success');
      expect(attemptCount, 2);
    });

    test('should not retry on DioException with 400 status code', () async {
      // Arrange
      var attemptCount = 0;
      Future<String> operation() async {
        attemptCount++;
        throw DioException(
          requestOptions: RequestOptions(path: '/'),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(path: '/'),
            statusCode: 400,
          ),
        );
      }

      // Act & Assert
      expect(
        () => RetryHelper.retry(
          operation: operation,
          maxRetries: 3,
        ),
        throwsA(isA<DioException>()),
      );
      expect(attemptCount, 1);
    });
  });
}

