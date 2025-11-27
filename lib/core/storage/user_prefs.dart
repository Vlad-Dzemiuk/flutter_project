import 'package:hive_flutter/hive_flutter.dart';

/// Збереження user preferences (тема, мова, тощо) через Hive.
class UserPrefs {
  static const _boxName = 'user_prefs';

  UserPrefs._internal();
  static final UserPrefs instance = UserPrefs._internal();

  Box? _box;

  Future<Box> _getBox() async {
    if (_box != null && _box!.isOpen) return _box!;
    _box = await Hive.openBox(_boxName);
    return _box!;
  }

  // === Тема застосунку ===

  Future<void> setThemeMode(String mode) async {
    // 'light', 'dark', 'system'
    final box = await _getBox();
    await box.put('theme_mode', mode);
  }

  Future<String> getThemeMode() async {
    final box = await _getBox();
    return (box.get('theme_mode') as String?) ?? 'system';
  }

  // === Мова інтерфейсу ===

  Future<void> setLanguageCode(String code) async {
    final box = await _getBox();
    await box.put('language_code', code);
  }

  Future<String> getLanguageCode() async {
    final box = await _getBox();
    return (box.get('language_code') as String?) ?? 'en';
  }

  // === Історія переглянутих фільмів/серіалів з пошуку ===

  Future<void> addToSearchHistory(Map<String, dynamic> mediaItem) async {
    final box = await _getBox();
    final rawHistory = box.get('search_history', defaultValue: <dynamic>[]);
    final history = (rawHistory as List<dynamic>)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();

    // Видаляємо якщо вже є (за id та isMovie)
    history.removeWhere(
      (item) =>
          item['id'] == mediaItem['id'] &&
          item['isMovie'] == mediaItem['isMovie'],
    );

    // Додаємо на початок
    history.insert(0, mediaItem);

    // Обмежуємо до 50 елементів
    if (history.length > 50) history.removeLast();

    await box.put('search_history', history);
  }

  Future<List<Map<String, dynamic>>> getSearchHistory() async {
    final box = await _getBox();
    final rawHistory = box.get('search_history', defaultValue: <dynamic>[]);
    return (rawHistory as List<dynamic>)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  Future<void> clearSearchHistory() async {
    final box = await _getBox();
    await box.put('search_history', <Map<String, dynamic>>[]);
  }
}
