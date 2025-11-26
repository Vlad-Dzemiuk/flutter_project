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

  // Тут можна додати останні фільтри пошуку, останню вкладку тощо
}


