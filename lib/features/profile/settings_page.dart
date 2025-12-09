import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../core/responsive.dart';
import '../../core/theme.dart';
import '../../shared/widgets/loading_wrapper.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _selectedLanguage = 'Українська';

  ThemeMode _selectedTheme = ThemeMode.system;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = ThemeControllerScope.of(context);
    _selectedTheme = controller.mode;
  }

  Future<void> _chooseLanguage() async {
    final lang = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final colors = theme.colorScheme;
        final isDesktop = Responsive.isDesktop(ctx);
        final isTablet = Responsive.isTablet(ctx);
        final horizontalPadding = Responsive.getHorizontalPadding(ctx);
        final spacing = Responsive.getSpacing(ctx);
        final isDark = theme.brightness == Brightness.dark;

        return Container(
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
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                left: horizontalPadding.left,
                right: horizontalPadding.right,
                top: spacing * 1.5,
                bottom: spacing * 1.5 + MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: EdgeInsets.only(bottom: spacing),
                      decoration: BoxDecoration(
                        color: colors.onSurfaceVariant.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // Header
                  Row(
                    children: [
                      Icon(
                        Icons.language,
                        color: colors.primary,
                        size: isDesktop ? 28 : isTablet ? 26 : 24,
                      ),
                      SizedBox(width: spacing * 0.6),
                      Text(
                        'Оберіть мову',
                        style: TextStyle(
                          color: colors.onBackground,
                          fontSize: isDesktop ? 24 : isTablet ? 22 : 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: spacing * 1.5),
                  // Language options
                  _LanguageOption(
                    title: 'Українська',
                    icon: Icons.flag,
                    onTap: () => Navigator.of(ctx).pop('Українська'),
                    isSelected: _selectedLanguage == 'Українська',
                  ),
                  SizedBox(height: spacing),
                  _LanguageOption(
                    title: 'English',
                    icon: Icons.flag_outlined,
                    onTap: () => Navigator.of(ctx).pop('English'),
                    isSelected: _selectedLanguage == 'English',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    if (lang != null) {
      setState(() => _selectedLanguage = lang);
    }
  }

  Future<void> _chooseTheme() async {
    final controller = ThemeControllerScope.of(context);
    final theme = await showModalBottomSheet<ThemeMode>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final colors = theme.colorScheme;
        final isDesktop = Responsive.isDesktop(ctx);
        final isTablet = Responsive.isTablet(ctx);
        final horizontalPadding = Responsive.getHorizontalPadding(ctx);
        final spacing = Responsive.getSpacing(ctx);
        final isDark = theme.brightness == Brightness.dark;

        return Container(
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
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                left: horizontalPadding.left,
                right: horizontalPadding.right,
                top: spacing * 1.5,
                bottom: spacing * 1.5 + MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: EdgeInsets.only(bottom: spacing),
                      decoration: BoxDecoration(
                        color: colors.onSurfaceVariant.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // Header
                  Row(
                    children: [
                      Icon(
                        Icons.dark_mode_outlined,
                        color: colors.primary,
                        size: isDesktop ? 28 : isTablet ? 26 : 24,
                      ),
                      SizedBox(width: spacing * 0.6),
                      Text(
                        'Тема застосунку',
                        style: TextStyle(
                          color: colors.onBackground,
                          fontSize: isDesktop ? 24 : isTablet ? 22 : 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: spacing * 1.5),
                  // Theme options
                  _ThemeOption(
                    title: 'Системна',
                    icon: Icons.brightness_auto,
                    value: ThemeMode.system,
                    groupValue: _selectedTheme,
                    onChanged: (value) => Navigator.of(ctx).pop(value),
                  ),
                  SizedBox(height: spacing),
                  _ThemeOption(
                    title: 'Світла',
                    icon: Icons.light_mode,
                    value: ThemeMode.light,
                    groupValue: _selectedTheme,
                    onChanged: (value) => Navigator.of(ctx).pop(value),
                  ),
                  SizedBox(height: spacing),
                  _ThemeOption(
                    title: 'Темна',
                    icon: Icons.dark_mode,
                    value: ThemeMode.dark,
                    groupValue: _selectedTheme,
                    onChanged: (value) => Navigator.of(ctx).pop(value),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    if (theme != null) {
      await controller.setMode(theme);
      setState(() => _selectedTheme = theme);
    }
  }

  String get _themeLabel {
    switch (_selectedTheme) {
      case ThemeMode.light:
        return 'Світла';
      case ThemeMode.dark:
        return 'Темна';
      case ThemeMode.system:
      default:
        return 'Системна';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return LoadingWrapper(
      child: Scaffold(
      backgroundColor: colors.background,
      body: Container(
        decoration: AppGradients.background(context),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = Responsive.isDesktop(context);
              final isTablet = Responsive.isTablet(context);
              final horizontalPadding = Responsive.getHorizontalPadding(context);
              final verticalPadding = Responsive.getVerticalPadding(context);
              final spacing = Responsive.getSpacing(context);
              final maxFormWidth = Responsive.getMaxFormWidth(context);

              return Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding.left,
                      verticalPadding.top,
                      horizontalPadding.right,
                      verticalPadding.bottom,
                    ),
                    child: Row(
                      mainAxisAlignment: isDesktop || isTablet
                          ? MainAxisAlignment.center
                          : MainAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.settings,
                          color: colors.primary,
                          size: isDesktop ? 28 : 24,
                        ),
                        SizedBox(width: spacing * 0.6),
                        Text(
                          'Налаштування',
                          style: TextStyle(
                            color: colors.onBackground,
                            fontSize: isDesktop ? 24 : 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding.left,
                          0,
                          horizontalPadding.right,
                          verticalPadding.bottom * 2,
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: isDesktop || isTablet ? maxFormWidth : double.infinity,
                          ),
                          child: Column(
                            children: [
                              // Адаптивна сітка для налаштувань на десктопі
                              if (isDesktop)
                                GridView.count(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  crossAxisCount: 2,
                                  crossAxisSpacing: spacing,
                                  mainAxisSpacing: spacing,
                                  childAspectRatio: 1.5,
                                  children: [
                                    _SettingsTile(
                                      title: 'Мова застосунку',
                                      subtitle: '$_selectedLanguage',
                                      icon: Icons.language,
                                      onTap: _chooseLanguage,
                                    ),
                                    _SettingsTile(
                                      title: 'Тема застосунку',
                                      subtitle: '$_themeLabel',
                                      icon: Icons.dark_mode_outlined,
                                      onTap: _chooseTheme,
                                    ),
                                  ],
                                )
                              else
                                Column(
                                  children: [
                                    _SettingsTile(
                                      title: 'Мова застосунку',
                                      subtitle: '$_selectedLanguage',
                                      icon: Icons.language,
                                      onTap: _chooseLanguage,
                                    ),
                                    SizedBox(height: spacing),
                                    _SettingsTile(
                                      title: 'Тема застосунку',
                                      subtitle: '$_themeLabel',
                                      icon: Icons.dark_mode_outlined,
                                      onTap: _chooseTheme,
                                    ),
                                  ],
                                ),
                              SizedBox(height: spacing),
                              _SettingsTile(
                                title: 'Про застосунок',
                                icon: Icons.info_outline,
                                onTap: () {
                                  Navigator.of(context).pushNamed(AppConstants.aboutRoute);
                                },
                              ),
                              SizedBox(height: spacing * 1.5),
                              Text(
                                'Версія застосунку: 1.0.0',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: colors.onBackground.withOpacity(0.6),
                                  fontWeight: FontWeight.w600,
                                  fontSize: isDesktop ? 16 : 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.title,
    required this.icon,
    required this.onTap,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDesktop = Responsive.isDesktop(context);
    final isTablet = Responsive.isTablet(context);
    final spacing = Responsive.getSpacing(context);

    return Container(
      margin: EdgeInsets.only(bottom: spacing),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(
          isDesktop ? 20 : 18,
        ),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha:
            theme.brightness == Brightness.light ? 1 : 0.4,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:
              theme.brightness == Brightness.light ? 0.08 : 0.25,
            ),
            blurRadius: isDesktop ? 22 : 18,
            offset: Offset(0, isDesktop ? 14 : 12),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 20 : isTablet ? 18 : 16,
          vertical: isDesktop ? 12 : 8,
        ),
        leading: Container(
          padding: EdgeInsets.all(isDesktop ? 12 : 10),
          decoration: BoxDecoration(
            color: colors.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: colors.primary,
            size: isDesktop ? 24 : 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: colors.onBackground,
            fontWeight: FontWeight.w700,
            fontSize: isDesktop ? 18 : 16,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: TextStyle(
                  color: colors.onBackground.withOpacity(0.6),
                  fontSize: isDesktop ? 15 : 14,
                ),
              )
            : null,
        trailing: Icon(
          Icons.chevron_right,
          color: colors.onBackground.withOpacity(0.45),
          size: isDesktop ? 28 : 24,
        ),
        onTap: onTap,
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool isSelected;

  const _LanguageOption({
    required this.title,
    required this.icon,
    required this.onTap,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDesktop = Responsive.isDesktop(context);
    final isTablet = Responsive.isTablet(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(isDesktop ? 16 : 14),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 18 : isTablet ? 16 : 14,
          vertical: isDesktop ? 16 : 14,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.primary.withOpacity(isDark ? 0.2 : 0.1)
              : colors.surfaceVariant.withOpacity(isDark ? 0.2 : 0.5),
          borderRadius: BorderRadius.circular(isDesktop ? 16 : 14),
          border: Border.all(
            color: isSelected
                ? colors.primary.withOpacity(0.5)
                : colors.outlineVariant.withOpacity(0.5),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? colors.primary : colors.onSurfaceVariant,
              size: isDesktop ? 24 : 22,
            ),
            SizedBox(width: Responsive.getSpacing(context) * 0.8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isSelected ? colors.primary : colors.onSurface,
                  fontSize: isDesktop ? 18 : 16,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: colors.primary,
                size: isDesktop ? 24 : 22,
              ),
          ],
        ),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String title;
  final IconData icon;
  final ThemeMode value;
  final ThemeMode groupValue;
  final ValueChanged<ThemeMode?> onChanged;

  const _ThemeOption({
    required this.title,
    required this.icon,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDesktop = Responsive.isDesktop(context);
    final isTablet = Responsive.isTablet(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSelected = value == groupValue;

    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(isDesktop ? 16 : 14),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 18 : isTablet ? 16 : 14,
          vertical: isDesktop ? 16 : 14,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.primary.withOpacity(isDark ? 0.2 : 0.1)
              : colors.surfaceVariant.withOpacity(isDark ? 0.2 : 0.5),
          borderRadius: BorderRadius.circular(isDesktop ? 16 : 14),
          border: Border.all(
            color: isSelected
                ? colors.primary.withOpacity(0.5)
                : colors.outlineVariant.withOpacity(0.5),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? colors.primary : colors.onSurfaceVariant,
              size: isDesktop ? 24 : 22,
            ),
            SizedBox(width: Responsive.getSpacing(context) * 0.8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isSelected ? colors.primary : colors.onSurface,
                  fontSize: isDesktop ? 18 : 16,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
            Radio<ThemeMode>(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
              activeColor: colors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
