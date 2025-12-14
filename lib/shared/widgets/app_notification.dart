import 'package:flutter/material.dart';

/// Типи нотифікацій
enum NotificationType { success, error, info, warning }

/// Універсальний компонент для відображення нотифікацій
/// Використовує дизайн як у нотифікацій для авторизації
class AppNotification {
  AppNotification._();

  /// Показує нотифікацію з заданим типом та повідомленням
  static void show(
    BuildContext context, {
    required String message,
    required NotificationType type,
    Duration? duration,
    IconData? icon,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    // Визначаємо колір та іконку за типом
    Color backgroundColor;
    IconData defaultIcon;
    Duration defaultDuration;

    switch (type) {
      case NotificationType.success:
        backgroundColor = colors.primary;
        defaultIcon = Icons.check_circle;
        defaultDuration = const Duration(seconds: 2);
        break;
      case NotificationType.error:
        backgroundColor = colors.error;
        defaultIcon = Icons.error_outline;
        defaultDuration = const Duration(seconds: 4);
        break;
      case NotificationType.info:
        backgroundColor = colors.primaryContainer;
        defaultIcon = Icons.info_outline;
        defaultDuration = const Duration(seconds: 3);
        break;
      case NotificationType.warning:
        backgroundColor = colors.errorContainer;
        defaultIcon = Icons.warning_amber_rounded;
        defaultDuration = const Duration(seconds: 3);
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon ?? defaultIcon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: duration ?? defaultDuration,
      ),
    );
  }

  /// Показує нотифікацію про успіх
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration? duration,
    IconData? icon,
  }) {
    show(
      context,
      message: message,
      type: NotificationType.success,
      duration: duration,
      icon: icon,
    );
  }

  /// Показує нотифікацію про помилку
  static void showError(
    BuildContext context,
    String message, {
    Duration? duration,
    IconData? icon,
  }) {
    show(
      context,
      message: message,
      type: NotificationType.error,
      duration: duration,
      icon: icon,
    );
  }

  /// Показує інформаційну нотифікацію
  static void showInfo(
    BuildContext context,
    String message, {
    Duration? duration,
    IconData? icon,
  }) {
    show(
      context,
      message: message,
      type: NotificationType.info,
      duration: duration,
      icon: icon,
    );
  }

  /// Показує попереджувальну нотифікацію
  static void showWarning(
    BuildContext context,
    String message, {
    Duration? duration,
    IconData? icon,
  }) {
    show(
      context,
      message: message,
      type: NotificationType.warning,
      duration: duration,
      icon: icon,
    );
  }
}
