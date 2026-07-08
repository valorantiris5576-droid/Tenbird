import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../app_language.dart';

class DonationScreen extends StatelessWidget {
  const DonationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLanguage.t(
                  en: 'Donation Status',
                  ko: '기부 현황',
                  ja: '寄付状況',
                  es: 'Estado de donación',
                  zh: '捐款状况',
                ),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // 내 기부금 카드
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  final myDon =
                      (snapshot.data?.data() as Map?)?['totalDonation'] ?? 0;
                  final myKm =
                      (snapshot.data?.data() as Map?)?['totalKm'] ?? 0.0;
                  final km = myKm is double ? myKm : (myKm as num).toDouble();
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111827),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF00C896).withValues(alpha: 0.25),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLanguage.t(
                            en: 'This Month\'s Donation',
                            ko: '이번 달 기부',
                            ja: '今月の寄付',
                            es: 'Donación de este mes',
                            zh: '本月捐款',
                          ),
                          style: const TextStyle(
                            color: Color(0xB3FFFFFF),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '₩ $myDon',
                          style: const TextStyle(
                            color: Color(0xFF00C896),
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${km.toStringAsFixed(1)}km ${AppLanguage.t(en: 'run', ko: '달림', ja: '走った', es: 'corrido', zh: '已跑')}',
                          style: const TextStyle(
                            color: Color(0xB3FFFFFF),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // 주간 차트
              Text(
                AppLanguage.t(
                  en: 'Weekly Donation Status',
                  ko: '주간 기부 현황',
                  ja: '週間寄付状況',
                  es: 'Estado semanal de donación',
                  zh: '每周捐款状况',
                ),
                style: const TextStyle(color: Color(0xB3FFFFFF), fontSize: 13),
              ),
              const SizedBox(height: 12),
              _WeeklyChart(uid: uid),
              const SizedBox(height: 20),

              // 최근 기록
              Text(
                AppLanguage.t(
                  en: 'Recent Records',
                  ko: '최근 기록',
                  ja: '最近の記録',
                  es: 'Registros recientes',
                  zh: '最近记录',
                ),
                style: const TextStyle(color: Color(0xB3FFFFFF), fontSize: 13),
              ),
              const SizedBox(height: 8),

              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .collection('runs')
                    .orderBy('createdAt', descending: true)
                    .limit(10)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          AppLanguage.t(
                            en: 'No running records yet',
                            ko: '아직 러닝 기록이 없어요',
                            ja: 'まだランニング記録がありません',
                            es: 'Aún no hay registros de carrera',
                            zh: '还没有跑步记录',
                          ),
                          style: const TextStyle(color: Color(0xFF8899AA)),
                        ),
                      ),
                    );
                  }
                  final docs = snapshot.data!.docs;
                  return Column(
                    children: docs.map((doc) {
                      final km = (doc['distanceKm'] as num).toDouble();
                      final don = doc['donation'] as int;
                      final ts = doc['createdAt'] as Timestamp?;
                      final date = ts != null
                          ? '${ts.toDate().month.toString().padLeft(2, '0')}.${ts.toDate().day.toString().padLeft(2, '0')}'
                          : '--';
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF111827),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.06),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              date,
                              style: const TextStyle(
                                color: Color(0xFF8899AA),
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '${km.toStringAsFixed(1)} km',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '+₩$don',
                              style: const TextStyle(
                                color: Color(0xFF00C896),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  const _WeeklyChart({required this.uid});
  final String? uid;

  @override
  Widget build(BuildContext context) {
    // 요일 이름도 언어에 맞게 바꿔요!
    final days = AppLanguage.current == 'ko'
        ? ['월', '화', '수', '목', '금', '토', '일']
        : AppLanguage.current == 'ja'
        ? ['月', '火', '水', '木', '金', '土', '日']
        : AppLanguage.current == 'es'
        ? ['L', 'M', 'X', 'J', 'V', 'S', 'D']
        : AppLanguage.current == 'zh'
        ? ['一', '二', '三', '四', '五', '六', '日']
        : ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('runs')
          .orderBy('createdAt', descending: true)
          .limit(7)
          .snapshots(),
      builder: (context, snapshot) {
        final heights = List<double>.filled(7, 0.1);

        if (snapshot.hasData) {
          for (final doc in snapshot.data!.docs) {
            final ts = doc['createdAt'] as Timestamp?;
            if (ts != null) {
              final weekday = ts.toDate().weekday - 1;
              final km = (doc['distanceKm'] as num).toDouble();
              if (weekday >= 0 && weekday < 7) {
                heights[weekday] = (km / 10).clamp(0.1, 1.0);
              }
            }
          }
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF111827),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 80,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(7, (i) {
                    final isToday = i == DateTime.now().weekday - 1;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: Container(
                          height: 80 * heights[i],
                          decoration: BoxDecoration(
                            color: isToday
                                ? const Color(0xFF00C896)
                                : const Color(
                                    0xFF00C896,
                                  ).withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: days
                    .map(
                      (d) => Expanded(
                        child: Text(
                          d,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF8899AA),
                            fontSize: 11,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}
