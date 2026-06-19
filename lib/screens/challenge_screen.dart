import 'package:flutter/material.dart';

class ChallengeScreen extends StatelessWidget {
  ChallengeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('챌린지', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              _ChallengeCard(title: '이번 주 10km 완주', subtitle: '달성 시 +100원 추가 기부', goal: '10K', progress: 0.62, current: '6.2', total: '10 km', daysLeft: '4일 남음', color: const Color(0xFF00C896)),
              const SizedBox(height: 12),
              _ChallengeCard(title: '30일 연속 달리기', subtitle: '새벽 6시 이전 달리면 보너스 기부', goal: '30일', progress: 0.4, current: '12', total: '30일', daysLeft: '18일 남음', color: const Color(0xFF1D9E75)),
              const SizedBox(height: 20),
              const Text('완료한 챌린지', style: TextStyle(color: Color(0xB3FFFFFF), fontSize: 13)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _Badge('첫 5K 완주'),
                  _Badge('7일 연속'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  const _ChallengeCard({required this.title, required this.subtitle, required this.goal, required this.progress, required this.current, required this.total, required this.daysLeft, required this.color});
  final String title, subtitle, goal, current, total, daysLeft;
  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFF111827), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withValues(alpha: 0.06))),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: color,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(goal, style: const TextStyle(color: Color(0xFF0A0E1A), fontSize: 28, fontWeight: FontWeight.bold)),
                Text(title, style: const TextStyle(color: Color(0xFF0A0E1A), fontSize: 13, fontWeight: FontWeight.w500)),
                Text(daysLeft, style: TextStyle(color: const Color(0xFF0A0E1A).withValues(alpha: 0.7), fontSize: 11)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('$current / $total', style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w500)),
                    Text('${(progress * 100).toInt()}%', style: const TextStyle(color: Color(0xFF8899AA), fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(value: progress, backgroundColor: const Color(0xFF1E2535), valueColor: AlwaysStoppedAnimation<Color>(color), minHeight: 5),
                ),
                const SizedBox(height: 8),
                Text(subtitle, style: const TextStyle(color: Color(0xFF8899AA), fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF00C896).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF00C896).withValues(alpha: 0.4)),
      ),
      child: Text(label, style: const TextStyle(color: Color(0xFF00C896), fontSize: 13, fontWeight: FontWeight.w500)),
    );
  }
}