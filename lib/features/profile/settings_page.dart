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
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Text(
              'Оберіть мову',
              style: Theme.of(ctx).textTheme.titleMedium,
            ),
            ListTile(
              title: const Text('Українська'),
              onTap: () => Navigator.of(ctx).pop('Українська'),
            ),
            ListTile(
              title: const Text('English'),
              onTap: () => Navigator.of(ctx).pop('English'),
            ),
          ],
        ),
      ),
    );
    if (lang != null) {
      setState(() => _selectedLanguage = lang);
    }
  }

  Future<void> _chooseTheme() async {
    final controller = ThemeControllerScope.of(context);
    final theme = await showModalBottomSheet<ThemeMode>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Text(
              'Тема застосунку',
              style: Theme.of(ctx).textTheme.titleMedium,
            ),
            RadioListTile<ThemeMode>(
              value: ThemeMode.system,
              groupValue: _selectedTheme,
              onChanged: (value) => Navigator.of(ctx).pop(value),
              title: const Text('Системна'),
            ),
            RadioListTile<ThemeMode>(
              value: ThemeMode.light,
              groupValue: _selectedTheme,
              onChanged: (value) => Navigator.of(ctx).pop(value),
              title: const Text('Світла'),
            ),
            RadioListTile<ThemeMode>(
              value: ThemeMode.dark,
              groupValue: _selectedTheme,
              onChanged: (value) => Navigator.of(ctx).pop(value),
              title: const Text('Темна'),
            ),
          ],
        ),
      ),
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

    return Container(
      margin: EdgeInsets.only(bottom: Responsive.getSpacing(context)),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(
          isDesktop ? 18 : isTablet ? 17 : 16,
        ),
        border: Border.all(color: colors.outlineVariant.withOpacity(0.8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              theme.brightness == Brightness.light ? 0.08 : 0.25,
            ),
            blurRadius: isDesktop ? 16 : 14,
            offset: Offset(0, isDesktop ? 10 : 8),
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
