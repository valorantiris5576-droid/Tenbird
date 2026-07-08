import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../app_language.dart';
import '../models/badge_model.dart';
import '../services/badge_service.dart';

class BadgeCollectionScreen extends StatefulWidget {
  const BadgeCollectionScreen({super.key});

  @override
  State<BadgeCollectionScreen> createState() => _BadgeCollectionScreenState();
}

class _BadgeCollectionScreenState extends State<BadgeCollectionScreen>
    with TickerProviderStateMixin {
  final _db = FirebaseFirestore.instance;
  final _uid = FirebaseAuth.instance.currentUser?.uid;
  String? _equippedBadgeId;
  List<String> _earnedIds = [];
  Map<String, double> _progress = {};
  bool _loading = true;
  late AnimationController _treeController;
  late Animation<double> _treeAnimation;

  @override
  void initState() {
    super.initState();
    _treeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _treeAnimation = CurvedAnimation(
      parent: _treeController,
      curve: Curves.easeOutCubic,
    );
    _load();
  }

  @override
  void dispose() {
    _treeController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final earned = await BadgeService.getEarnedBadgeIds();
    final equipped = await BadgeService.getEquippedBadgeId();
    if (_uid == null) return;
    final doc = await _db.collection('users').doc(_uid).get();
    final data = doc.data() ?? {};
    final totalKm = ((data['totalKm'] ?? 0.0) as num).toDouble();
    final totalDonation = (data['totalDonation'] ?? 0) as int;
    final totalRuns = (data['totalRuns'] ?? 0) as int;
    final consecutiveDays = (data['consecutiveDays'] ?? 0) as int;
    final nightRuns = (data['nightRuns'] ?? 0) as int;
    final earlyRuns = (data['earlyRuns'] ?? 0) as int;
    final completedChallenges = (data['completedChallenges'] ?? 0) as int;
    final progress = await BadgeService.getBadgeProgress(
      totalKm: totalKm,
      totalDonation: totalDonation,
      totalRuns: totalRuns,
      consecutiveDays: consecutiveDays,
      nightRuns: nightRuns,
      earlyRuns: earlyRuns,
      completedChallenges: completedChallenges,
    );
    setState(() {
      _earnedIds = earned;
      _equippedBadgeId = equipped;
      _progress = progress;
      _loading = false;
    });
    _treeController.forward();
  }

  Future<void> _equip(String badgeId) async {
    if (_equippedBadgeId == badgeId) {
      await BadgeService.unequipBadge();
      setState(() => _equippedBadgeId = null);
    } else {
      await BadgeService.equipBadge(badgeId);
      setState(() => _equippedBadgeId = badgeId);
    }
  }

  void _showDetail(BadgeModel badge) {
    final earned = _earnedIds.contains(badge.id);
    final progress = _progress[badge.id] ?? 0.0;
    final rarityColor = BadgeData.rarityColor(badge.rarity);

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111827),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF1E2535),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: earned
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          rarityColor.withValues(alpha: 0.9),
                          rarityColor.withValues(alpha: 0.4),
                        ],
                      )
                    : null,
                color: earned ? null : const Color(0xFF1E2535),
                border: Border.all(
                  color: earned ? rarityColor : const Color(0xFF2D3748),
                  width: 2,
                ),
                boxShadow: earned
                    ? [
                        BoxShadow(
                          color: rarityColor.withValues(alpha: 0.3),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  earned ? badge.nameEn[0] : '?',
                  style: TextStyle(
                    color: earned ? Colors.white : const Color(0xFF4A5568),
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: rarityColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    BadgeData.rarityName(badge.rarity),
                    style: TextStyle(
                      color: rarityColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (badge.hidden) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFB300).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Hidden',
                      style: TextStyle(
                        color: Color(0xFFFFB300),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 10),
            Text(
              earned ? badge.name : (badge.hidden ? '???' : badge.name),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              earned
                  ? badge.desc
                  : (badge.hidden
                        ? AppLanguage.t(
                            en: 'Keep running to unlock!',
                            ko: '계속 달리면 열려요!',
                            ja: '走り続けると解放！',
                            es: '¡Sigue corriendo!',
                            zh: '继续跑步解锁！',
                          )
                        : badge.desc),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF8899AA),
                fontSize: 14,
                height: 1.5,
              ),
            ),
            if (!earned) ...[
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: const Color(0xFF1E2535),
                  valueColor: AlwaysStoppedAnimation<Color>(rarityColor),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  color: rarityColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            if (earned) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _equip(badge.id);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _equippedBadgeId == badge.id
                        ? const Color(0xFF1E2535)
                        : const Color(0xFF00C896),
                    foregroundColor: _equippedBadgeId == badge.id
                        ? const Color(0xFF8899AA)
                        : const Color(0xFF0A0E1A),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    _equippedBadgeId == badge.id
                        ? AppLanguage.t(
                            en: 'Unequip',
                            ko: '해제하기',
                            ja: '外す',
                            es: 'Desequipar',
                            zh: '卸下',
                          )
                        : AppLanguage.t(
                            en: 'Equip',
                            ko: '장착하기',
                            ja: '装備する',
                            es: 'Equipar',
                            zh: '装备',
                          ),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A0E1A),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF00C896)),
        ),
      );
    }

    final total = BadgeData.all.length;
    final earned = _earnedIds.length;
    final unearnedBadges = BadgeData.all
        .where((b) => !_earnedIds.contains(b.id))
        .toList();
    final earnedBadges = BadgeData.all
        .where((b) => _earnedIds.contains(b.id))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      AppLanguage.t(
                        en: 'My Badges',
                        ko: '내 배지',
                        ja: 'マイバッジ',
                        es: 'Mis Insignias',
                        zh: '我的徽章',
                      ),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '$earned / $total',
                      style: const TextStyle(
                        color: Color(0xFF00C896),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              AnimatedBuilder(
                animation: _treeAnimation,
                builder: (context, child) => _TreeWidget(
                  earnedCount: earned,
                  total: total,
                  progress: _treeAnimation.value,
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  _treeStageText(earned, total),
                  style: const TextStyle(
                    color: Color(0xFF8899AA),
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              if (earnedBadges.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    AppLanguage.t(
                      en: 'Earned',
                      ko: '획득한 배지',
                      ja: '獲得済み',
                      es: 'Obtenidas',
                      zh: '已获得',
                    ),
                    style: const TextStyle(
                      color: Color(0xB3FFFFFF),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 100,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: earnedBadges.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, i) {
                      final badge = earnedBadges[i];
                      final rarityColor = BadgeData.rarityColor(badge.rarity);
                      return GestureDetector(
                        onTap: () => _showDetail(badge),
                        child: Container(
                          width: 80,
                          decoration: BoxDecoration(
                            color: const Color(0xFF141824),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: _equippedBadgeId == badge.id
                                  ? const Color(0xFF00C896)
                                  : rarityColor.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 42,
                                      height: 42,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            rarityColor.withValues(alpha: 0.9),
                                            rarityColor.withValues(alpha: 0.4),
                                          ],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: rarityColor.withValues(
                                              alpha: 0.3,
                                            ),
                                            blurRadius: 8,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          badge.nameEn[0],
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      width: 8,
                                      height: 3,
                                      decoration: BoxDecoration(
                                        color: rarityColor,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (_equippedBadgeId == badge.id)
                                Positioned(
                                  top: 6,
                                  right: 6,
                                  child: Container(
                                    width: 7,
                                    height: 7,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFF00C896),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 28),
              ],
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  AppLanguage.t(
                    en: 'Locked',
                    ko: '잠긴 배지',
                    ja: 'ロック済み',
                    es: 'Bloqueadas',
                    zh: '未解锁',
                  ),
                  style: const TextStyle(
                    color: Color(0xB3FFFFFF),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: unearnedBadges.length,
                itemBuilder: (context, i) {
                  final badge = unearnedBadges[i];
                  final rarityColor = BadgeData.rarityColor(badge.rarity);
                  final prog = _progress[badge.id] ?? 0.0;
                  return GestureDetector(
                    onTap: () => _showDetail(badge),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF141824),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF1E2535)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF1E2535),
                            ),
                            child: Center(
                              child: Text(
                                badge.hidden ? '?' : badge.nameEn[0],
                                style: const TextStyle(
                                  color: Color(0xFF4A5568),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          if (prog > 0) ...[
                            const SizedBox(height: 6),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(2),
                                child: LinearProgressIndicator(
                                  value: prog,
                                  backgroundColor: const Color(0xFF1E2535),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    rarityColor,
                                  ),
                                  minHeight: 3,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  String _treeStageText(int earned, int total) {
    final ratio = total == 0 ? 0.0 : earned / total;
    if (ratio == 0)
      return AppLanguage.t(
        en: 'Earn your first badge to plant a seed',
        ko: '첫 배지를 얻어 씨앗을 심어요',
        ja: '最初のバッジで種を植えよう',
        es: 'Gana tu primera insignia',
        zh: '获得第一个徽章种下种子',
      );
    if (ratio < 0.2)
      return AppLanguage.t(
        en: 'A sprout is growing...',
        ko: '새싹이 자라고 있어요...',
        ja: '芽が育っています...',
        es: 'Un brote está creciendo...',
        zh: '小芽正在生长...',
      );
    if (ratio < 0.4)
      return AppLanguage.t(
        en: 'Leaves are appearing!',
        ko: '잎이 돋아나고 있어요!',
        ja: '葉っぱが出てきました！',
        es: '¡Aparecen las hojas!',
        zh: '叶子出现了！',
      );
    if (ratio < 0.6)
      return AppLanguage.t(
        en: 'Your tree is growing strong',
        ko: '나무가 튼튼하게 자라고 있어요',
        ja: '木がしっかり育っています',
        es: 'Tu árbol crece fuerte',
        zh: '你的树在茁壮成长',
      );
    if (ratio < 0.8)
      return AppLanguage.t(
        en: 'Flowers are blooming!',
        ko: '꽃이 피어나고 있어요!',
        ja: '花が咲いています！',
        es: '¡Las flores están floreciendo!',
        zh: '花朵盛开了！',
      );
    if (ratio < 1.0)
      return AppLanguage.t(
        en: 'Almost there! Fruits are forming',
        ko: '거의 다 왔어요! 열매가 맺히고 있어요',
        ja: 'もうすぐ！実がなっています',
        es: '¡Casi! Se forman los frutos',
        zh: '快到了！果实正在形成',
      );
    return AppLanguage.t(
      en: 'A magnificent tree! All badges earned!',
      ko: '멋진 나무 완성! 모든 배지 획득!',
      ja: '見事な木！全バッジ獲得！',
      es: '¡Árbol magnífico!',
      zh: '壮观的树！所有徽章已获得！',
    );
  }
}

class _TreeWidget extends StatelessWidget {
  const _TreeWidget({
    required this.earnedCount,
    required this.total,
    required this.progress,
  });
  final int earnedCount;
  final int total;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final ratio = total == 0 ? 0.0 : earnedCount / total;
    return SizedBox(
      height: 220,
      child: CustomPaint(painter: _TreePainter(ratio: ratio * progress)),
    );
  }
}

class _TreePainter extends CustomPainter {
  final double ratio;
  const _TreePainter({required this.ratio});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final groundY = size.height - 20;
    final trunkPaint = Paint()
      ..color = const Color(0xFF5C3D1E)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final trunkHeight = 60.0 + (ratio * 40);
    canvas.drawLine(
      Offset(cx, groundY),
      Offset(cx, groundY - trunkHeight),
      trunkPaint,
    );
    if (ratio <= 0) return;
    final branchPaint = Paint()
      ..color = const Color(0xFF5C3D1E)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    if (ratio > 0.05) {
      canvas.drawLine(
        Offset(cx, groundY - trunkHeight * 0.6),
        Offset(cx - 30, groundY - trunkHeight * 0.9),
        branchPaint,
      );
      canvas.drawLine(
        Offset(cx, groundY - trunkHeight * 0.6),
        Offset(cx + 30, groundY - trunkHeight * 0.9),
        branchPaint,
      );
    }
    if (ratio > 0.2) {
      canvas.drawLine(
        Offset(cx, groundY - trunkHeight * 0.4),
        Offset(cx - 45, groundY - trunkHeight * 0.65),
        branchPaint,
      );
      canvas.drawLine(
        Offset(cx, groundY - trunkHeight * 0.4),
        Offset(cx + 45, groundY - trunkHeight * 0.65),
        branchPaint,
      );
    }
    final leafPaint = Paint()
      ..color = const Color(0xFF00C896).withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;
    final flowerPaint = Paint()
      ..color = const Color(0xFFFF6B9D).withValues(alpha: 0.9)
      ..style = PaintingStyle.fill;
    final fruitPaint = Paint()
      ..color = const Color(0xFFFF6B6B).withValues(alpha: 0.9)
      ..style = PaintingStyle.fill;
    final leafPositions = [
      Offset(cx, groundY - trunkHeight - 10),
      Offset(cx - 30, groundY - trunkHeight * 0.9 - 8),
      Offset(cx + 30, groundY - trunkHeight * 0.9 - 8),
      Offset(cx - 45, groundY - trunkHeight * 0.65 - 8),
      Offset(cx + 45, groundY - trunkHeight * 0.65 - 8),
      Offset(cx - 15, groundY - trunkHeight * 0.75),
      Offset(cx + 15, groundY - trunkHeight * 0.75),
      Offset(cx - 25, groundY - trunkHeight * 0.5),
      Offset(cx + 25, groundY - trunkHeight * 0.5),
    ];
    final leafCount = (ratio * leafPositions.length).ceil().clamp(
      0,
      leafPositions.length,
    );
    for (int i = 0; i < leafCount; i++) {
      final pos = leafPositions[i];
      final isFlower = ratio > 0.6 && i % 3 == 1;
      final isFruit = ratio > 0.8 && i % 4 == 0;
      final paint = isFruit ? fruitPaint : (isFlower ? flowerPaint : leafPaint);
      final radius = isFruit ? 7.0 : (isFlower ? 6.0 : 16.0);
      if (!isFruit && !isFlower) {
        final path = Path();
        path.moveTo(pos.dx, pos.dy - radius);
        path.quadraticBezierTo(
          pos.dx + radius * 0.8,
          pos.dy - radius * 0.4,
          pos.dx,
          pos.dy + radius * 0.5,
        );
        path.quadraticBezierTo(
          pos.dx - radius * 0.8,
          pos.dy - radius * 0.4,
          pos.dx,
          pos.dy - radius,
        );
        canvas.drawPath(path, paint);
      } else {
        canvas.drawCircle(pos, radius, paint);
      }
    }
    if (ratio > 0.1) {
      final glowPaint = Paint()
        ..color = const Color(0xFF00C896).withValues(alpha: 0.08)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(cx, groundY - trunkHeight - 5),
        55 * ratio,
        glowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_TreePainter old) => old.ratio != ratio;
}
