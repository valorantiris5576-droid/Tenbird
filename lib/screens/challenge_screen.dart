import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

class ChallengeItem {
  final String id;
  final String title;
  final String description;
  final String goal;
  final String reward;
  double progress;
  double current;
  final double total;
  final int daysLeft;
  final Color color;

  ChallengeItem({
    required this.id,
    required this.title,
    required this.description,
    required this.goal,
    required this.reward,
    this.progress = 0.0,
    this.current = 0.0,
    required this.total,
    required this.daysLeft,
    required this.color,
  });

  String get totalString =>
      total.toInt() == total ? '${total.toInt()} ' : '$total ';
  String get currentString =>
      current.toInt() == current ? '${current.toInt()}' : '$current';
}

class ChallengeScreen extends StatefulWidget {
  const ChallengeScreen({super.key});

  @override
  State<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen> {
  late ConfettiController _confettiController;

  final List<ChallengeItem> _allChallenges = [
    ChallengeItem(
      id: '1',
      title: '폭염 이겨내기 챌린지',
      goal: '2주간 30km 달리기',
      description: '더위에 지지 않고 꾸준히 달려보자. 여름철 운동 습관을 만들고, 달린 거리만큼 기부도 쌓인다.',
      reward: '+300원 추가 기부 및 폭염 극복 뱃지',
      total: 30.0,
      daysLeft: 14,
      color: const Color(0xFFFF6B6B),
    ),
    ChallengeItem(
      id: '2',
      title: '선셋 러닝 챌린지',
      goal: '일몰 시간대 러닝 5회 인증',
      description: '가장 아름다운 러닝 타임. 붉게 물든 하늘 아래 달리며 여름 저녁을 즐겨보자.',
      reward: '+150원 추가 기부 및 노을 러너 뱃지',
      total: 5.0,
      daysLeft: 14,
      color: const Color(0xFFFF8E53),
    ),
    ChallengeItem(
      id: '3',
      title: '미라클 챌린지',
      goal: '오전 7시 이전 러닝 7회 달성',
      description: '하루를 남들보다 먼저 시작하는 사람들의 챌린지. 아침 러닝으로 생산적인 하루를 만들어보자.',
      reward: '+200원 추가 기부 및 미라클 모닝 뱃지',
      total: 7.0,
      daysLeft: 7,
      color: const Color(0xFFFEE140),
    ),
    ChallengeItem(
      id: '4',
      title: 'GOD생 챌린지',
      goal: '7일 연속 러닝 및 누적 10km',
      description: '작심삼일은 끝. 일주일 동안 꾸준히 달리며 건강한 루틴을 만들어보자.',
      reward: '+250원 추가 기부 및 갓생러 뱃지',
      total: 10.0,
      daysLeft: 7,
      color: const Color(0xFF00C896),
    ),
    ChallengeItem(
      id: '5',
      title: '수박 한 통 챌린지',
      goal: '누적 20km 달성',
      description: '여름 대표 과일 수박 한 통 칼로리를 태운다는 컨셉. 시원한 성취감을 느껴보자.',
      reward: '+200원 추가 기부 및 수박 뱃지',
      total: 20.0,
      daysLeft: 14,
      color: const Color(0xFF4E9F3D),
    ),
    ChallengeItem(
      id: '6',
      title: '에어컨 off 챌린지',
      goal: '하루 1시간 에어컨 끄고 플로깅',
      description: '지구를 시원하게! 에어컨을 잠시 끄고 동네를 가볍게 달리며 쓰레기를 줍는 환경 보호 챌린지.',
      reward: '+300원 추가 기부 및 에코 러너 뱃지',
      total: 7.0,
      daysLeft: 7,
      color: const Color(0xFF00D2FC),
    ),
    ChallengeItem(
      id: '7',
      title: '바다 가기 전 챌린지',
      goal: '누적 30km 달성하기',
      description: '여름 휴가, 바다로 떠나기 전 탄탄한 기초 체력을 다져보는 본격 러닝 프로젝트.',
      reward: '+500원 추가 기부 및 오션 챌린저 뱃지',
      total: 30.0,
      daysLeft: 14,
      color: const Color(0xFFFF416C),
    ),
    ChallengeItem(
      id: '8',
      title: '썬크림 러너 챌린지',
      goal: '낮 시간대 러닝 3회 인증',
      description: '뜨거운 태양도 막을 수 없다! 자외선 차단제 단단히 바르고 여름의 에너지를 마주하는 도전.',
      reward: '+200원 추가 기부 및 태양을 피하는 방법 뱃지',
      total: 3.0,
      daysLeft: 10,
      color: const Color(0xFFFFB300),
    ),
    ChallengeItem(
      id: '9',
      title: '열대야 탈출 챌린지',
      goal: '밤 9시 이후 야간 러닝 5회 인증',
      description: '잠 못 드는 여름 밤, 시원한 밤바람을 맞으며 하루의 스트레스를 날려버리는 야간 시티런.',
      reward: '+250원 추가 기부 및 미드나잇 러너 뱃지',
      total: 5.0,
      daysLeft: 14,
      color: const Color(0xFF8A2387),
    ),
    ChallengeItem(
      id: '10',
      title: '기부 마라톤 챌린지',
      goal: '2주간 누적 42.195km 달성',
      description: '여름의 한계를 뛰어넘는 도전! 마라톤 풀코스 거리를 완주하고 도움이 필요한 곳에 따뜻한 마음을 전하세요.',
      reward: '+1000원 추가 기부 및 여름 마라토너 뱃지',
      total: 42.195,
      daysLeft: 14,
      color: const Color(0xFF11998E),
    ),
    ChallengeItem(
      id: '11',
      title: '7979 친구 챌린지',
      goal: '친구와 합산 79.79km 달성',
      description:
          '친구와 함께 달리자. 혼자보단 둘이 함께 달리면 더 멀리 갈 수 있다. 친구와 79.79km 달성후 같이 보상 받자.',
      reward: '+500원 추가 기부 및 우정 러너 뱃지',
      total: 79.79,
      daysLeft: 30,
      color: const Color(0xFF7C3AED),
    ),
  ];

  final Set<String> _joinedIds = {};
  final List<String> _completedChallenges = [];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _show(ChallengeItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111827),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          builder: (context, scrollController) {
            return StatefulBuilder(
              builder: (context, setModalState) {
                final has = _joinedIds.contains(item.id);
                final isFull = _joinedIds.length >= 3;

                return SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E2535),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          item.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: item.color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '목표: ${item.goal}',
                            style: TextStyle(
                              color: item.color,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          '챌린지 설명',
                          style: TextStyle(
                            color: Color(0xFF8899AA),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.description,
                          style: const TextStyle(
                            color: Color(0xFFE5E7EB),
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          '달성 보상',
                          style: TextStyle(
                            color: Color(0xFF8899AA),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.reward,
                          style: const TextStyle(
                            color: Color(0xFF00C896),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (!has && isFull)
                          const Padding(
                            padding: EdgeInsets.only(bottom: 12),
                            child: Center(
                              child: Text(
                                '챌린지는 동시에 최대 3개까지만 도전할 수 있습니다.',
                                style: TextStyle(
                                  color: Color(0xFFFF6B6B),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: has
                                  ? const Color(0xFFEF4444)
                                  : (isFull
                                        ? const Color(0xFF374151)
                                        : const Color(0xFF00C896)),
                              disabledBackgroundColor: const Color(0xFF1F2937),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            onPressed: (!has && isFull)
                                ? null
                                : () {
                                    setState(() {
                                      if (has) {
                                        _joinedIds.remove(item.id);
                                        item.current = 0.0;
                                        item.progress = 0.0;
                                      } else {
                                        _joinedIds.add(item.id);
                                      }
                                    });
                                    Navigator.pop(context);
                                  },
                            child: Text(
                              has ? '챌린지 포기하기' : '이 챌린지 도전하기',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: has
                                    ? Colors.white
                                    : ((!has && isFull)
                                          ? const Color(0xFF6B7280)
                                          : const Color(0xFF0A0E1A)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final joined = _allChallenges
        .where((c) => _joinedIds.contains(c.id))
        .toList();
    final available = _allChallenges
        .where((c) => !_joinedIds.contains(c.id))
        .toList();

    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFF0A0E1A),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '챌린지',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '진행 중인 챌린지 (${joined.length}/3)',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (joined.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFF111827),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        '현재 도전 중인 챌린지가 없습니다.\n아래에서 마음에 드는 챌린지를 선택해 보세요.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF8899AA),
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: joined.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = joined[index];
                        return _ChallengeCard(
                          challenge: item,
                          onTap: () => _show(item),
                        );
                      },
                    ),
                  const SizedBox(height: 28),
                  const Text(
                    '여름을 시원하게 날려줄 챌린지',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: available.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = available[index];
                      return InkWell(
                        onTap: () => _show(item),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF111827),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.04),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.title,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item.goal,
                                      style: TextStyle(
                                        color: item.color,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios,
                                color: Color(0xFF4A5568),
                                size: 14,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    '완료한 챌린지',
                    style: TextStyle(
                      color: Color(0xB3FFFFFF),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _completedChallenges
                        .map((label) => _Badge(label))
                        .toList(),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            maxBlastForce: 15,
            minBlastForce: 5,
            emissionFrequency: 0.05,
            numberOfParticles: 30,
            gravity: 0.1,
          ),
        ),
      ],
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  const _ChallengeCard({required this.challenge, required this.onTap});

  final ChallengeItem challenge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final String unit =
        (challenge.title.contains('회') || challenge.goal.contains('회'))
        ? '회'
        : 'km';

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: challenge.color,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${challenge.totalString}$unit',
                        style: const TextStyle(
                          color: Color(0xFF0A0E1A),
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${challenge.daysLeft}일 남음',
                        style: TextStyle(
                          color: const Color(0xFF0A0E1A).withValues(alpha: 0.7),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    challenge.title,
                    style: const TextStyle(
                      color: Color(0xFF0A0E1A),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
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
                    Text(
                      '${challenge.currentString} / ${challenge.totalString}',
                      style: TextStyle(
                        color: challenge.color,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${(challenge.progress * 100).toInt()}%',
                      style: const TextStyle(
                        color: Color(0xFF8899AA),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: challenge.progress,
                    backgroundColor: const Color(0xFF1E2535),
                    valueColor: AlwaysStoppedAnimation<Color>(challenge.color),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '보상: ${challenge.reward}',
                  style: const TextStyle(
                    color: Color(0xFF8899AA),
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
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
        border: Border.all(
          color: const Color(0xFF00C896).withValues(alpha: 0.4),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF00C896),
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
