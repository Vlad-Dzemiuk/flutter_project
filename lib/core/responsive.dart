import 'package:flutter/material.dart';

/// Утиліта для адаптивного дизайну
class Responsive {
  /// Breakpoints для різних типів пристроїв
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;
  static const double desktopBreakpoint = 1440;

  /// Визначає тип пристрою на основі ширини екрана
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) {
      return DeviceType.mobile;
    } else if (width < tabletBreakpoint) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }

  /// Визначає чи екран в горизонтальній орієнтації
  static bool isLandscape(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.width > size.height;
  }

  /// Визначає кількість колонок для GridView на основі ширини екрана та орієнтації
  static int getGridColumnCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isLandscapeMode = isLandscape(context);

    if (width < mobileBreakpoint) {
      return isLandscapeMode ? 3 : 2; // Мобільні: 2-3 колонки
    } else if (width < tabletBreakpoint) {
      return isLandscapeMode ? 5 : 3; // Планшети: 3-5 колонок
    } else if (width < desktopBreakpoint) {
      return isLandscapeMode ? 6 : 4; // Десктоп (середній): 4-6 колонок
    } else {
      return isLandscapeMode ? 7 : 5; // Десктоп (великий): 5-7 колонок
    }
  }

  /// Адаптивний padding для горизонтальних відступів
  static EdgeInsets getHorizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isLandscapeMode = isLandscape(context);

    if (width < mobileBreakpoint) {
      return EdgeInsets.symmetric(horizontal: isLandscapeMode ? 20 : 16);
    } else if (width < tabletBreakpoint) {
      return EdgeInsets.symmetric(horizontal: isLandscapeMode ? 32 : 24);
    } else if (width < desktopBreakpoint) {
      return EdgeInsets.symmetric(horizontal: isLandscapeMode ? 40 : 32);
    } else {
      return EdgeInsets.symmetric(horizontal: isLandscapeMode ? 56 : 48);
    }
  }

  /// Адаптивний padding для вертикальних відступів
  static EdgeInsets getVerticalPadding(BuildContext context) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return const EdgeInsets.symmetric(vertical: 12);
      case DeviceType.tablet:
        return const EdgeInsets.symmetric(vertical: 16);
      case DeviceType.desktop:
        return const EdgeInsets.symmetric(vertical: 20);
    }
  }

  /// Адаптивний spacing між елементами
  static double getSpacing(BuildContext context) {
    final deviceType = getDeviceType(context);
    final isLandscapeMode = isLandscape(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return isLandscapeMode ? 14.0 : 12.0;
      case DeviceType.tablet:
        return isLandscapeMode ? 18.0 : 16.0;
      case DeviceType.desktop:
        return isLandscapeMode ? 24.0 : 20.0;
    }
  }

  /// Адаптивна ширина картки медіа
  static double getMediaCardWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final columns = getGridColumnCount(context);
    final horizontalPadding = getHorizontalPadding(context);
    final spacing = getSpacing(context);

    final availableWidth = width -
        horizontalPadding.left -
        horizontalPadding.right -
        (spacing * (columns - 1));

    return availableWidth / columns;
  }

  /// Перевірка чи це мобільний пристрій
  static bool isMobile(BuildContext context) {
    return getDeviceType(context) == DeviceType.mobile;
  }

  /// Перевірка чи це планшет
  static bool isTablet(BuildContext context) {
    return getDeviceType(context) == DeviceType.tablet;
  }

  /// Перевірка чи це десктоп
  static bool isDesktop(BuildContext context) {
    return getDeviceType(context) == DeviceType.desktop;
  }

  /// Максимальна ширина для форм на десктопі/планшеті
  static double getMaxFormWidth(BuildContext context) {
    final deviceType = getDeviceType(context);
    final isLandscapeMode = isLandscape(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return double.infinity;
      case DeviceType.tablet:
        return isLandscapeMode ? 600 : 500;
      case DeviceType.desktop:
        return isLandscapeMode ? 550 : 450;
    }
  }

  /// Адаптивний aspect ratio для карток медіа
  static double getMediaCardAspectRatio(BuildContext context) {
    final deviceType = getDeviceType(context);
    final isLandscapeMode = isLandscape(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return isLandscapeMode ? 0.7 : 0.65;
      case DeviceType.tablet:
        return isLandscapeMode ? 0.75 : 0.7;
      case DeviceType.desktop:
        return isLandscapeMode ? 0.7 : 0.65;
    }
  }
}

/// Типи пристроїв
enum DeviceType { mobile, tablet, desktop }
