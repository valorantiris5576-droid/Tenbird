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
  int _tabIndex = 0;

  Future<void> _signOut() async {
    await _auth.signOut();
  }

  void _showSecurityDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF141824),
        title: const Text('보안', style: TextStyle(color: Colors.white)),
        content: const Text(
          '2단계 인증 및 보안 기능은 준비 중이에요! 곧 업데이트될 예정이에요.',
          style: TextStyle(color: Color(0xB3FFFFFF), fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인', style: TextStyle(color: Color(0xFF00C896))),
          ),
        ],
      ),
    );
  }

  void _showFriendDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF141824),
        title: const Text('친구 추가', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '친구의 유저네임을 입력하세요.',
              style: TextStyle(color: Color(0xB3FFFFFF), fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: '유저네임',
                labelStyle: const TextStyle(color: Color(0xFF8899AA)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF1E2535)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF00C896)),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소', style: TextStyle(color: Color(0xFF8899AA))),
          ),
          TextButton(
            onPressed: () async {
              final username = controller.text.trim();
              if (username.isEmpty) return;
              final uid = _auth.currentUser?.uid;
              final result = await _db
                  .collection('users')
                  .where('username', isEqualTo: username)
                  .limit(1)
                  .get();
              if (context.mounted) {
                Navigator.pop(context);
                if (result.docs.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('유저를 찾을 수 없어요.')),
                  );
                } else {
                  final friendUid = result.docs.first.id;
                  await _db
                      .collection('users')
                      .doc(uid)
                      .collection('friends')
                      .doc(friendUid)
                      .set({
                        'username': username,
                        'addedAt': FieldValue.serverTimestamp(),
                      });
                  if (context.mounted)
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('$username 님을 친구로 추가했어요!')),
                    );
                }
              }
            },
            child: const Text('추가', style: TextStyle(color: Color(0xFF00C896))),
          ),
        ],
      ),
    );
  }

  void _showLocationDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF141824),
        title: const Text('동네 변경', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '활동 지역을 입력하세요.',
              style: TextStyle(color: Color(0xB3FFFFFF), fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: '예: 서울 강남구',
                labelStyle: const TextStyle(color: Color(0xFF8899AA)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF1E2535)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF00C896)),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소', style: TextStyle(color: Color(0xFF8899AA))),
          ),
          TextButton(
            onPressed: () async {
              final uid = _auth.currentUser?.uid;
              if (uid != null && controller.text.trim().isNotEmpty) {
                await _db.collection('users').doc(uid).set({
                  'location': controller.text.trim(),
                }, SetOptions(merge: true));
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('동네가 변경됐어요!')));
                }
              }
            },
            child: const Text('저장', style: TextStyle(color: Color(0xFF00C896))),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111827),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF1E2535),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '도움말',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: const [
                  _HelpItem(
                    q: '기부금은 어떻게 계산되나요?',
                    a: '1km를 달릴 때마다 10원이 자동으로 기부됩니다.',
                  ),
                  _HelpItem(q: 'GPS가 안 켜져요.', a: '브라우저에서 위치 권한을 허용해주세요.'),
                  _HelpItem(
                    q: '챌린지는 몇 개까지 가능한가요?',
                    a: '동시에 최대 3개까지 도전할 수 있어요.',
                  ),
                  _HelpItem(
                    q: '기부금은 실제로 어디로 가나요?',
                    a: '현재는 개발 단계로 실제 기부는 이루어지지 않아요.',
                  ),
                  _HelpItem(
                    q: '러닝을 중간에 멈추면 기부금은?',
                    a: '멈춘 시점까지 달린 거리로 기부금이 계산돼요.',
                  ),
                  _HelpItem(
                    q: '게스트로 로그인하면 기록이 저장되나요?',
                    a: '게스트도 러닝 기록이 저장돼요. 단, 다른 기기에서는 접근 불가해요.',
                  ),
                  _HelpItem(
                    q: '비밀번호를 잊어버렸어요.',
                    a: '로그인 화면에서 Forgot Password를 눌러 이메일로 재설정 링크를 받으세요.',
                  ),
                  _HelpItem(
                    q: '챌린지를 포기하면 어떻게 되나요?',
                    a: '진행 중인 챌린지를 포기하면 기존 진행률이 초기화돼요.',
                  ),
                  _HelpItem(
                    q: '날씨 정보가 틀려요.',
                    a: '서울 강남 기준 날씨를 표시해요. 실시간 위치 기반은 추후 업데이트 예정이에요.',
                  ),
                  _HelpItem(
                    q: '동네 변경은 왜 하는 건가요?',
                    a: '동네별 러너 랭킹과 코스 추천 기능에 활용될 예정이에요.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF141824),
        title: const Text('알림 설정', style: TextStyle(color: Colors.white)),
        content: const Text(
          '푸시 알림 기능은 준비 중이에요! 곧 업데이트될 예정이에요.',
          style: TextStyle(color: Color(0xB3FFFFFF), fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인', style: TextStyle(color: Color(0xFF00C896))),
          ),
        ],
      ),
    );
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
                      const Text(
                        '프로필',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _menuOpen = !_menuOpen),
                        child: _menuOpen
                            ? const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 22,
                              )
                            : Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 18,
                                    height: 2,
                                    color: Colors.white,
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 2,
                                    ),
                                  ),
                                  Container(
                                    width: 18,
                                    height: 2,
                                    color: Colors.white,
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 2,
                                    ),
                                  ),
                                  Container(
                                    width: 18,
                                    height: 2,
                                    color: Colors.white,
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 2,
                                    ),
                                  ),
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
                            color: const Color(
                              0xFF00C896,
                            ).withValues(alpha: 0.15),
                            border: Border.all(
                              color: const Color(0xFF00C896),
                              width: 1.5,
                            ),
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Color(0xFF00C896),
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          isGuest ? '게스트' : (user?.displayName ?? '러너'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
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
                            return Text(
                              dateStr,
                              style: const TextStyle(
                                color: Color(0xB3FFFFFF),
                                fontSize: 12,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _tabIndex = 0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: _tabIndex == 0
                                      ? const Color(0xFF00C896)
                                      : const Color(0xFF1E2535),
                                  width: 2,
                                ),
                              ),
                            ),
                            child: Text(
                              '내 정보',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _tabIndex == 0
                                    ? const Color(0xFF00C896)
                                    : const Color(0xFF8899AA),
                                fontSize: 13,
                                fontWeight: _tabIndex == 0
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _tabIndex = 1),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: _tabIndex == 1
                                      ? const Color(0xFF00C896)
                                      : const Color(0xFF1E2535),
                                  width: 2,
                                ),
                              ),
                            ),
                            child: Text(
                              '친구',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _tabIndex == 1
                                    ? const Color(0xFF00C896)
                                    : const Color(0xFF8899AA),
                                fontSize: 13,
                                fontWeight: _tabIndex == 1
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (_tabIndex == 0) ...[
                    StreamBuilder<DocumentSnapshot>(
                      stream: _db.collection('users').doc(uid).snapshots(),
                      builder: (context, snapshot) {
                        final data = snapshot.data?.data() as Map?;
                        final totalDon = data?['totalDonation'] ?? 0;
                        final totalKm = data?['totalKm'] ?? 0.0;
                        final km = totalKm is double
                            ? totalKm
                            : (totalKm as num).toDouble();
                        return Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF141824),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: const Color(0xFF1E2535),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          '총 기부금',
                                          style: TextStyle(
                                            color: Color(0xFF8899AA),
                                            fontSize: 11,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '₩$totalDon',
                                          style: const TextStyle(
                                            color: Color(0xFF00C896),
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF141824),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: const Color(0xFF1E2535),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          '총 거리',
                                          style: TextStyle(
                                            color: Color(0xFF8899AA),
                                            fontSize: 11,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${km.toStringAsFixed(1)} km',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
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
                              decoration: BoxDecoration(
                                color: const Color(0xFF141824),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFF1E2535),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        '이번 주 목표',
                                        style: TextStyle(
                                          color: Color(0xFF8899AA),
                                          fontSize: 11,
                                        ),
                                      ),
                                      Text(
                                        '${km.toStringAsFixed(1)} / 10 km',
                                        style: const TextStyle(
                                          color: Color(0xFF00C896),
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: (km / 10).clamp(0.0, 1.0),
                                      backgroundColor: const Color(0xFF1E2535),
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                            Color(0xFF00C896),
                                          ),
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
                    const Text(
                      '최근 러닝',
                      style: TextStyle(color: Color(0xB3FFFFFF), fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    StreamBuilder<QuerySnapshot>(
                      stream: _db
                          .collection('users')
                          .doc(uid)
                          .collection('runs')
                          .orderBy('createdAt', descending: true)
                          .limit(5)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Text(
                            '아직 러닝 기록이 없어요',
                            style: TextStyle(color: Color(0xFF8899AA)),
                          );
                        }
                        return Column(
                          children: snapshot.data!.docs.map((doc) {
                            final km = (doc['distanceKm'] as num).toDouble();
                            final don = doc['donation'] as int;
                            final ts = doc['createdAt'] as Timestamp?;
                            final date = ts != null
                                ? '${ts.toDate().month}.${ts.toDate().day.toString().padLeft(2, '0')}'
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                    '₩$don',
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

                  if (_tabIndex == 1) ...[
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: '유저네임 검색',
                              hintStyle: const TextStyle(
                                color: Color(0xFF8899AA),
                              ),
                              filled: true,
                              fillColor: const Color(0xFF141824),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Color(0xFF1E2535),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Color(0xFF1E2535),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Color(0xFF00C896),
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                            ),
                            onSubmitted: (value) => _showFriendDialog(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _showFriendDialog,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00C896),
                            foregroundColor: const Color(0xFF0A0E1A),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          child: const Text('추가'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    StreamBuilder<QuerySnapshot>(
                      stream: _db
                          .collection('users')
                          .doc(uid)
                          .collection('friends')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Text(
                                '아직 친구가 없어요\n유저네임으로 친구를 추가해보세요!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFF8899AA),
                                  height: 1.6,
                                ),
                              ),
                            ),
                          );
                        }
                        return Column(
                          children: snapshot.data!.docs.map((doc) {
                            final friendUid = doc.id;
                            final username = doc['username'] ?? '알 수 없음';
                            return StreamBuilder<DocumentSnapshot>(
                              stream: _db
                                  .collection('users')
                                  .doc(friendUid)
                                  .snapshots(),
                              builder: (context, friendSnap) {
                                final data = friendSnap.data?.data() as Map?;
                                final km = (data?['totalKm'] ?? 0.0);
                                final friendKm = km is double
                                    ? km
                                    : (km as num).toDouble();
                                final don = data?['totalDonation'] ?? 0;
                                final initials = username.length >= 2
                                    ? username.substring(0, 2).toUpperCase()
                                    : username.toUpperCase();
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF141824),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0xFF1E2535),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: const Color(
                                                0xFF00C896,
                                              ).withValues(alpha: 0.15),
                                              border: Border.all(
                                                color: const Color(0xFF00C896),
                                                width: 1.5,
                                              ),
                                            ),
                                            child: Center(
                                              child: Text(
                                                initials,
                                                style: const TextStyle(
                                                  color: Color(0xFF00C896),
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  username,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                Text(
                                                  '총 ${friendKm.toStringAsFixed(1)}km 달림',
                                                  style: const TextStyle(
                                                    color: Color(0xFF8899AA),
                                                    fontSize: 11,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                '₩$don',
                                                style: const TextStyle(
                                                  color: Color(0xFF00C896),
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const Text(
                                                '총 기부',
                                                style: TextStyle(
                                                  color: Color(0xFF8899AA),
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          value: (friendKm / 10).clamp(
                                            0.0,
                                            1.0,
                                          ),
                                          backgroundColor: const Color(
                                            0xFF1E2535,
                                          ),
                                          valueColor:
                                              const AlwaysStoppedAnimation<
                                                Color
                                              >(Color(0xFF00C896)),
                                          minHeight: 4,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            '주간 목표',
                                            style: TextStyle(
                                              color: Color(0xFF8899AA),
                                              fontSize: 10,
                                            ),
                                          ),
                                          Text(
                                            '${friendKm.toStringAsFixed(1)} / 10km',
                                            style: const TextStyle(
                                              color: Color(0xFF8899AA),
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              '설정',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => setState(() => _menuOpen = false),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _MenuItem(
                        icon: Icons.lock_outline,
                        title: '보안',
                        subtitle: '비밀번호 · 2단계 인증',
                        onTap: _showSecurityDialog,
                      ),
                      _MenuItem(
                        icon: Icons.person_add_outlined,
                        title: '친구 추가',
                        subtitle: '함께 달릴 친구 찾기',
                        onTap: () {
                          setState(() {
                            _menuOpen = false;
                            _tabIndex = 1;
                          });
                        },
                      ),
                      _MenuItem(
                        icon: Icons.location_on_outlined,
                        title: '동네 변경',
                        subtitle: '내 활동 지역 설정',
                        onTap: _showLocationDialog,
                      ),
                      _MenuItem(
                        icon: Icons.help_outline,
                        title: '도움말',
                        subtitle: '자주 묻는 질문',
                        onTap: _showHelpDialog,
                      ),
                      _MenuItem(
                        icon: Icons.notifications_outlined,
                        title: '알림 설정',
                        subtitle: '푸시 알림 관리',
                        onTap: _showNotificationDialog,
                      ),
                      const Divider(color: Color(0xFF1E2535)),
                      ListTile(
                        leading: const Icon(
                          Icons.logout,
                          color: Colors.redAccent,
                        ),
                        title: const Text(
                          '로그아웃',
                          style: TextStyle(color: Colors.redAccent),
                        ),
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
  const _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFF141824),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF1E2535)),
        ),
        child: Icon(icon, color: const Color(0xFF00C896), size: 18),
      ),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Color(0xFF8899AA), fontSize: 11),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: Color(0xFF4A5568),
        size: 18,
      ),
    );
  }
}

class _HelpItem extends StatefulWidget {
  const _HelpItem({required this.q, required this.a});
  final String q;
  final String a;

  @override
  State<_HelpItem> createState() => _HelpItemState();
}

class _HelpItemState extends State<_HelpItem> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _open = !_open),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF141824),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF1E2535)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.q,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Icon(
                    _open ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: const Color(0xFF8899AA),
                    size: 18,
                  ),
                ],
              ),
            ),
            if (_open)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                child: Text(
                  widget.a,
                  style: const TextStyle(
                    color: Color(0xB3FFFFFF),
                    fontSize: 12,
                    height: 1.6,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
