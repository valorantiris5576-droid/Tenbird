import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;
  bool _menuOpen = false;

  Future<void> _signOut() async {
    await _auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    final isGuest = user?.isAnonymous ?? false;
    final uid = user?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('프로필', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                      GestureDetector(
                        onTap: () => setState(() => _menuOpen = !_menuOpen),
                        child: _menuOpen
                            ? const Icon(Icons.close, color: Colors.white, size: 22)
                            : Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(width: 18, height: 2, color: Colors.white, margin: const EdgeInsets.symmetric(vertical: 2)),
                                  Container(width: 18, height: 2, color: Colors.white, margin: const EdgeInsets.symmetric(vertical: 2)),
                                  Container(width: 18, height: 2, color: Colors.white, margin: const EdgeInsets.symmetric(vertical: 2)),
                                ],
                              ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF00C896).withValues(alpha: 0.15),
                            border: Border.all(color: const Color(0xFF00C896), width: 1.5),
                          ),
                          child: const Icon(Icons.person, color: Color(0xFF00C896), size: 32),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          isGuest ? '게스트' : (user?.displayName ?? '러너'),
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        StreamBuilder<DocumentSnapshot>(
                          stream: _db.collection('users').doc(uid).snapshots(),
                          builder: (context, snapshot) {
                            final data = snapshot.data?.data() as Map?;
                            final createdAt = data?['createdAt'] as Timestamp?;
                            final dateStr = createdAt != null
                                ? '가입일 ${createdAt.toDate().year}.${createdAt.toDate().month.toString().padLeft(2, '0')}.${createdAt.toDate().day.toString().padLeft(2, '0')}'
                                : '가입일 -';
                            return Text(dateStr, style: const TextStyle(color: Color(0xB3FFFFFF), fontSize: 12));
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  StreamBuilder<DocumentSnapshot>(
                    stream: _db.collection('users').doc(uid).snapshots(),
                    builder: (context, snapshot) {
                      final data = snapshot.data?.data() as Map?;
                      final totalDon = data?['totalDonation'] ?? 0;
                      final totalKm = data?['totalKm'] ?? 0.0;
                      final km = totalKm is double ? totalKm : (totalKm as num).toDouble();
                      return Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(color: const Color(0xFF141824), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF1E2535))),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('총 기부금', style: TextStyle(color: Color(0xFF8899AA), fontSize: 11)),
                                      const SizedBox(height: 4),
                                      Text('₩$totalDon', style: const TextStyle(color: Color(0xFF00C896), fontSize: 18, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(color: const Color(0xFF141824), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF1E2535))),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('총 거리', style: TextStyle(color: Color(0xFF8899AA), fontSize: 11)),
                                      const SizedBox(height: 4),
                                      Text('${km.toStringAsFixed(1)} km', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: const Color(0xFF141824), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF1E2535))),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('오늘의 요약', style: TextStyle(color: Color(0xFF8899AA), fontSize: 11)),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('오늘 거리', style: TextStyle(color: Color(0xFF8899AA), fontSize: 11)),
                                          const SizedBox(height: 4),
                                          Text('${km.toStringAsFixed(1)} km', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('오늘 기부', style: TextStyle(color: Color(0xFF8899AA), fontSize: 11)),
                                          const SizedBox(height: 4),
                                          Text('₩$totalDon', style: const TextStyle(color: Color(0xFF00C896), fontSize: 16, fontWeight: FontWeight.w500)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: const Color(0xFF141824), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF1E2535))),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('이번 주 목표', style: TextStyle(color: Color(0xFF8899AA), fontSize: 11)),
                                    Text('${km.toStringAsFixed(1)} / 10 km', style: const TextStyle(color: Color(0xFF00C896), fontSize: 11)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: (km / 10).clamp(0.0, 1.0),
                                    backgroundColor: const Color(0xFF1E2535),
                                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00C896)),
                                    minHeight: 5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text('최근 러닝', style: TextStyle(color: Color(0xB3FFFFFF), fontSize: 13)),
                  const SizedBox(height: 8),
                  StreamBuilder<QuerySnapshot>(
                    stream: _db.collection('users').doc(uid).collection('runs').orderBy('createdAt', descending: true).limit(5).snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Text('아직 러닝 기록이 없어요', style: TextStyle(color: Color(0xFF8899AA)));
                      }
                      return Column(
                        children: snapshot.data!.docs.map((doc) {
                          final km = (doc['distanceKm'] as num).toDouble();
                          final don = doc['donation'] as int;
                          final ts = doc['createdAt'] as Timestamp?;
                          final date = ts != null ? '${ts.toDate().month}.${ts.toDate().day.toString().padLeft(2, '0')}' : '--';
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                                Text('₩$don', style: const TextStyle(color: Color(0xFF00C896), fontWeight: FontWeight.w500)),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
            if (_menuOpen)
              Container(
                color: const Color(0xFF0A0E1A),
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('설정', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                            GestureDetector(
                              onTap: () => setState(() => _menuOpen = false),
                              child: const Icon(Icons.close, color: Colors.white, size: 22),
                            ),
                          ],
                        ),
                      ),
                      _MenuItem(icon: Icons.lock_outline, title: '보안', subtitle: '비밀번호 · 2단계 인증'),
                      _MenuItem(icon: Icons.person_add_outlined, title: '친구 추가', subtitle: '함께 달릴 친구 찾기'),
                      _MenuItem(icon: Icons.location_on_outlined, title: '동네 변경', subtitle: '내 활동 지역 설정'),
                      _MenuItem(icon: Icons.help_outline, title: '도움말', subtitle: '자주 묻는 질문'),
                      _MenuItem(icon: Icons.notifications_outlined, title: '알림 설정', subtitle: '푸시 알림 관리'),
                      const Divider(color: Color(0xFF1E2535)),
                      ListTile(
                        leading: const Icon(Icons.logout, color: Colors.redAccent),
                        title: const Text('로그아웃', style: TextStyle(color: Colors.redAccent)),
                        onTap: _signOut,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(color: const Color(0xFF141824), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFF1E2535))),
        child: Icon(icon, color: const Color(0xFF00C896), size: 18),
      ),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(color: Color(0xFF8899AA), fontSize: 11)),
      trailing: const Icon(Icons.chevron_right, color: Color(0xFF4A5568), size: 18),
    );
  }
}