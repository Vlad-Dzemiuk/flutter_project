import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../l10n/app_localizations.dart';
import '../../core/constants.dart';
import '../../core/di.dart';
import '../../core/responsive.dart';
import '../../core/theme.dart';
import '../../shared/widgets/loading_wrapper.dart';
import '../settings/settings_bloc.dart';
import '../settings/settings_event.dart';
import '../settings/settings_state.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SettingsBloc>.value(
      value: getIt<SettingsBloc>(),
      child: const _SettingsPageContent(),
    );
  }
}

class _SettingsPageContent extends StatefulWidget {
  const _SettingsPageContent();

  @override
  State<_SettingsPageContent> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<_SettingsPageContent> {
  String _selectedLanguage = 'Українська';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final settingsState = context.watch<SettingsBloc>().state;
    final l10n = AppLocalizations.of(context)!;
    // Оновлюємо мову зі стану
    if (settingsState.languageCode == 'uk') {
      _selectedLanguage = l10n.ukrainian;
    } else {
      _selectedLanguage = l10n.english;
    }
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
        final modalL10n = AppLocalizations.of(ctx)!;
        final settingsState = ctx.watch<SettingsBloc>().state;

        return Container(
          decoration: BoxDecoration(
            gradient: isDark
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF0F172A), Color(0xFF0B1020)],
                  )
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [colors.surfaceContainerHighest, colors.surface],
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
                        color: colors.onSurfaceVariant.withValues(alpha: 0.4),
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
                        size: isDesktop
                            ? 28
                            : isTablet
                                ? 26
                                : 24,
                      ),
                      SizedBox(width: spacing * 0.6),
                      Text(
                        modalL10n.selectLanguage,
                        style: TextStyle(
                          color: colors.onSurface,
                          fontSize: isDesktop
                              ? 24
                              : isTablet
                                  ? 22
                                  : 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: spacing * 1.5),
                  // Language options
                  _LanguageOption(
                    title: modalL10n.ukrainian,
                    icon: Icons.flag,
                    onTap: () => Navigator.of(ctx).pop('uk'),
                    isSelected: settingsState.languageCode == 'uk',
                  ),
                  SizedBox(height: spacing),
                  _LanguageOption(
                    title: modalL10n.english,
                    icon: Icons.flag_outlined,
                    onTap: () => Navigator.of(ctx).pop('en'),
                    isSelected: settingsState.languageCode == 'en',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    if (lang != null && mounted) {
      context.read<SettingsBloc>().add(SetLanguageEvent(lang));
      final updatedL10n = AppLocalizations.of(context)!;
      setState(() {
        _selectedLanguage =
            lang == 'uk' ? updatedL10n.ukrainian : updatedL10n.english;
      });
    }
  }

  Future<void> _chooseTheme() async {
    final settingsBloc = context.read<SettingsBloc>();
    final currentTheme = settingsBloc.state.themeMode;
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
                    colors: [Color(0xFF0F172A), Color(0xFF0B1020)],
                  )
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [colors.surfaceContainerHighest, colors.surface],
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
                        color: colors.onSurfaceVariant.withValues(alpha: 0.4),
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
                        size: isDesktop
                            ? 28
                            : isTablet
                                ? 26
                                : 24,
                      ),
                      SizedBox(width: spacing * 0.6),
                      Text(
                        AppLocalizations.of(context)!.appThemeTitle,
                        style: TextStyle(
                          color: colors.onSurface,
                          fontSize: isDesktop
                              ? 24
                              : isTablet
                                  ? 22
                                  : 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: spacing * 1.5),
                  // Theme options
                  _ThemeOption(
                    title: AppLocalizations.of(context)!.systemTheme,
                    icon: Icons.brightness_auto,
                    value: ThemeMode.system,
                    groupValue: currentTheme,
                    onChanged: (value) => Navigator.of(ctx).pop(value),
                  ),
                  SizedBox(height: spacing),
                  _ThemeOption(
                    title: AppLocalizations.of(context)!.lightTheme,
                    icon: Icons.light_mode,
                    value: ThemeMode.light,
                    groupValue: currentTheme,
                    onChanged: (value) => Navigator.of(ctx).pop(value),
                  ),
                  SizedBox(height: spacing),
                  _ThemeOption(
                    title: AppLocalizations.of(context)!.darkTheme,
                    icon: Icons.dark_mode,
                    value: ThemeMode.dark,
                    groupValue: currentTheme,
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
      settingsBloc.add(SetThemeModeEvent(theme));
    }
  }

  String _getThemeLabel(ThemeMode themeMode) {
    final l10n = AppLocalizations.of(context)!;
    switch (themeMode) {
      case ThemeMode.light:
        return l10n.lightTheme;
      case ThemeMode.dark:
        return l10n.darkTheme;
      case ThemeMode.system:
        return l10n.systemTheme;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      bloc: context.read<SettingsBloc>(),
      builder: (context, settingsState) {
        final theme = Theme.of(context);
        final colors = theme.colorScheme;
        final currentTheme = settingsState.themeMode;

        return LoadingWrapper(
          child: Scaffold(
            backgroundColor: colors.surface,
            body: Container(
              decoration: AppGradients.background(context),
              child: SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isDesktop = Responsive.isDesktop(context);
                    final isTablet = Responsive.isTablet(context);
                    final horizontalPadding = Responsive.getHorizontalPadding(
                      context,
                    );
                    final verticalPadding = Responsive.getVerticalPadding(
                      context,
                    );
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
                                AppLocalizations.of(context)!.settings,
                                style: TextStyle(
                                  color: colors.onSurface,
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
                                  maxWidth: isDesktop || isTablet
                                      ? maxFormWidth
                                      : double.infinity,
                                ),
                                child: Column(
                                  children: [
                                    // Адаптивна сітка для налаштувань на десктопі
                                    if (isDesktop)
                                      GridView.count(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        crossAxisCount: 2,
                                        crossAxisSpacing: spacing,
                                        mainAxisSpacing: spacing,
                                        childAspectRatio: 1.5,
                                        children: [
                                          _SettingsTile(
                                            title: AppLocalizations.of(
                                              context,
                                            )!
                                                .appLanguage,
                                            subtitle: _selectedLanguage,
                                            icon: Icons.language,
                                            onTap: _chooseLanguage,
                                          ),
                                          _SettingsTile(
                                            title: AppLocalizations.of(
                                              context,
                                            )!
                                                .appTheme,
                                            subtitle: _getThemeLabel(
                                              currentTheme,
                                            ),
                                            icon: Icons.dark_mode_outlined,
                                            onTap: _chooseTheme,
                                          ),
                                        ],
                                      )
                                    else
                                      Column(
                                        children: [
                                          _SettingsTile(
                                            title: AppLocalizations.of(
                                              context,
                                            )!
                                                .appLanguage,
                                            subtitle: _selectedLanguage,
                                            icon: Icons.language,
                                            onTap: _chooseLanguage,
                                          ),
                                          SizedBox(height: spacing),
                                          _SettingsTile(
                                            title: AppLocalizations.of(
                                              context,
                                            )!
                                                .appTheme,
                                            subtitle: _getThemeLabel(
                                              currentTheme,
                                            ),
                                            icon: Icons.dark_mode_outlined,
                                            onTap: _chooseTheme,
                                          ),
                                        ],
                                      ),
                                    SizedBox(height: spacing),
                                    _SettingsTile(
                                      title: AppLocalizations.of(
                                        context,
                                      )!
                                          .aboutApp,
                                      icon: Icons.info_outline,
                                      onTap: () {
                                        Navigator.of(
                                          context,
                                        ).pushNamed(AppConstants.aboutRoute);
                                      },
                                    ),
                                    SizedBox(height: spacing * 1.5),
                                    Text(
                                      AppLocalizations.of(
                                        context,
                                      )!
                                          .appVersion('1.0.0'),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: colors.onSurface.withValues(
                                          alpha: 0.6,
                                        ),
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
      },
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
        borderRadius: BorderRadius.circular(isDesktop ? 20 : 18),
        border: Border.all(
          color: colors.outlineVariant.withValues(
            alpha: theme.brightness == Brightness.light ? 1 : 0.4,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: theme.brightness == Brightness.light ? 0.08 : 0.25,
            ),
            blurRadius: isDesktop ? 22 : 18,
            offset: Offset(0, isDesktop ? 14 : 12),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: isDesktop
              ? 20
              : isTablet
                  ? 18
                  : 16,
          vertical: isDesktop ? 12 : 8,
        ),
        leading: Container(
          padding: EdgeInsets.all(isDesktop ? 12 : 10),
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: colors.primary, size: isDesktop ? 24 : 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: colors.onSurface,
            fontWeight: FontWeight.w700,
            fontSize: isDesktop ? 18 : 16,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: TextStyle(
                  color: colors.onSurface.withValues(alpha: 0.6),
                  fontSize: isDesktop ? 15 : 14,
                ),
              )
            : null,
        trailing: Icon(
          Icons.chevron_right,
          color: colors.onSurface.withValues(alpha: 0.45),
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
          horizontal: isDesktop
              ? 18
              : isTablet
                  ? 16
                  : 14,
          vertical: isDesktop ? 16 : 14,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.primary.withValues(alpha: isDark ? 0.2 : 0.1)
              : colors.surfaceContainerHighest.withValues(
                  alpha: isDark ? 0.2 : 0.5,
                ),
          borderRadius: BorderRadius.circular(isDesktop ? 16 : 14),
          border: Border.all(
            color: isSelected
                ? colors.primary.withValues(alpha: 0.5)
                : colors.outlineVariant.withValues(alpha: 0.5),
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
          horizontal: isDesktop
              ? 18
              : isTablet
                  ? 16
                  : 14,
          vertical: isDesktop ? 16 : 14,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.primary.withValues(alpha: isDark ? 0.2 : 0.1)
              : colors.surfaceContainerHighest.withValues(
                  alpha: isDark ? 0.2 : 0.5,
                ),
          borderRadius: BorderRadius.circular(isDesktop ? 16 : 14),
          border: Border.all(
            color: isSelected
                ? colors.primary.withValues(alpha: 0.5)
                : colors.outlineVariant.withValues(alpha: 0.5),
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
