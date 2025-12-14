import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

/// Збереження user preferences (тема, мова, тощо) через Hive.
class UserPrefs {
  UserPrefs._internal();
  static final UserPrefs instance = UserPrefs._internal();

  static const String _prefsBoxName = 'user_preferences';
  static const String _searchHistoryBoxName = 'search_history';

  static const String _themeModeKey = 'theme_mode';
  static const String _languageCodeKey = 'language_code';

  Box? _prefsBox;
  Box? _searchHistoryBox;

  /// Ініціалізація Hive boxes для user preferences
  Future<void> init() async {
    if (_prefsBox != null && _searchHistoryBox != null) return;

    _prefsBox = await Hive.openBox(_prefsBoxName);
    _searchHistoryBox = await Hive.openBox(_searchHistoryBoxName);
  }

  Box get prefsBox {
    if (_prefsBox == null) {
      throw Exception('UserPrefs not initialized. Call init() first.');
    }
    return _prefsBox!;
  }

  Box get searchHistoryBox {
    if (_searchHistoryBox == null) {
      throw Exception('UserPrefs not initialized. Call init() first.');
    }
    return _searchHistoryBox!;
  }

  // === Тема застосунку ===

  Future<void> setThemeMode(String mode) async {
    // 'light', 'dark', 'system'
    await prefsBox.put(_themeModeKey, mode);
  }

  Future<String> getThemeMode() async {
    return prefsBox.get(_themeModeKey, defaultValue: 'system') as String;
  }

  // === Мова інтерфейсу ===

  Future<void> setLanguageCode(String code) async {
    await prefsBox.put(_languageCodeKey, code);
  }

  Future<String> getLanguageCode() async {
    return prefsBox.get(_languageCodeKey, defaultValue: 'en') as String;
  }

  // === Історія переглянутих фільмів/серіалів з пошуку ===

  Future<void> addToSearchHistory(Map<String, dynamic> mediaItem) async {
    final mediaId = mediaItem['id'] as int;
    final isMovie = (mediaItem['isMovie'] as bool?) ?? false;

    // Створюємо ключ для унікальності (media_id + isMovie)
    final key = '${mediaId}_${isMovie ? 1 : 0}';

    // Зберігаємо дані з timestamp
    final entry = {
      'data': mediaItem,
      'added_at': DateTime.now().millisecondsSinceEpoch,
    };

    await searchHistoryBox.put(key, jsonEncode(entry));

    // Обмежуємо до 50 елементів - видаляємо найстаріші
    final allKeys = searchHistoryBox.keys.toList();
    if (allKeys.length > 50) {
      // Сортуємо ключі за timestamp (найстаріші спочатку)
      final entriesWithTimestamps = <MapEntry<String, int>>[];
      for (final key in allKeys) {
        final entryJson = searchHistoryBox.get(key) as String?;
        if (entryJson != null) {
          try {
            final entry = jsonDecode(entryJson) as Map<String, dynamic>;
            final timestamp = entry['added_at'] as int;
            entriesWithTimestamps.add(MapEntry(key.toString(), timestamp));
          } catch (e) {
            // Якщо не вдалося розпарсити, видаляємо
            await searchHistoryBox.delete(key);
          }
        }
      }

      entriesWithTimestamps.sort((a, b) => a.value.compareTo(b.value));

      // Видаляємо найстаріші записи
      final toDelete = entriesWithTimestamps.length - 50;
      for (var i = 0; i < toDelete; i++) {
        await searchHistoryBox.delete(entriesWithTimestamps[i].key);
      }
    }
  }

  Future<List<Map<String, dynamic>>> getSearchHistory() async {
    final allKeys = searchHistoryBox.keys.toList();
    final entriesWithTimestamps = <MapEntry<Map<String, dynamic>, int>>[];

    for (final key in allKeys) {
      final entryJson = searchHistoryBox.get(key) as String?;
      if (entryJson != null) {
        try {
          final entry = jsonDecode(entryJson) as Map<String, dynamic>;
          final data = entry['data'] as Map<String, dynamic>;
          final timestamp = entry['added_at'] as int;
          entriesWithTimestamps.add(MapEntry(data, timestamp));
        } catch (e) {
          // Пропускаємо пошкоджені записи
          continue;
        }
      }
    }

    // Сортуємо за timestamp (найновіші спочатку) та обмежуємо до 50
    entriesWithTimestamps.sort((a, b) => b.value.compareTo(a.value));

    return entriesWithTimestamps.take(50).map((entry) => entry.key).toList();
  }

  Future<void> clearSearchHistory() async {
    await searchHistoryBox.clear();
  }
}
