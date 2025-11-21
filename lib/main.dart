import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/constants.dart';
import 'core/di.dart' as di;
import 'core/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await di.init();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie Discovery App',
      theme: ThemeData(primarySwatch: Colors.blue),
      onGenerateRoute: AppRouter.generateRoute,
      initialRoute: AppConstants.homeRoute,
    );
  }
}

