import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_language.dart';
import 'team_onboarding_screen.dart';

class TeamManageScreen extends StatefulWidget {
  const TeamManageScreen({super.key});

  @override
  State<TeamManageScreen> createState() => _TeamManageScreenState();
}

class _TeamManageScreenState extends State<TeamManageScreen> {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  Future<void> _leaveTeam(String teamId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF141824),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          AppLanguage.t(
            en: 'Leave team?',
            ko: '팀을 나갈까요?',
            ja: 'チームを脱退しますか？',
            es: '¿Salir del equipo?',
            zh: '退出团队？',
          ),
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          AppLanguage.t(
            en: 'You can join again with the invite code.',
            ko: '초대 코드로 다시 참가할 수 있어요.',
            ja: '招待コードで再参加できます。',
            es: 'Puedes volver con el código de invitación.',
            zh: '可以用邀请码再次加入。',
          ),
          style: const TextStyle(color: Color(0xB3FFFFFF), fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              AppLanguage.t(
                en: 'Cancel',
                ko: '취소',
                ja: 'キャンセル',
                es: 'Cancelar',
                zh: '取消',
              ),
              style: const TextStyle(color: Color(0xFF8899AA)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              AppLanguage.t(
                en: 'Leave',
                ko: '나가기',
                ja: '脱退',
                es: 'Salir',
                zh: '退出',
              ),
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    await _db.collection('teams').doc(teamId).collection('members').doc(uid).delete();
    await _db.collection('teams').doc(teamId).update({
      'memberCount': FieldValue.increment(-1),
    });
    await _db.collection('users').doc(uid).set({
      'teamId': FieldValue.delete(),
      'teamName': FieldValue.delete(),
    }, SetOptions(merge: true));

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLanguage.t(
              en: 'You left the team.',
              ko: '팀에서 나왔어요.',
              ja: 'チームを脱退しました。',
              es: 'Saliste del equipo.',
              zh: '已退出团队。',
            ),
          ),
        ),
      );
    }
  }

  Future<void> _copyCode(String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLanguage.t(
              en: 'Code copied!',
              ko: '코드가 복사됐어요!',
              ja: 'コードをコピーしました！',
              es: '¡Código copiado!',
              zh: '代码已复制！',
            ),
          ),
        ),
      );
    }
  }

  void _openCreateTeam() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TeamOnboardingScreen()),
    ).then((created) {
      if (created == true && mounted) Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final uid = _auth.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E1A),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          AppLanguage.t(
            en: 'Team Management',
            ko: '팀 관리',
            ja: 'チーム管理',
            es: 'Gestión de equipo',
            zh: '团队管理',
          ),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: _db.collection('users').doc(uid).snapshots(),
          builder: (context, userSnap) {
            final userData = userSnap.data?.data() as Map?;
            final teamId = userData?['teamId'] as String?;

            if (teamId == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.groups_outlined,
                        color: Color(0xFF8899AA),
                        size: 56,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppLanguage.t(
                          en: 'You\'re not in a team yet',
                          ko: '아직 팀이 없어요',
                          ja: 'まだチームに所属していません',
                          es: 'Aún no estás en un equipo',
                          zh: '您还没有加入团队',
                        ),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppLanguage.t(
                          en: 'Create a team from the Challenge tab.',
                          ko: '챌린지 탭에서 팀을 만들 수 있어요.',
                          ja: 'チャレンジタブからチームを作成できます。',
                          es: 'Crea un equipo desde la pestaña Desafíos.',
                          zh: '可在挑战标签页创建团队。',
                        ),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF8899AA),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _openCreateTeam,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00C896),
                            foregroundColor: const Color(0xFF0A0E1A),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            AppLanguage.t(
                              en: 'Create Team',
                              ko: '팀 만들기',
                              ja: 'チームを作る',
                              es: 'Crear equipo',
                              zh: '创建团队',
                            ),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return StreamBuilder<DocumentSnapshot>(
              stream: _db.collection('teams').doc(teamId).snapshots(),
              builder: (context, teamSnap) {
                if (!teamSnap.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF00C896)),
                  );
                }

                final teamData = teamSnap.data?.data() as Map?;
                final teamName = teamData?['name'] as String? ?? '';
                final inviteCode = teamData?['inviteCode'] as String? ?? teamId.substring(0, 6).toUpperCase();
                final memberCount = teamData?['memberCount'] ?? 1;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF00C896).withValues(alpha: 0.15),
                              ),
                              child: const Icon(
                                Icons.groups,
                                color: Color(0xFF00C896),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    teamName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '$memberCount ${AppLanguage.t(en: 'members', ko: '명', ja: '名', es: 'miembros', zh: '名成员')}',
                                    style: const TextStyle(
                                      color: Color(0xFF8899AA),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        AppLanguage.t(
                          en: 'Invite code',
                          ko: '초대 코드',
                          ja: '招待コード',
                          es: 'Código de invitación',
                          zh: '邀请码',
                        ),
                        style: const TextStyle(
                          color: Color(0xB3FFFFFF),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF141824),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFF1E2535)),
                        ),
                        child: Row(
                          children: [
                            Text(
                              inviteCode,
                              style: const TextStyle(
                                color: Color(0xFF00C896),
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 4,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () => _copyCode(inviteCode),
                              icon: const Icon(
                                Icons.copy,
                                color: Color(0xFF8899AA),
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppLanguage.t(
                          en: 'Share this code so friends can join your team.',
                          ko: '친구에게 코드를 공유하면 팀에 참가할 수 있어요.',
                          ja: 'このコードを共有して友達を招待しましょう。',
                          es: 'Comparte este código para que se unan.',
                          zh: '分享此代码让好友加入团队。',
                        ),
                        style: const TextStyle(
                          color: Color(0xFF8899AA),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => _leaveTeam(teamId),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.redAccent,
                            side: const BorderSide(color: Colors.redAccent),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            AppLanguage.t(
                              en: 'Leave Team',
                              ko: '팀 나가기',
                              ja: 'チームを脱退',
                              es: 'Salir del equipo',
                              zh: '退出团队',
                            ),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
