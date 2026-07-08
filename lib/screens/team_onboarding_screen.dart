import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confetti/confetti.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app_language.dart';

class TeamOnboardingScreen extends StatefulWidget {
  const TeamOnboardingScreen({super.key});

  @override
  State<TeamOnboardingScreen> createState() => _TeamOnboardingScreenState();
}

class _TeamOnboardingScreenState extends State<TeamOnboardingScreen> {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;
  final _pageController = PageController();
  final _nameController = TextEditingController();
  final _searchController = TextEditingController();

  int _step = 0;
  bool _creating = false;
  String? _teamId;
  String? _teamName;
  String? _inviteCode;
  final Set<String> _invitedUserIds = {};
  final Set<String> _invitedUsernames = {};

  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 4),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _searchController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  String _generateInviteCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rand = Random();
    return List.generate(6, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  void _goToStep(int step) {
    setState(() => _step = step);
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
    );
  }

  Future<void> _createTeamAndContinue() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    final user = _auth.currentUser;
    if (user == null || user.isAnonymous) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLanguage.t(
              en: 'Sign in to create a team.',
              ko: '로그인 후 팀을 만들 수 있어요.',
              ja: 'チームを作るにはログインが必要です。',
              es: 'Inicia sesión para crear un equipo.',
              zh: '请登录后创建团队。',
            ),
          ),
        ),
      );
      return;
    }
    setState(() => _creating = true);
    try {
      final code = _generateInviteCode();
      final teamRef = await _db.collection('teams').add({
        'name': name,
        'createdBy': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'totalKm': 0.0,
        'totalDonation': 0,
        'memberCount': 1,
        'inviteCode': code,
      });
      await teamRef.collection('members').doc(user.uid).set({
        'joinedAt': FieldValue.serverTimestamp(),
      });
      await _db.collection('users').doc(user.uid).set({
        'teamId': teamRef.id,
        'teamName': name,
      }, SetOptions(merge: true));
      if (!mounted) return;
      setState(() {
        _teamId = teamRef.id;
        _teamName = name;
        _inviteCode = code;
        _creating = false;
      });
      _goToStep(1);
    } catch (_) {
      if (mounted) {
        setState(() => _creating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLanguage.t(
                en: 'Could not create team.',
                ko: '팀을 만들지 못했어요.',
                ja: 'チームを作成できませんでした。',
                es: 'No se pudo crear el equipo.',
                zh: '无法创建团队。',
              ),
            ),
          ),
        );
      }
    }
  }

  Future<void> _copyInviteMessage() async {
    if (_inviteCode == null || _teamName == null) return;
    final message = AppLanguage.t(
      en: 'Join my StepGive team "$_teamName"! Code: $_inviteCode',
      ko: 'StepGive 팀 "$_teamName"에 참가해요! 코드: $_inviteCode',
      ja: 'StepGiveチーム「$_teamName」に参加！コード: $_inviteCode',
      es: '¡Únete a mi equipo "$_teamName"! Código: $_inviteCode',
      zh: '加入我的团队 "$_teamName"！代码: $_inviteCode',
    );
    await Clipboard.setData(ClipboardData(text: message));
    if (mounted)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLanguage.t(
              en: 'Copied!',
              ko: '복사됐어요!',
              ja: 'コピーしました！',
              es: '¡Copiado!',
              zh: '已复制！',
            ),
          ),
        ),
      );
  }

  Future<void> _inviteUser(String friendUid, String username) async {
    if (_teamId == null || _invitedUserIds.contains(friendUid)) return;
    final uid = _auth.currentUser?.uid;
    if (uid == null || friendUid == uid) return;
    await _db
        .collection('users')
        .doc(friendUid)
        .collection('teamInvites')
        .doc(_teamId)
        .set({
          'teamId': _teamId,
          'teamName': _teamName,
          'inviteCode': _inviteCode,
          'invitedBy': uid,
          'invitedAt': FieldValue.serverTimestamp(),
        });
    setState(() {
      _invitedUserIds.add(friendUid);
      _invitedUsernames.add(username);
    });
    if (mounted)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLanguage.t(
              en: 'Invited $username!',
              ko: '$username님께 초대를 보냈어요!',
              ja: '$usernameさんに招待を送りました！',
              es: '¡Invitación enviada a $username!',
              zh: '已向 $username 发送邀请！',
            ),
          ),
        ),
      );
  }

  Future<void> _searchAndInvite() async {
    final username = _searchController.text.trim();
    if (username.isEmpty) return;
    final uid = _auth.currentUser?.uid;
    final result = await _db
        .collection('users')
        .where('username', isEqualTo: username)
        .limit(1)
        .get();
    if (!mounted) return;
    if (result.docs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLanguage.t(
              en: 'User not found.',
              ko: '유저를 찾을 수 없어요.',
              ja: 'ユーザーが見つかりません。',
              es: 'Usuario no encontrado.',
              zh: '找不到用户。',
            ),
          ),
        ),
      );
      return;
    }
    final friendUid = result.docs.first.id;
    if (friendUid == uid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLanguage.t(
              en: 'You can\'t invite yourself!',
              ko: '자기 자신은 초대할 수 없어요!',
              ja: '自分自身は招待できません！',
              es: '¡No puedes invitarte!',
              zh: '不能邀请自己！',
            ),
          ),
        ),
      );
      return;
    }
    await _inviteUser(friendUid, username);
    _searchController.clear();
  }

  void _finishOnboarding() {
    _goToStep(2);
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _confettiController.play();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildTopBar(),
                _buildProgressBar(),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (i) => setState(() => _step = i),
                    children: [
                      _buildNameStep(),
                      _buildInviteStep(),
                      _buildCompleteStep(),
                    ],
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  Color(0xFF00C896),
                  Color(0xFF4DFFCC),
                  Colors.white,
                ],
                numberOfParticles: 28,
                maxBlastForce: 28,
                minBlastForce: 12,
                gravity: 0.12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => _step == 0 || _step == 2
                ? Navigator.pop(context)
                : _goToStep(0),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: List.generate(3, (i) {
          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
              decoration: BoxDecoration(
                color: i <= _step
                    ? const Color(0xFF00C896)
                    : const Color(0xFF1E2535),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildNameStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF00C896).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.groups_outlined,
              color: Color(0xFF00C896),
              size: 28,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            AppLanguage.t(
              en: 'What\'s your team name?',
              ko: '팀 이름이 뭐예요?',
              ja: 'チーム名は？',
              es: '¿Cómo se llama tu equipo?',
              zh: '团队叫什么名字？',
            ),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            AppLanguage.t(
              en: 'Pick a name your teammates will recognize.',
              ko: '팀원들이 바로 알아볼 수 있는 이름으로 정해요.',
              ja: 'メンバーがすぐわかる名前を選びましょう。',
              es: 'Elige un nombre que tus compañeros reconozcan.',
              zh: '选一个队友一眼就能认出的名字。',
            ),
            style: const TextStyle(
              color: Color(0xFF8899AA),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _nameController,
            autofocus: true,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) {
              if (!_creating) _createTeamAndContinue();
            },
            decoration: InputDecoration(
              hintText: AppLanguage.t(
                en: 'e.g. Morning Runners',
                ko: '예: 새벽 러너즈',
                ja: '例: モーニングランナーズ',
                es: 'ej. Corredores del Alba',
                zh: '例如：晨跑小队',
              ),
              hintStyle: const TextStyle(
                color: Color(0xFF4A5568),
                fontWeight: FontWeight.normal,
              ),
              filled: true,
              fillColor: const Color(0xFF141824),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFF1E2535)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFF00C896),
                  width: 1.5,
                ),
              ),
            ),
          ),
          const Spacer(),
          _primaryButton(
            label: AppLanguage.t(
              en: 'Continue',
              ko: '다음',
              ja: '次へ',
              es: 'Continuar',
              zh: '继续',
            ),
            onPressed: _creating ? null : _createTeamAndContinue,
            loading: _creating,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildInviteStep() {
    final uid = _auth.currentUser?.uid;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF00C896).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.person_add_outlined,
              color: Color(0xFF00C896),
              size: 28,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            AppLanguage.t(
              en: 'Invite your teammates!',
              ko: '팀원을 초대해요!',
              ja: 'チームメンバーを招待！',
              es: '¡Invita a tu equipo!',
              zh: '邀请队友吧！',
            ),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            AppLanguage.t(
              en: 'Share your code or invite friends directly.',
              ko: '코드를 공유하거나 친구를 직접 초대해요.',
              ja: 'コードを共有するか、友達を直接招待しましょう。',
              es: 'Comparte tu código o invita amigos directamente.',
              zh: '分享邀请码或直接邀请好友。',
            ),
            style: const TextStyle(
              color: Color(0xFF8899AA),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF111827),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF00C896).withValues(alpha: 0.25),
              ),
            ),
            child: Column(
              children: [
                Text(
                  AppLanguage.t(
                    en: 'Team invite code',
                    ko: '팀 초대 코드',
                    ja: '招待コード',
                    es: 'Código de invitación',
                    zh: '团队邀请码',
                  ),
                  style: const TextStyle(
                    color: Color(0xFF8899AA),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _inviteCode ?? '------',
                  style: const TextStyle(
                    color: Color(0xFF00C896),
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _shareButton(
                  icon: Icons.email_outlined,
                  label: AppLanguage.t(
                    en: 'Email',
                    ko: '이메일',
                    ja: 'メール',
                    es: 'Email',
                    zh: '邮件',
                  ),
                  onTap: _copyInviteMessage,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _shareButton(
                  icon: Icons.chat_bubble_outline,
                  label: AppLanguage.t(
                    en: 'KakaoTalk',
                    ko: '카카오톡',
                    ja: 'カカオトーク',
                    es: 'KakaoTalk',
                    zh: 'KakaoTalk',
                  ),
                  onTap: _copyInviteMessage,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Text(
            AppLanguage.t(
              en: 'Invite friends directly',
              ko: '친구 직접 초대',
              ja: '友達を直接招待',
              es: 'Invitar amigos directamente',
              zh: '直接邀请好友',
            ),
            style: const TextStyle(
              color: Color(0xB3FFFFFF),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: AppLanguage.t(
                      en: 'Search username',
                      ko: '유저네임 검색',
                      ja: 'ユーザー名検索',
                      es: 'Buscar usuario',
                      zh: '搜索用户名',
                    ),
                    hintStyle: const TextStyle(color: Color(0xFF4A5568)),
                    filled: true,
                    fillColor: const Color(0xFF141824),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFF8899AA),
                      size: 20,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
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
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _searchAndInvite,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C896),
                    foregroundColor: const Color(0xFF0A0E1A),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    AppLanguage.t(
                      en: 'Invite',
                      ko: '초대',
                      ja: '招待',
                      es: 'Invitar',
                      zh: '邀请',
                    ),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (uid != null)
            StreamBuilder<QuerySnapshot>(
              stream: _db
                  .collection('users')
                  .doc(uid)
                  .collection('friends')
                  .snapshots(),
              builder: (context, snap) {
                if (!snap.hasData || snap.data!.docs.isEmpty)
                  return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLanguage.t(
                        en: 'Your friends',
                        ko: '내 친구',
                        ja: '友達',
                        es: 'Tus amigos',
                        zh: '我的好友',
                      ),
                      style: const TextStyle(
                        color: Color(0xFF8899AA),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...snap.data!.docs.map((doc) {
                      return StreamBuilder<DocumentSnapshot>(
                        stream: _db.collection('users').doc(doc.id).snapshots(),
                        builder: (context, userSnap) {
                          final data = userSnap.data?.data() as Map?;
                          final username =
                              data?['username'] as String? ?? 'Runner';
                          final invited = _invitedUserIds.contains(doc.id);
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF141824),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF1E2535),
                              ),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: const Color(
                                    0xFF00C896,
                                  ).withValues(alpha: 0.15),
                                  child: Text(
                                    username.isNotEmpty
                                        ? username[0].toUpperCase()
                                        : 'R',
                                    style: const TextStyle(
                                      color: Color(0xFF00C896),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    username,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                invited
                                    ? Text(
                                        AppLanguage.t(
                                          en: 'Sent',
                                          ko: '전송됨',
                                          ja: '送信済',
                                          es: 'Enviado',
                                          zh: '已发送',
                                        ),
                                        style: const TextStyle(
                                          color: Color(0xFF8899AA),
                                          fontSize: 12,
                                        ),
                                      )
                                    : TextButton(
                                        onPressed: () =>
                                            _inviteUser(doc.id, username),
                                        child: Text(
                                          AppLanguage.t(
                                            en: 'Invite',
                                            ko: '초대',
                                            ja: '招待',
                                            es: 'Invitar',
                                            zh: '邀请',
                                          ),
                                          style: const TextStyle(
                                            color: Color(0xFF00C896),
                                          ),
                                        ),
                                      ),
                              ],
                            ),
                          );
                        },
                      );
                    }),
                  ],
                );
              },
            ),
          if (_invitedUsernames.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _invitedUsernames
                  .map(
                    (name) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00C896).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF00C896).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        name,
                        style: const TextStyle(
                          color: Color(0xFF00C896),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
          const SizedBox(height: 24),
          if (_invitedUserIds.length < 2)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                AppLanguage.t(
                  en: 'Invite at least 2 more members to finish',
                  ko: '최소 2명을 더 초대해야 완료할 수 있어요',
                  ja: 'あと2人以上招待してください',
                  es: 'Invita al menos 2 miembros más',
                  zh: '至少再邀请2名成员',
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF8899AA), fontSize: 12),
              ),
            ),
          _primaryButton(
            label: AppLanguage.t(
              en: 'Finish',
              ko: '완료',
              ja: '完了',
              es: 'Finalizar',
              zh: '完成',
            ),
            onPressed: _invitedUserIds.length >= 2 ? _finishOnboarding : null,
          ),
        ],
      ),
    );
  }

  Widget _buildCompleteStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const Spacer(flex: 2),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF00C896).withValues(alpha: 0.15),
              border: Border.all(color: const Color(0xFF00C896), width: 2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00C896).withValues(alpha: 0.25),
                  blurRadius: 32,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: const Icon(
              Icons.emoji_events_outlined,
              color: Color(0xFF00C896),
              size: 48,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            AppLanguage.t(
              en: 'Team created!',
              ko: '팀 창단 완료!',
              ja: 'チーム設立完了！',
              es: '¡Equipo creado!',
              zh: '团队创建完成！',
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '"$_teamName"',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF00C896),
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            AppLanguage.t(
              en: 'Run together, donate together.\nYour team journey starts now!',
              ko: '함께 달리고, 함께 기부해요.\n이제 팀 러닝을 시작해 볼까요?',
              ja: '一緒に走って、一緒に寄付。\nチームランを始めましょう！',
              es: 'Corran juntos, donen juntos.\n¡Comienza la aventura en equipo!',
              zh: '一起跑步，一起捐赠。\n现在开始团队之旅吧！',
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF8899AA),
              fontSize: 14,
              height: 1.6,
            ),
          ),
          const Spacer(flex: 3),
          _primaryButton(
            label: AppLanguage.t(
              en: 'Let\'s go!',
              ko: '시작하기',
              ja: '始めよう！',
              es: '¡Vamos!',
              zh: '开始吧！',
            ),
            onPressed: () => Navigator.pop(context, true),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _primaryButton({
    required String label,
    required VoidCallback? onPressed,
    bool loading = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00C896),
          disabledBackgroundColor: const Color(
            0xFF00C896,
          ).withValues(alpha: 0.4),
          foregroundColor: const Color(0xFF0A0E1A),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF0A0E1A),
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _shareButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: const Color(0xFF141824),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF1E2535)),
          ),
          child: Column(
            children: [
              Icon(icon, color: const Color(0xFF00C896), size: 22),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
