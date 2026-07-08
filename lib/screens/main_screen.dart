import 'package:flutter/material.dart';
import 'donation_screen.dart';
import 'running_screen.dart';
import 'challenge_screen.dart';
import 'profile_screen.dart';
import 'home_screen.dart';
import '../app_language.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _idx = 0;

  void setIndex(int i) {
    setState(() => _idx = i);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(
        onGoToRunning: () => setIndex(2),
        onGoToChallenge: () => setIndex(3),
      ),
      const DonationScreen(),
      RunningScreen(),
      ChallengeScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF050810),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: IndexedStack(index: _idx, children: pages),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFF1E2535), width: 0.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: _idx,
          onTap: (i) => setState(() => _idx = i),
          backgroundColor: const Color(0xFF0D1120),
          selectedItemColor: const Color(0xFF00C896),
          unselectedItemColor: const Color(0xFF4A5568),
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 10,
          unselectedFontSize: 10,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
              label: AppLanguage.t(
                en: 'Home',
                ko: '홈',
                ja: 'ホーム',
                es: 'Inicio',
                zh: '首页',
              ),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.bar_chart),
              label: AppLanguage.t(
                en: 'Donate',
                ko: '기부',
                ja: '寄付',
                es: 'Donar',
                zh: '捐款',
              ),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.directions_run),
              label: AppLanguage.t(
                en: 'Run',
                ko: '러닝',
                ja: 'ラン',
                es: 'Correr',
                zh: '跑步',
              ),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.emoji_events_outlined),
              label: AppLanguage.t(
                en: 'Challenge',
                ko: '챌린지',
                ja: 'チャレンジ',
                es: 'Desafío',
                zh: '挑战',
              ),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline),
              label: AppLanguage.t(
                en: 'Profile',
                ko: '프로필',
                ja: 'プロフィール',
                es: 'Perfil',
                zh: '我的',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
