import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'theme/app_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const StepGiveApp());
}

class StepGiveApp extends StatelessWidget {
  const StepGiveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StepGive',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.dark(
          primary: AppColors.accent,
          surface: AppColors.background,
        ),
        inputDecorationTheme: InputDecorationTheme(
          errorStyle: const TextStyle(color: Colors.redAccent),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
