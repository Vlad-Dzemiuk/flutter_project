import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/constants.dart';
import 'core/di.dart' as di;
import 'core/app_router.dart';
import 'core/theme.dart';
import 'core/storage/user_prefs.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Hive.initFlutter();
  await di.init();

  final storedTheme = await UserPrefs.instance.getThemeMode();
  final themeController =
      ThemeController(AppThemes.parseThemeMode(storedTheme));

  runApp(MyApp(themeController: themeController));
}

class MyApp extends StatefulWidget {
  final ThemeController themeController;

  const MyApp({super.key, required this.themeController});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    // Коли системна тема змінюється, оновлюємо UI якщо використовується ThemeMode.system
    if (widget.themeController.mode == ThemeMode.system) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.themeController,
      builder: (context, _) {
        return ThemeControllerScope(
          controller: widget.themeController,
          child: MaterialApp(
            title: 'Movie Discovery App',
            theme: AppThemes.light,
            darkTheme: AppThemes.dark,
            themeMode: widget.themeController.mode,
            // MaterialApp автоматично визначає системну тему через MediaQuery
            // коли themeMode == ThemeMode.system
            onGenerateRoute: AppRouter.generateRoute,
            initialRoute: AppConstants.homeRoute,
          ),
        );
      },
    );
  }
}

