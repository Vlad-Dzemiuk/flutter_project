import 'package:flutter/material.dart';
import '../../core/constants.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _selectedLanguage = 'Українська';
  ThemeMode _selectedTheme = ThemeMode.system;

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
    return Scaffold(
      appBar: AppBar(title: const Text('Налаштування')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: const Text('Мова застосунку'),
            subtitle: Text('$_selectedLanguage (демо)'),
            leading: const Icon(Icons.language),
            trailing: const Icon(Icons.chevron_right),
            onTap: _chooseLanguage,
          ),
          const Divider(),
          ListTile(
            title: const Text('Тема застосунку'),
            subtitle: Text('$_themeLabel (демо)'),
            leading: const Icon(Icons.dark_mode_outlined),
            trailing: const Icon(Icons.chevron_right),
            onTap: _chooseTheme,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Про застосунок'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).pushNamed(AppConstants.aboutRoute);
            },
          ),
          const SizedBox(height: 16),
          const Text(
            'Версія застосунку: 1.0.0',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
