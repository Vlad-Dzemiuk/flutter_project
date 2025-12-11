import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/constants.dart';
import 'core/di.dart' as di;
import 'core/app_router.dart';
import 'core/theme.dart';
import 'features/settings/settings_bloc.dart';
import 'features/settings/settings_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  
  // Ініціалізація Firebase
  try {
    await Firebase.initializeApp();
  } catch (e) {
    // Якщо Firebase не налаштовано, продовжуємо без нього
  }
  
  // Ініціалізація Hive Flutter
  await Hive.initFlutter();
  
  await di.init();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

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
    final settingsBloc = di.getIt<SettingsBloc>();
    if (settingsBloc.state.themeMode == ThemeMode.system) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SettingsBloc>.value(
      value: di.getIt<SettingsBloc>(),
      child: BlocBuilder<SettingsBloc, SettingsState>(
        bloc: di.getIt<SettingsBloc>(),
        builder: (context, settingsState) {
          return MaterialApp(
            title: 'Movie Discovery App',
            theme: AppThemes.light,
            darkTheme: AppThemes.dark,
            themeMode: settingsState.themeMode,
            // MaterialApp автоматично визначає системну тему через MediaQuery
            // коли themeMode == ThemeMode.system
            onGenerateRoute: AppRouter.generateRoute,
            initialRoute: AppConstants.homeRoute,
          );
        },
      ),
    );
  }
}

