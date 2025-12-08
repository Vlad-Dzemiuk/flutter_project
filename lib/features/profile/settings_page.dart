import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';

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

    return Scaffold(
      backgroundColor: colors.background,
      body: Container(
        decoration: AppGradients.background(context),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                child: Row(
                  children: [
                    Icon(Icons.settings, color: colors.primary),
                    const SizedBox(width: 10),
                    Text(
                      'Налаштування',
                      style: TextStyle(
                        color: colors.onBackground,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
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
                    _SettingsTile(
                      title: 'Про застосунок',
                      icon: Icons.info_outline,
                      onTap: () {
                        Navigator.of(context).pushNamed(AppConstants.aboutRoute);
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Версія застосунку: 1.0.0',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colors.onBackground.withOpacity(0.6),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant.withOpacity(0.8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              theme.brightness == Brightness.light ? 0.08 : 0.25,
            ),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colors.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: colors.primary),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: colors.onBackground,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: TextStyle(color: colors.onBackground.withOpacity(0.6)),
              )
            : null,
        trailing: Icon(Icons.chevron_right, color: colors.onBackground.withOpacity(0.45)),
        onTap: onTap,
      ),
    );
  }
}
