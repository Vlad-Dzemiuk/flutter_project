import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'interceptors/auth_header_interceptor.dart';
import 'interceptors/api_key_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import '../../features/auth/auth_repository.dart';

/// Централізований Dio HTTP client з interceptors
class DioClient {
  static DioClient? _instance;
  late Dio _dio;
  final Logger _logger = Logger();
  final AuthRepository? _authRepository;

  DioClient._internal({AuthRepository? authRepository})
    : _authRepository = authRepository {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.themoviedb.org/3',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _setupInterceptors();
  }

  factory DioClient({AuthRepository? authRepository}) {
    _instance ??= DioClient._internal(authRepository: authRepository);
    return _instance!;
  }

  Dio get dio => _dio;

  void _setupInterceptors() {
    // 1. Logging Interceptor - детальне логування запитів/відповідей
    _dio.interceptors.add(LoggingInterceptor());

    // 2. API Key Interceptor - автоматичне додавання API key
    _dio.interceptors.add(ApiKeyInterceptor());

    // 3. Auth Header Interceptor - автоматичне додавання авторизаційних headers
    _dio.interceptors.add(
      AuthHeaderInterceptor(authRepository: _authRepository),
    );

    // 4. Retry Interceptor - повторює запити при мережевих помилках
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) async {
          // Перевіряємо, чи це мережева помилка, яку можна повторити
          final isRetryable = _isRetryableDioError(error);

          if (isRetryable) {
            final options = error.requestOptions;
            final retryCount = options.extra['retryCount'] ?? 0;
            const maxRetries = 3;

            if (retryCount < maxRetries) {
              options.extra['retryCount'] = retryCount + 1;

              // Експоненційний backoff: delay = 1s, 2s, 4s
              final delay = Duration(seconds: 1 << retryCount);

              _logger.w(
                'Retrying request (attempt ${retryCount + 1}/$maxRetries) '
                'after ${delay.inSeconds}s. Error: ${error.message}',
              );

              await Future.delayed(delay);

              try {
                final response = await _dio.fetch(options);
                return handler.resolve(response);
              } catch (e) {
                // Якщо повторна спроба також не вдалася, продовжуємо ланцюжок помилок
                if (retryCount + 1 >= maxRetries) {
                  return handler.next(error);
                }
                // Рекурсивно викликаємо обробник помилок для наступної спроби
                return handler.next(error);
              }
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  /// Перевіряє, чи можна повторити запит при даній DioException
  bool _isRetryableDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return true;
      case DioExceptionType.badResponse:
        // Повторюємо тільки для серверних помилок (5xx) та деяких клієнтських (408, 429)
        if (error.response != null) {
          final statusCode = error.response!.statusCode;
          return statusCode != null &&
              (statusCode >= 500 ||
                  statusCode == 408 || // Request Timeout
                  statusCode == 429); // Too Many Requests
        }
        return false;
      case DioExceptionType.unknown:
        // Перевіряємо, чи це мережева помилка
        final errorString = error.toString().toLowerCase();
        return errorString.contains('socketexception') ||
            errorString.contains('failed host lookup') ||
            errorString.contains('network is unreachable') ||
            errorString.contains('connection refused') ||
            errorString.contains('connection reset') ||
            errorString.contains('connection timed out');
      default:
        return false;
    }
  }
}
