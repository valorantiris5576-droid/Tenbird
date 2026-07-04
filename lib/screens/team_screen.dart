import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../app_language.dart';

class TeamScreen extends StatefulWidget {
  const TeamScreen({super.key});
  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  void _showCreateTeamDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF141824),
        title: Text(
          AppLanguage.t(
            en: 'Create Team',
            ko: '팀 만들기',
            ja: 'チーム作成',
            es: 'Crear equipo',
            zh: '创建团队',
          ),
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLanguage.t(
                en: 'Enter team name.',
                ko: '팀 이름을 입력하세요.',
                ja: 'チーム名を入力してください。',
                es: 'Ingresa el nombre del equipo.',
                zh: '请输入团队名称。',
              ),
              style: const TextStyle(color: Color(0xB3FFFFFF), fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: AppLanguage.t(
                  en: 'Team Name',
                  ko: '팀 이름',
                  ja: 'チーム名',
                  es: 'Nombre del equipo',
                  zh: '团队名称',
                ),
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
            onPressed: () async {
              final teamName = controller.text.trim();
              if (teamName.isEmpty) return;
              final uid = _auth.currentUser?.uid;
              final teamRef = await _db.collection('teams').add({
                'name': teamName,
                'createdBy': uid,
                'createdAt': FieldValue.serverTimestamp(),
                'totalKm': 0.0,
                'totalDonation': 0,
                'memberCount': 1,
              });
              await teamRef.collection('members').doc(uid).set({
                'joinedAt': FieldValue.serverTimestamp(),
              });
              await _db.collection('users').doc(uid).set({
                'teamId': teamRef.id,
                'teamName': teamName,
              }, SetOptions(merge: true));
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '$teamName ${AppLanguage.t(en: 'team created!', ko: '팀이 생성됐어요!', ja: 'チームが作成されました！', es: '¡equipo creado!', zh: '团队已创建！')}',
                    ),
                  ),
                );
              }
            },
            child: Text(
              AppLanguage.t(
                en: 'Create',
                ko: '만들기',
                ja: '作成',
                es: 'Crear',
                zh: '创建',
              ),
              style: const TextStyle(color: Color(0xFF00C896)),
            ),
          ),
        ],
      ),
    );
  }

  void _showJoinTeamDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF141824),
        title: Text(
          AppLanguage.t(
            en: 'Join Team',
            ko: '팀 참가하기',
            ja: 'チームに参加',
            es: 'Unirse al equipo',
            zh: '加入团队',
          ),
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLanguage.t(
                en: 'Search team name.',
                ko: '팀 이름을 검색하세요.',
                ja: 'チーム名を検索してください。',
                es: 'Busca el nombre del equipo.',
                zh: '搜索团队名称。',
              ),
              style: const TextStyle(color: Color(0xB3FFFFFF), fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: AppLanguage.t(
                  en: 'Team Name',
                  ko: '팀 이름',
                  ja: 'チーム名',
                  es: 'Nombre del equipo',
                  zh: '团队名称',
                ),
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
            onPressed: () async {
              final teamName = controller.text.trim();
              if (teamName.isEmpty) return;
              final uid = _auth.currentUser?.uid;
              final result = await _db
                  .collection('teams')
                  .where('name', isEqualTo: teamName)
                  .limit(1)
                  .get();
              if (context.mounted) {
                Navigator.pop(context);
                if (result.docs.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLanguage.t(
                          en: 'Team not found.',
                          ko: '팀을 찾을 수 없어요.',
                          ja: 'チームが見つかりません。',
                          es: 'Equipo no encontrado.',
                          zh: '找不到团队。',
                        ),
                      ),
                    ),
                  );
                } else {
                  final teamDoc = result.docs.first;
                  await teamDoc.reference.collection('members').doc(uid).set({
                    'joinedAt': FieldValue.serverTimestamp(),
                  });
                  await teamDoc.reference.update({
                    'memberCount': FieldValue.increment(1),
                  });
                  await _db.collection('users').doc(uid).set({
                    'teamId': teamDoc.id,
                    'teamName': teamName,
                  }, SetOptions(merge: true));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '$teamName ${AppLanguage.t(en: 'joined!', ko: '팀에 참가했어요!', ja: 'に参加しました！', es: '¡te uniste!', zh: '已加入！')}',
                        ),
                      ),
                    );
                  }
                }
              }
            },
            child: Text(
              AppLanguage.t(
                en: 'Join',
                ko: '참가',
                ja: '参加',
                es: 'Unirse',
                zh: '加入',
              ),
              style: const TextStyle(color: Color(0xFF00C896)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = _auth.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E1A),
        elevation: 0,
        title: Text(
          AppLanguage.t(
            en: 'Team Running',
            ko: '팀 러닝',
            ja: 'チームランニング',
            es: 'Carrera en equipo',
            zh: '团队跑步',
          ),
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: _db.collection('users').doc(uid).snapshots(),
          builder: (context, userSnap) {
            final userData = userSnap.data?.data() as Map?;
            final teamId = userData?['teamId'];

            if (teamId == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.groups_outlined,
                        color: Color(0xFF00C896),
                        size: 64,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        AppLanguage.t(
                          en: 'No team yet',
                          ko: '아직 팀이 없어요',
                          ja: 'まだチームがありません',
                          es: 'Aún no tienes equipo',
                          zh: '还没有团队',
                        ),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppLanguage.t(
                          en: 'Create or join a team\nto run with friends!',
                          ko: '팀을 만들거나 참가해서\n친구들과 함께 달려보세요!',
                          ja: 'チームを作るか参加して\n友達と一緒に走りましょう！',
                          es: 'Crea o únete a un equipo\n¡para correr con amigos!',
                          zh: '创建或加入团队\n与朋友一起跑步！',
                        ),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF8899AA),
                          fontSize: 13,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _showCreateTeamDialog,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00C896),
                            foregroundColor: const Color(0xFF0A0E1A),
                            padding: const EdgeInsets.symmetric(vertical: 16),
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
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _showJoinTeamDialog,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF00C896),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: Color(0xFF00C896)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            AppLanguage.t(
                              en: 'Join Team',
                              ko: '팀 참가하기',
                              ja: 'チームに参加',
                              es: 'Unirse al equipo',
                              zh: '加入团队',
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
                if (!teamSnap.hasData) return const SizedBox();
                final teamData = teamSnap.data?.data() as Map?;
                if (teamData == null) return const SizedBox();
                final teamName = teamData['name'] ?? '';
                final totalKm = (teamData['totalKm'] ?? 0.0);
                final km = totalKm is double
                    ? totalKm
                    : (totalKm as num).toDouble();
                final totalDon = teamData['totalDonation'] ?? 0;
                final memberCount = teamData['memberCount'] ?? 1;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFF111827),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(
                              0xFF00C896,
                            ).withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
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
                                    Icons.groups,
                                    color: Color(0xFF00C896),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      teamName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '$memberCount ${AppLanguage.t(en: 'members', ko: '명 참가 중', ja: '名参加中', es: 'miembros', zh: '名成员')}',
                                      style: const TextStyle(
                                        color: Color(0xFF8899AA),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        AppLanguage.t(
                                          en: 'Team Distance',
                                          ko: '팀 누적 거리',
                                          ja: 'チーム累計距離',
                                          es: 'Distancia del equipo',
                                          zh: '团队累计距离',
                                        ),
                                        style: const TextStyle(
                                          color: Color(0xFF8899AA),
                                          fontSize: 11,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${km.toStringAsFixed(1)} km',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        AppLanguage.t(
                                          en: 'Team Donations',
                                          ko: '팀 누적 기부',
                                          ja: 'チーム累計寄付',
                                          es: 'Donaciones del equipo',
                                          zh: '团队累计捐款',
                                        ),
                                        style: const TextStyle(
                                          color: Color(0xFF8899AA),
                                          fontSize: 11,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '₩$totalDon',
                                        style: const TextStyle(
                                          color: Color(0xFF00C896),
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        AppLanguage.t(
                          en: 'Team Members',
                          ko: '팀 멤버',
                          ja: 'チームメンバー',
                          es: 'Miembros del equipo',
                          zh: '团队成员',
                        ),
                        style: const TextStyle(
                          color: Color(0xB3FFFFFF),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 12),
                      StreamBuilder<QuerySnapshot>(
                        stream: _db
                            .collection('teams')
                            .doc(teamId)
                            .collection('members')
                            .snapshots(),
                        builder: (context, memberSnap) {
                          if (!memberSnap.hasData) return const SizedBox();
                          return Column(
                            children: memberSnap.data!.docs.map((doc) {
                              return StreamBuilder<DocumentSnapshot>(
                                stream: _db
                                    .collection('users')
                                    .doc(doc.id)
                                    .snapshots(),
                                builder: (context, memberDataSnap) {
                                  final mData =
                                      memberDataSnap.data?.data() as Map?;
                                  final name =
                                      mData?['displayName'] ??
                                      mData?['username'] ??
                                      'Runner';
                                  final memberKmRaw = mData?['totalKm'] ?? 0.0;
                                  final memberKm = memberKmRaw is double
                                      ? memberKmRaw
                                      : (memberKmRaw as num).toDouble();
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF141824),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: const Color(0xFF1E2535),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          name,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          '${memberKm.toStringAsFixed(1)} km',
                                          style: const TextStyle(
                                            color: Color(0xFF00C896),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
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
