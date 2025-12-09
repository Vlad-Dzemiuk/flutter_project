import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

/// Покращений interceptor для детального логування HTTP запитів та відповідей
class LoggingInterceptor extends Interceptor {
  final Logger _logger = Logger();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final requestTime = DateTime.now();
    options.extra['requestTime'] = requestTime;

    _logger.d(
      '┌─────────────────────────────────────────────────────────────\n'
      '│ 📤 REQUEST [${options.method}] ${options.uri}\n'
      '├─────────────────────────────────────────────────────────────',
    );

    // Логуємо headers (приховуємо чутливі дані)
    if (options.headers.isNotEmpty) {
      final safeHeaders = Map<String, dynamic>.from(options.headers);
      // Приховуємо чутливі headers
      safeHeaders.forEach((key, value) {
        if (key.toLowerCase().contains('authorization') ||
            key.toLowerCase().contains('api-key') ||
            key.toLowerCase().contains('token')) {
          safeHeaders[key] = '***HIDDEN***';
        }
      });
      _logger.d('│ Headers: $safeHeaders');
    }

    // Логуємо query parameters (приховуємо API key)
    if (options.queryParameters.isNotEmpty) {
      final safeQueryParams = Map<String, dynamic>.from(options.queryParameters);
      if (safeQueryParams.containsKey('api_key')) {
        safeQueryParams['api_key'] = '***HIDDEN***';
      }
      _logger.d('│ Query Parameters: $safeQueryParams');
    }

    // Логуємо body (якщо є)
    if (options.data != null) {
      final dataStr = options.data.toString();
      // Обмежуємо довжину логу
      final truncatedData = dataStr.length > 500
          ? '${dataStr.substring(0, 500)}... (truncated)'
          : dataStr;
      _logger.d('│ Body: $truncatedData');
    }

    _logger.d(
      '└─────────────────────────────────────────────────────────────',
    );

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final requestTime = response.requestOptions.extra['requestTime'] as DateTime?;
    final duration = requestTime != null
        ? DateTime.now().difference(requestTime)
        : null;

    _logger.d(
      '┌─────────────────────────────────────────────────────────────\n'
      '│ 📥 RESPONSE [${response.statusCode}] ${response.requestOptions.uri}\n'
      '├─────────────────────────────────────────────────────────────',
    );

    if (duration != null) {
      _logger.d('│ Duration: ${duration.inMilliseconds}ms');
    }

    // Логуємо response headers
    if (response.headers.map.isNotEmpty) {
      _logger.d('│ Headers: ${response.headers.map}');
    }

    // Логуємо response data (обмежуємо розмір)
    if (response.data != null) {
      final dataStr = response.data.toString();
      final truncatedData = dataStr.length > 1000
          ? '${dataStr.substring(0, 1000)}... (truncated)'
          : dataStr;
      _logger.d('│ Data: $truncatedData');
    }

    _logger.d(
      '└─────────────────────────────────────────────────────────────',
    );

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final requestTime = err.requestOptions.extra['requestTime'] as DateTime?;
    Duration? duration;
    if (requestTime != null) {
      duration = DateTime.now().difference(requestTime);
    }

    _logger.e(
      '┌─────────────────────────────────────────────────────────────\n'
      '│ ❌ ERROR [${err.type}] ${err.requestOptions.method} ${err.requestOptions.uri}\n'
      '├─────────────────────────────────────────────────────────────',
    );

    if (duration != null) {
      _logger.e('│ Duration: ${duration.inMilliseconds}ms');
    }

    _logger.e('│ Error Type: ${err.type}');
    _logger.e('│ Error Message: ${err.message}');

    if (err.response != null) {
      _logger.e('│ Status Code: ${err.response!.statusCode}');
      if (err.response!.data != null) {
        final dataStr = err.response!.data.toString();
        final truncatedData = dataStr.length > 500
            ? '${dataStr.substring(0, 500)}... (truncated)'
            : dataStr;
        _logger.e('│ Response Data: $truncatedData');
      }
    }

    _logger.e('│ Stack Trace: ${err.stackTrace}');

    _logger.e(
      '└─────────────────────────────────────────────────────────────',
    );

    handler.next(err);
  }
}

