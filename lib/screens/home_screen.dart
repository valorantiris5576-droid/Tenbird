import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  // 로그아웃
  Future<void> _signOut() async {
    await _auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    final isGuest = user?.isAnonymous ?? false;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('안녕하세요 👋',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isGuest ? '게스트님' : (user?.displayName ?? '러너님'),
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  // 로그아웃 버튼
                  IconButton(
                    onPressed: _signOut,
                    icon: const Icon(Icons.logout, color: AppColors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 전체 누적 기부금 카드
              StreamBuilder<DocumentSnapshot>(
                stream: _db.collection('global').doc('stats').snapshots(),
                builder: (context, snapshot) {
                  final total = snapshot.data?.get('totalDonation') ?? 0;
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111827),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: 0.1),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('전체 누적 기부금',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13, letterSpacing: 1),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${total.toString()}원',
                          style: const TextStyle(
                            color: AppColors.accent,
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text('모든 러너들이 함께 만든 금액이에요 🌍',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // 달리기 시작 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.background,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text('🏃 달리기 시작', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 16),

              // 빠른 메뉴
              Row(
                children: [
                  Expanded(
                    child: _QuickCard(
                      emoji: '💚',
                      title: '기부 현황',
                      subtitle: '누적 기부금 확인',
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickCard(
                      emoji: '⭐',
                      title: '미션',
                      subtitle: '도전 과제 확인',
                      onTap: () {},
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickCard extends StatelessWidget {
  const _QuickCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final String emoji;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}