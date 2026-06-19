import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'donation_screen.dart';
import 'running_screen.dart';
import 'challenge_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _idx = 0;

  final _pages = [
    const HomeScreen(),
    const DonationScreen(),
    RunningScreen(),
    ChallengeScreen(),
    const ProfileScreen(),
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 웹 화면에서 양쪽 여백이 더 자연스러워 보이도록 배경색 수정
      backgroundColor: const Color(0xFF050810),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: IndexedStack(
            index: _idx,
            children: _pages,
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Color(0xFF1E2535), width: 0.5),
          ),
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
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: '홈',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              label: '기부',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.directions_run),
              label: '러닝',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.emoji_events_outlined),
              label: '챌린지',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: '프로필',
            ),
          ],
        ),
      ),
    );
  }
}