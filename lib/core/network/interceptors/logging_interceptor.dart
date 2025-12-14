import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

/// Покращений interceptor для детального логування HTTP запитів та відповідей
class LoggingInterceptor extends Interceptor {
  final Logger _logger = Logger();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final requestTime = DateTime.now();
    options.extra['requestTime'] = requestTime;

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
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

    _logger.e('└─────────────────────────────────────────────────────────────');

    handler.next(err);
  }
}
