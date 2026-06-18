import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

void main() async {
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
        scaffoldBackgroundColor: const Color(0xFF0A0E1A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00C896),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

// 로그인 상태에 따라 홈 또는 로그인 화면 보여주기
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // 로그인 됐으면 홈 화면
        if (snapshot.hasData) return const HomeScreen();
        // 로그인 안 됐으면 로그인 화면
        return const LoginScreen();
      },
    );
  }
}