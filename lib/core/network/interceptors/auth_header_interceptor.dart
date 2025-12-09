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
          // TMDB API використовує session_id для авторизованих запитів
          // Якщо в майбутньому буде потрібно додати токен, це можна зробити тут
          // options.headers['Authorization'] = 'Bearer $token';
          
          // Для TMDB можна додати session_id якщо він є
          // final sessionId = await SecureStorageService.instance.getSessionId();
          // if (sessionId != null) {
          //   options.queryParameters['session_id'] = sessionId;
          // }
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

