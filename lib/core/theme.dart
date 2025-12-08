import 'package:flutter/material.dart';
import 'storage/user_prefs.dart';

class AppThemes {
  static ThemeMode parseThemeMode(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  static String themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
      default:
        return 'system';
    }
  }

  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: const Color(0xFF4B5AF6),
        secondary: const Color(0xFF8B7BFF),
        surface: const Color(0xFFF7F7FB),
        surfaceVariant: const Color(0xFFE6E7EE),
        background: const Color(0xFFF7F7FB),
        onBackground: const Color(0xFF0F172A),
        onSurface: const Color(0xFF0F172A),
      ),
      scaffoldBackgroundColor: const Color(0xFFF7F7FB),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Color(0xFF0F172A),
      ),
      textTheme: base.textTheme.apply(
        bodyColor: const Color(0xFF0F172A),
        displayColor: const Color(0xFF0F172A),
      ),
      cardColor: Colors.white,
      brightness: Brightness.light,
    );
  }

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: const Color(0xFF9FB4FF),
        secondary: const Color(0xFF6C63FF),
        surface: const Color(0xFF101726),
        surfaceVariant: const Color(0xFF111827),
        background: const Color(0xFF0B1020),
        onBackground: Colors.white,
        onSurface: Colors.white,
      ),
      scaffoldBackgroundColor: const Color(0xFF0B1020),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      cardColor: const Color(0xFF0F172A),
      brightness: Brightness.dark,
    );
  }
}

class ThemeController extends ChangeNotifier {
  ThemeMode _mode;
  ThemeMode get mode => _mode;

  ThemeController(this._mode);

  Future<void> setMode(ThemeMode newMode) async {
    _mode = newMode;
    notifyListeners();
    await UserPrefs.instance.setThemeMode(AppThemes.themeModeToString(newMode));
  }

  /// Отримує фактичну тему, яка зараз використовується
  /// (враховуючи системну тему, якщо mode == ThemeMode.system)
  Brightness getEffectiveBrightness(BuildContext context) {
    if (_mode == ThemeMode.system) {
      return MediaQuery.platformBrightnessOf(context);
    }
    return _mode == ThemeMode.dark ? Brightness.dark : Brightness.light;
  }
}

class AppGradients {
  static BoxDecoration background(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      return const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F172A),
            Color(0xFF0B1020),
            Color(0xFF0A0E1A),
          ],
        ),
      );
    }
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFF7F8FC),
          Color(0xFFEAEFF9),
          Color(0xFFF4F6FB),
        ],
      ),
    );
  }
}

class ThemeControllerScope extends InheritedWidget {
  final ThemeController controller;

  const ThemeControllerScope({
    super.key,
    required this.controller,
    required super.child,
  });

  static ThemeController of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<ThemeControllerScope>();
    assert(scope != null, 'ThemeControllerScope not found in context');
    return scope!.controller;
  }

  @override
  bool updateShouldNotify(covariant ThemeControllerScope oldWidget) {
    return oldWidget.controller != controller;
  }
}

