import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../../storage/secure_storage_service.dart';

/// Interceptor для автоматичного додавання API key до кожного запиту
class ApiKeyInterceptor extends Interceptor {
  final Logger _logger = Logger();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      // Отримуємо API key з secure storage
      final apiKey = await SecureStorageService.instance.getTmdbApiKey();
      
      // Додаємо API key як query параметр (TMDB API вимагає це)
      options.queryParameters['api_key'] = apiKey;
      
      // Додаємо мову за замовчуванням
      if (!options.queryParameters.containsKey('language')) {
        options.queryParameters['language'] = 'en-US';
      }
      
      // Також можна додати API key в headers для додаткової безпеки
      // options.headers['X-API-Key'] = apiKey;
      
    } catch (e) {
      _logger.e('Failed to get API key: $e');
      return handler.reject(
        DioException(
          requestOptions: options,
          error: 'API key not configured',
          type: DioExceptionType.unknown,
        ),
      );
    }
    
    handler.next(options);
  }
}

