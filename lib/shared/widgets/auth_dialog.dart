import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../core/responsive.dart';
import '../../core/theme.dart';

/// Стилізований діалог для неавторизованих користувачів
class AuthDialog extends StatelessWidget {
  final String title;
  final String message;
  final IconData? icon;

  const AuthDialog({
    super.key,
    required this.title,
    required this.message,
    this.icon,
  });

  static Future<void> show(
    BuildContext context, {
    String? title,
    String? message,
    IconData? icon,
  }) async {
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (ctx) => AuthDialog(
        title: title ?? 'Потрібна авторизація',
        message: message ?? 'Увійдіть, щоб додати до вподобань.',
        icon: icon,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final isDesktop = Responsive.isDesktop(context);
    final isTablet = Responsive.isTablet(context);
    final spacing = Responsive.getSpacing(context);
    final horizontalPadding = Responsive.getHorizontalPadding(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isDesktop ? 500 : (isTablet ? 400 : double.infinity),
        ),
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0F172A),
                    Color(0xFF0B1020),
                  ],
                )
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colors.surfaceContainerHighest,
                    colors.surface,
                  ],
                ),
          borderRadius: BorderRadius.circular(isDesktop ? 24 : 20),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.2),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(isDesktop ? 28 : isTablet ? 24 : 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Іконка
              Container(
                padding: EdgeInsets.all(isDesktop ? 18 : 16),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon ?? Icons.favorite_border,
                  color: colors.primary,
                  size: isDesktop ? 36 : 32,
                ),
              ),
              SizedBox(height: spacing * 1.5),
              // Заголовок
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: isDesktop ? 24 : 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: spacing / 2),
              // Повідомлення
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.onSurfaceVariant,
                  fontSize: isDesktop ? 16 : 14,
                  height: 1.5,
                ),
              ),
              SizedBox(height: spacing * 1.5),
              // Кнопки
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: colors.onSurfaceVariant,
                      padding: EdgeInsets.symmetric(
                        horizontal: spacing,
                        vertical: spacing / 2,
                      ),
                    ),
                    child: const Text('Скасувати'),
                  ),
                  SizedBox(width: spacing / 2),
                  FilledButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pushNamed(AppConstants.loginRoute);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: colors.onPrimary,
                      padding: EdgeInsets.symmetric(
                        horizontal: spacing * 1.5,
                        vertical: spacing / 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Увійти'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

