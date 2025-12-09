import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../../../features/auth/auth_repository.dart';

/// Interceptor для автоматичного додавання авторизаційних headers
class AuthHeaderInterceptor extends Interceptor {
  final Logger _logger = Logger();
  final AuthRepository? _authRepository;

  AuthHeaderInterceptor({AuthRepository? authRepository})
      : _authRepository = authRepository;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      // Додаємо авторизаційний токен, якщо користувач авторизований
      if (_authRepository != null) {
        final currentUser = _authRepository.currentUser;
        if (currentUser != null) {
          // Отримуємо токен (JWT або Firebase ID token)
          final token = await _authRepository.getJwtToken();
          if (token != null) {
            // Додаємо токен в Authorization header
            options.headers['Authorization'] = 'Bearer $token';
          }
        }
      }
    } catch (e) {
      _logger.w('Failed to add auth headers: $e');
    }
    
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Логуємо помилки авторизації
    if (err.response?.statusCode == 401) {
      _logger.w('Unauthorized request: ${err.requestOptions.path}');
    }
    handler.next(err);
  }
}

