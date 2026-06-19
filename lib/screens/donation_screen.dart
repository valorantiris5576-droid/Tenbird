import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DonationScreen extends StatelessWidget {
  const DonationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal : 20, vertical : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '기부 현황',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                .collection('users')
                .doc(uid)
                .snapshots(),
              builder : (context , snapshot) {
                final myDon = (snapshot.data?.data() as Map?)?['totalDonation'] ?? 0;
                final myKm = (snapshot.data?.data() as Map?)?['totalKm'] ?? 0.0;
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
                        const Text(
                          '이번 달 기부',
                          style: TextStyle(color: Color(0xB3FFFFFF), fontSize: 13),
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
                          '${km.toStringAsFixed(1)}km 달림',
                          style: const TextStyle(color: Color(0xB3FFFFFF),fontSize: 12),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              const Text(
                '주간 기부 현황',
                style: TextStyle(color: Color(0xB3FFFFFF), fontSize: 13),
              ),
              const SizedBox(height: 12),
              _WeeklyChart(uid: uid),
              const SizedBox(height: 20),
              const Text(
                '최근 기록',
                style: TextStyle(color: Color(0xB3FFFFFF), fontSize: 13),
              ),
              const SizedBox(height : 8),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .collection('runs')
                    .orderBy('createdAt', descending: true)
                    .limit(10)
                    .snapshots(),
                builder: (context,snapshot){
                  if(!snapshot.hasData || snapshot.data!.docs.isEmpty){
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          '아직 러닝 기록이 없어요',
                          style: TextStyle(color: Color(0xFF8899AA)),
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
                          ? '${ts.toDate().month.toString().padLeft(2,'0')}.${ts.toDate().day.toString().padLeft(2,'0')}'
                          : '--';
                      return Container(
                        margin: const EdgeInsets.only(bottom : 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF111827),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(date, style: const TextStyle(color: Color(0xFF8899AA), fontSize: 12)),
                            Text('${km.toStringAsFixed(1)} km', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                            Text('+₩$don', style: const TextStyle(color: Color(0xFF00C896), fontWeight: FontWeight.w500)),
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
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('runs')
          .orderBy('createdAt', descending: true)
          .limit(7)
          .snapshots(),
      builder: (context, snapshot) {
        final days = ['월', '화', '수', '목', '금', '토', '일'];
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
                                : const Color(0xFF00C896).withValues(alpha: 0.3),
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
                children: days.map((d) => Expanded(
                  child: Text(
                    d,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Color(0xFF8899AA), fontSize: 11),
                  ),
                )).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}