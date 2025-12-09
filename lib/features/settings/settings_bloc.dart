import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'settings_event.dart';
import 'settings_state.dart';
import '../../core/storage/user_prefs.dart';
import '../../core/theme.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(const SettingsState()) {
    on<LoadSettingsEvent>(_onLoadSettings);
    on<SetThemeModeEvent>(_onSetThemeMode);
    on<SetLanguageEvent>(_onSetLanguage);
    // Завантажуємо налаштування при ініціалізації
    add(const LoadSettingsEvent());
  }

  Future<void> _onLoadSettings(
    LoadSettingsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(loading: true, error: ''));
    try {
      final themeModeString = await UserPrefs.instance.getThemeMode();
      final languageCode = await UserPrefs.instance.getLanguageCode();
      
      final themeMode = AppThemes.parseThemeMode(themeModeString);
      
      emit(state.copyWith(
        themeMode: themeMode,
        languageCode: languageCode,
        loading: false,
        error: '',
      ));
    } catch (e) {
      final errorMessage = _getUserFriendlyError(e);
      emit(state.copyWith(loading: false, error: errorMessage));
    }
  }

  Future<void> _onSetThemeMode(
    SetThemeModeEvent event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(error: ''));
    try {
      await UserPrefs.instance.setThemeMode(
        AppThemes.themeModeToString(event.themeMode),
      );
      emit(state.copyWith(themeMode: event.themeMode, error: ''));
    } catch (e) {
      final errorMessage = _getUserFriendlyError(e);
      emit(state.copyWith(error: errorMessage));
    }
  }

  Future<void> _onSetLanguage(
    SetLanguageEvent event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(error: ''));
    try {
      await UserPrefs.instance.setLanguageCode(event.languageCode);
      emit(state.copyWith(languageCode: event.languageCode, error: ''));
    } catch (e) {
      final errorMessage = _getUserFriendlyError(e);
      emit(state.copyWith(error: errorMessage));
    }
  }

  String _getUserFriendlyError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('permission') || errorString.contains('access')) {
      return 'Недостатньо прав доступу до сховища. Перевірте дозволи додатку.';
    }
    
    if (errorString.contains('storage') || errorString.contains('disk')) {
      return 'Помилка збереження налаштувань. Перевірте доступ до сховища.';
    }
    
    // Для інших помилок повертаємо загальне повідомлення
    return 'Не вдалося зберегти налаштування. Спробуйте пізніше.';
  }

  /// Отримує фактичну тему, яка зараз використовується
  /// (враховуючи системну тему, якщо mode == ThemeMode.system)
  Brightness getEffectiveBrightness(BuildContext context) {
    if (state.themeMode == ThemeMode.system) {
      return MediaQuery.platformBrightnessOf(context);
    }
    return state.themeMode == ThemeMode.dark ? Brightness.dark : Brightness.light;
  }
}

