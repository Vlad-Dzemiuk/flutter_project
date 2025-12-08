import 'package:flutter/foundation.dart';

/// Глобальний сервіс для відстеження стану завантаження головної сторінки
class LoadingStateService extends ChangeNotifier {
  static final LoadingStateService _instance = LoadingStateService._internal();
  factory LoadingStateService() => _instance;
  LoadingStateService._internal();

  bool _isHomePageLoaded = false;

  /// Чи завантажена головна сторінка
  bool get isHomePageLoaded => _isHomePageLoaded;

  /// Встановити, що головна сторінка завантажена
  void setHomePageLoaded() {
    if (!_isHomePageLoaded) {
      _isHomePageLoaded = true;
      notifyListeners();
    }
  }

  /// Скинути стан завантаження (для тестування або перезавантаження)
  void reset() {
    _isHomePageLoaded = false;
    notifyListeners();
  }
}

