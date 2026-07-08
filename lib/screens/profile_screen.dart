import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../app_language.dart';
import 'team_manage_screen.dart';
import 'team_onboarding_screen.dart';
import '../models/badge_model.dart';
import '../services/badge_service.dart';
import 'badge_collection_screen.dart';

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

  String _badgeEmoji(String id) {
    const map = {
      'first_run': '👟',
      'run_5km': '🏃',
      'run_10km': '⚡',
      'run_42km': '🏅',
      'run_100km': '🏆',
      'run_7days': '🔥',
      'team_founder': '👑',
      'team_member': '🤝',
      'friend_added': '💚',
      'challenge_1': '🎯',
      'challenge_3': '⚔️',
      'donation_first': '❤️',
      'donation_1000': '💎',
      'donation_10000': '🌟',
      'hidden_night_owl': '🦉',
      'hidden_early_bird': '🐦',
      'hidden_marathon': '🗿',
    };
    return map[id] ?? '🏅';
  }

  Future<void> _signOut() async {
    await _auth.signOut();
  }

  void _showSecurityDialog() {
    final user = _auth.currentUser;
    final isGuest = user?.isAnonymous ?? false;

    if (isGuest) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF141824),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            AppLanguage.t(
              en: 'No Account',
              ko: '계정 없음',
              ja: 'アカウントなし',
              es: 'Sin cuenta',
              zh: '没有账户',
            ),
            style: const TextStyle(color: Colors.white, fontSize: 17),
          ),
          content: Text(
            AppLanguage.t(
              en: 'Guest data is lost when the app is deleted.\nCreate an account to keep your donations safe!',
              ko: '게스트 데이터는 앱 삭제 시 사라져요.\n계정을 만들어 기부금을 지켜보세요!',
              ja: 'ゲストデータはアプリ削除で消えます。\nアカウントを作って寄付を守りましょう！',
              es: 'Los datos de invitado se pierden al eliminar la app.\n¡Crea una cuenta para proteger tus donaciones!',
              zh: '访客数据在删除应用时会丢失。\n创建账户保护您的捐款！',
            ),
            style: const TextStyle(
              color: Color(0xB3FFFFFF),
              fontSize: 13,
              height: 1.6,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                AppLanguage.t(
                  en: 'Later',
                  ko: '나중에',
                  ja: '後で',
                  es: 'Después',
                  zh: '稍后',
                ),
                style: const TextStyle(color: Color(0xFF8899AA)),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _auth.signOut();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00C896),
                foregroundColor: const Color(0xFF0A0E1A),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                AppLanguage.t(
                  en: 'Sign Up',
                  ko: '회원가입',
                  ja: '新規登録',
                  es: 'Registrarse',
                  zh: '注册',
                ),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
      return;
    }

    final passwordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    int tabIndex = 0;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111827),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
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
                const SizedBox(height: 16),
                Text(
                  AppLanguage.t(
                    en: 'Security',
                    ko: '보안',
                    ja: 'セキュリティ',
                    es: 'Seguridad',
                    zh: '安全',
                  ),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setModalState(() => tabIndex = 0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: tabIndex == 0
                                ? const Color(0xFF00C896).withValues(alpha: 0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: tabIndex == 0
                                  ? const Color(0xFF00C896)
                                  : const Color(0xFF1E2535),
                            ),
                          ),
                          child: Text(
                            AppLanguage.t(
                              en: 'Password',
                              ko: '비밀번호',
                              ja: 'パスワード',
                              es: 'Contraseña',
                              zh: '密码',
                            ),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: tabIndex == 0
                                  ? const Color(0xFF00C896)
                                  : const Color(0xFF8899AA),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setModalState(() => tabIndex = 1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: tabIndex == 1
                                ? const Color(0xFF00C896).withValues(alpha: 0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: tabIndex == 1
                                  ? const Color(0xFF00C896)
                                  : const Color(0xFF1E2535),
                            ),
                          ),
                          child: Text(
                            AppLanguage.t(
                              en: 'Email',
                              ko: '이메일',
                              ja: 'メール',
                              es: 'Email',
                              zh: '邮箱',
                            ),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: tabIndex == 1
                                  ? const Color(0xFF00C896)
                                  : const Color(0xFF8899AA),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (tabIndex == 0) ...[
                  _buildTextField(
                    passwordController,
                    AppLanguage.t(
                      en: 'Current Password',
                      ko: '현재 비밀번호',
                      ja: '現在のパスワード',
                      es: 'Contraseña actual',
                      zh: '当前密码',
                    ),
                    obscure: true,
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(
                    newPasswordController,
                    AppLanguage.t(
                      en: 'New Password',
                      ko: '새 비밀번호',
                      ja: '新しいパスワード',
                      es: 'Nueva contraseña',
                      zh: '新密码',
                    ),
                    obscure: true,
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(
                    confirmPasswordController,
                    AppLanguage.t(
                      en: 'Confirm Password',
                      ko: '비밀번호 확인',
                      ja: 'パスワード確認',
                      es: 'Confirmar contraseña',
                      zh: '确认密码',
                    ),
                    obscure: true,
                  ),
                  const SizedBox(height: 20),
                  _buildSubmitButton(
                    label: AppLanguage.t(
                      en: 'Change Password',
                      ko: '비밀번호 변경',
                      ja: 'パスワード変更',
                      es: 'Cambiar contraseña',
                      zh: '修改密码',
                    ),
                    onPressed: () async {
                      if (newPasswordController.text !=
                          confirmPasswordController.text) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              AppLanguage.t(
                                en: 'Passwords do not match!',
                                ko: '비밀번호가 일치하지 않아요!',
                                ja: 'パスワードが一致しません！',
                                es: '¡No coinciden!',
                                zh: '密码不匹配！',
                              ),
                            ),
                          ),
                        );
                        return;
                      }
                      if (newPasswordController.text.length < 6) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              AppLanguage.t(
                                en: 'At least 6 characters!',
                                ko: '6자 이상 입력하세요!',
                                ja: '6文字以上必要です！',
                                es: '¡Mínimo 6 caracteres!',
                                zh: '至少6个字符！',
                              ),
                            ),
                          ),
                        );
                        return;
                      }
                      try {
                        final u = FirebaseAuth.instance.currentUser!;
                        final cred = EmailAuthProvider.credential(
                          email: u.email!,
                          password: passwordController.text,
                        );
                        await u.reauthenticateWithCredential(cred);
                        await u.updatePassword(newPasswordController.text);
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                AppLanguage.t(
                                  en: 'Password changed!',
                                  ko: '비밀번호 변경 완료!',
                                  ja: 'パスワード変更完了！',
                                  es: '¡Contraseña cambiada!',
                                  zh: '密码已修改！',
                                ),
                              ),
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                AppLanguage.t(
                                  en: 'Wrong password!',
                                  ko: '현재 비밀번호가 틀렸어요!',
                                  ja: 'パスワードが違います！',
                                  es: '¡Contraseña incorrecta!',
                                  zh: '密码错误！',
                                ),
                              ),
                            ),
                          );
                        }
                      }
                    },
                  ),
                ],
                if (tabIndex == 1) ...[
                  _buildTextField(
                    passwordController,
                    AppLanguage.t(
                      en: 'Current Password',
                      ko: '현재 비밀번호',
                      ja: '現在のパスワード',
                      es: 'Contraseña actual',
                      zh: '当前密码',
                    ),
                    obscure: true,
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(
                    newPasswordController,
                    AppLanguage.t(
                      en: 'New Email',
                      ko: '새 이메일',
                      ja: '新しいメール',
                      es: 'Nuevo email',
                      zh: '新邮箱',
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSubmitButton(
                    label: AppLanguage.t(
                      en: 'Change Email',
                      ko: '이메일 변경',
                      ja: 'メール変更',
                      es: 'Cambiar email',
                      zh: '修改邮箱',
                    ),
                    onPressed: () async {
                      try {
                        final u = FirebaseAuth.instance.currentUser!;
                        final cred = EmailAuthProvider.credential(
                          email: u.email!,
                          password: passwordController.text,
                        );
                        await u.reauthenticateWithCredential(cred);
                        await u.verifyBeforeUpdateEmail(
                          newPasswordController.text,
                        );
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                AppLanguage.t(
                                  en: 'Verification email sent!',
                                  ko: '인증 메일 발송 완료!',
                                  ja: '認証メール送信完了！',
                                  es: '¡Email enviado!',
                                  zh: '验证邮件已发送！',
                                ),
                              ),
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                AppLanguage.t(
                                  en: 'Wrong password!',
                                  ko: '현재 비밀번호가 틀렸어요!',
                                  ja: 'パスワードが違います！',
                                  es: '¡Contraseña incorrecta!',
                                  zh: '密码错误！',
                                ),
                              ),
                            ),
                          );
                        }
                      }
                    },
                  ),
                ],
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF8899AA)),
        filled: true,
        fillColor: const Color(0xFF141824),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1E2535)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF00C896)),
        ),
      ),
    );
  }

  Widget _buildSubmitButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
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
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ),
    );
  }

  void _showFriendDialog() {
    if (_auth.currentUser?.isAnonymous ?? false) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF141824),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            AppLanguage.t(
              en: 'Friends',
              ko: '친구',
              ja: 'フレンド',
              es: 'Amigos',
              zh: '好友',
            ),
            style: const TextStyle(color: Colors.white, fontSize: 17),
          ),
          content: Text(
            AppLanguage.t(
              en: 'Create an account to connect with friends and track each other\'s runs!',
              ko: '계정을 만들면 친구와 함께 달린 거리를 나눌 수 있어요!',
              ja: 'アカウントを作って友達と一緒に走りましょう！',
              es: '¡Crea una cuenta para correr con amigos!',
              zh: '创建账户与好友一起跑步！',
            ),
            style: const TextStyle(
              color: Color(0xB3FFFFFF),
              fontSize: 13,
              height: 1.6,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                AppLanguage.t(
                  en: 'Later',
                  ko: '나중에',
                  ja: '後で',
                  es: 'Después',
                  zh: '稍后',
                ),
                style: const TextStyle(color: Color(0xFF8899AA)),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _auth.signOut();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00C896),
                foregroundColor: const Color(0xFF0A0E1A),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                AppLanguage.t(
                  en: 'Sign Up',
                  ko: '회원가입',
                  ja: '新規登録',
                  es: 'Registrarse',
                  zh: '注册',
                ),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
      return;
    }

    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111827),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
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
              const SizedBox(height: 16),
              Text(
                AppLanguage.t(
                  en: 'Add Friend',
                  ko: '친구 추가',
                  ja: 'フレンド追加',
                  es: 'Agregar amigo',
                  zh: '添加好友',
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
                  en: 'Enter username to send a friend request.',
                  ko: '유저네임을 입력하면 요청이 전송돼요.',
                  ja: 'ユーザー名を入力してフレンド申請を送りましょう。',
                  es: 'Ingresa el usuario para enviar una solicitud.',
                  zh: '输入用户名发送好友请求。',
                ),
                style: const TextStyle(color: Color(0xFF8899AA), fontSize: 12),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                style: const TextStyle(color: Colors.white),
                autofocus: true,
                decoration: InputDecoration(
                  labelText: AppLanguage.t(
                    en: 'Username',
                    ko: '유저네임',
                    ja: 'ユーザー名',
                    es: 'Usuario',
                    zh: '用户名',
                  ),
                  labelStyle: const TextStyle(color: Color(0xFF8899AA)),
                  filled: true,
                  fillColor: const Color(0xFF141824),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF8899AA),
                  ),
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
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
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
                      } else {
                        final friendUid = result.docs.first.id;
                        if (friendUid == uid) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                AppLanguage.t(
                                  en: 'You can\'t add yourself!',
                                  ko: '자기 자신은 추가할 수 없어요!',
                                  ja: '自分自身は追加できません！',
                                  es: '¡No puedes agregarte!',
                                  zh: '不能添加自己！',
                                ),
                              ),
                            ),
                          );
                          return;
                        }
                        final existing = await _db
                            .collection('users')
                            .doc(uid)
                            .collection('friends')
                            .doc(friendUid)
                            .get();
                        if (existing.exists) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  AppLanguage.t(
                                    en: 'Already friends!',
                                    ko: '이미 친구예요!',
                                    ja: 'すでにフレンドです！',
                                    es: '¡Ya son amigos!',
                                    zh: '已经是好友了！',
                                  ),
                                ),
                              ),
                            );
                          }
                          return;
                        }
                        final requestExisting = await _db
                            .collection('users')
                            .doc(friendUid)
                            .collection('friendRequests')
                            .doc(uid)
                            .get();
                        if (requestExisting.exists) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  AppLanguage.t(
                                    en: 'Request already sent!',
                                    ko: '이미 요청을 보냈어요!',
                                    ja: 'すでに申請済みです！',
                                    es: '¡Solicitud ya enviada!',
                                    zh: '请求已发送！',
                                  ),
                                ),
                              ),
                            );
                          }
                          return;
                        }
                        final myData = await _db
                            .collection('users')
                            .doc(uid)
                            .get();
                        final myUsername =
                            (myData.data() as Map?)?['username'] ?? '';
                        await _db
                            .collection('users')
                            .doc(friendUid)
                            .collection('friendRequests')
                            .doc(uid)
                            .set({
                              'from': uid,
                              'username': myUsername,
                              'sentAt': FieldValue.serverTimestamp(),
                            });
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                AppLanguage.t(
                                  en: 'Friend request sent!',
                                  ko: '친구 요청을 보냈어요!',
                                  ja: 'フレンド申請を送りました！',
                                  es: '¡Solicitud enviada!',
                                  zh: '好友请求已发送！',
                                ),
                              ),
                              backgroundColor: const Color(0xFF00C896),
                            ),
                          );
                        }
                      }
                    }
                  },
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
                      en: 'Send Request',
                      ko: '요청 보내기',
                      ja: '申請を送る',
                      es: 'Enviar solicitud',
                      zh: '发送请求',
                    ),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _showLocationDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF141824),
        title: Text(
          AppLanguage.t(
            en: 'Change Location',
            ko: '동네 변경',
            ja: '地域変更',
            es: 'Cambiar ubicación',
            zh: '更改地区',
          ),
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLanguage.t(
                en: 'Enter your activity area.',
                ko: '활동 지역을 입력하세요.',
                ja: '活動地域を入力してください。',
                es: 'Ingresa tu área de actividad.',
                zh: '请输入活动地区。',
              ),
              style: const TextStyle(color: Color(0xB3FFFFFF), fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: AppLanguage.t(
                  en: 'e.g. Gangnam, Seoul',
                  ko: '예: 서울 강남구',
                  ja: '例: 東京都渋谷区',
                  es: 'ej. Madrid',
                  zh: '例如: 首尔江南区',
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
              final uid = _auth.currentUser?.uid;
              if (uid != null && controller.text.trim().isNotEmpty) {
                await _db.collection('users').doc(uid).set({
                  'location': controller.text.trim(),
                }, SetOptions(merge: true));
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLanguage.t(
                          en: 'Location updated!',
                          ko: '동네가 변경됐어요!',
                          ja: '地域が変更されました！',
                          es: '¡Ubicación actualizada!',
                          zh: '地区已更新！',
                        ),
                      ),
                    ),
                  );
                }
              }
            },
            child: Text(
              AppLanguage.t(
                en: 'Save',
                ko: '저장',
                ja: '保存',
                es: 'Guardar',
                zh: '保存',
              ),
              style: const TextStyle(color: Color(0xFF00C896)),
            ),
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
            Text(
              AppLanguage.t(
                en: 'Help',
                ko: '도움말',
                ja: 'ヘルプ',
                es: 'Ayuda',
                zh: '帮助',
              ),
              style: const TextStyle(
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
                children: [
                  _HelpItem(
                    q: AppLanguage.t(
                      en: 'How are donations calculated?',
                      ko: '기부금은 어떻게 계산되나요?',
                      ja: '寄付金はどのように計算されますか？',
                      es: '¿Cómo se calculan las donaciones?',
                      zh: '捐款如何计算？',
                    ),
                    a: AppLanguage.t(
                      en: '10 won is donated for every 1km you run.',
                      ko: '1km를 달릴 때마다 10원이 자동으로 기부됩니다.',
                      ja: '1km走るごとに10ウォンが自動的に寄付されます。',
                      es: 'Se donan 10 wones automáticamente por cada 1km que corres.',
                      zh: '每跑1公里，自动捐赠10韩元。',
                    ),
                  ),
                  _HelpItem(
                    q: AppLanguage.t(
                      en: 'GPS won\'t turn on.',
                      ko: 'GPS가 안 켜져요.',
                      ja: 'GPSがオンになりません。',
                      es: 'El GPS no se activa.',
                      zh: 'GPS无法开启。',
                    ),
                    a: AppLanguage.t(
                      en: 'Please allow location permission in your browser.',
                      ko: '브라우저에서 위치 권한을 허용해주세요.',
                      ja: 'ブラウザで位置情報の許可をしてください。',
                      es: 'Por favor, permite el permiso de ubicación en tu navegador.',
                      zh: '请在浏览器中允许位置权限。',
                    ),
                  ),
                  _HelpItem(
                    q: AppLanguage.t(
                      en: 'How many challenges can I do?',
                      ko: '챌린지는 몇 개까지 가능한가요?',
                      ja: 'チャレンジはいくつまでできますか？',
                      es: '¿Cuántos desafíos puedo hacer?',
                      zh: '我可以参加多少个挑战？',
                    ),
                    a: AppLanguage.t(
                      en: 'You can take on up to 3 challenges at the same time.',
                      ko: '동시에 최대 3개까지 도전할 수 있어요.',
                      ja: '同時に最大3つのチャレンジに挑戦できます。',
                      es: 'Puedes participar en hasta 3 desafíos al mismo tiempo.',
                      zh: '您可以同时参加最多3个挑战。',
                    ),
                  ),
                  _HelpItem(
                    q: AppLanguage.t(
                      en: 'Where do donations actually go?',
                      ko: '기부금은 실제로 어디로 가나요?',
                      ja: '寄付金は実際にどこに行きますか？',
                      es: '¿A dónde van realmente las donaciones?',
                      zh: '捐款实际上去哪里？',
                    ),
                    a: AppLanguage.t(
                      en: 'Currently in development - no actual donations are made yet.',
                      ko: '현재는 개발 단계로 실제 기부는 이루어지지 않아요.',
                      ja: '現在開発段階のため、実際の寄付は行われていません。',
                      es: 'Actualmente en desarrollo, aún no se realizan donaciones reales.',
                      zh: '目前处于开发阶段，尚未进行实际捐款。',
                    ),
                  ),
                  _HelpItem(
                    q: AppLanguage.t(
                      en: 'What if I stop running midway?',
                      ko: '러닝을 중간에 멈추면 기부금은?',
                      ja: '走るのを途中で止めたら寄付金は？',
                      es: '¿Qué pasa si paro de correr a mitad?',
                      zh: '如果中途停止跑步，捐款怎么算？',
                    ),
                    a: AppLanguage.t(
                      en: 'Donations are calculated based on the distance you ran until you stopped.',
                      ko: '멈춘 시점까지 달린 거리로 기부금이 계산돼요.',
                      ja: '止まった時点までの距離で寄付金が計算されます。',
                      es: 'Las donaciones se calculan en base a la distancia que corriste hasta que paraste.',
                      zh: '捐款根据您停止时已跑的距离计算。',
                    ),
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
        title: Text(
          AppLanguage.t(
            en: 'Notification Settings',
            ko: '알림 설정',
            ja: '通知設定',
            es: 'Configuración de notificaciones',
            zh: '通知设置',
          ),
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          AppLanguage.t(
            en: 'Push notifications are coming soon!',
            ko: '푸시 알림 기능은 준비 중이에요! 곧 업데이트될 예정이에요.',
            ja: 'プッシュ通知は準備中です！もうすぐアップデートされます。',
            es: '¡Las notificaciones push estarán disponibles pronto!',
            zh: '推送通知功能即将推出！',
          ),
          style: const TextStyle(color: Color(0xB3FFFFFF), fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppLanguage.t(en: 'OK', ko: '확인', ja: 'OK', es: 'OK', zh: '确认'),
              style: const TextStyle(color: Color(0xFF00C896)),
            ),
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
                      Text(
                        AppLanguage.t(
                          en: 'Profile',
                          ko: '프로필',
                          ja: 'プロフィール',
                          es: 'Perfil',
                          zh: '个人资료',
                        ),
                        style: const TextStyle(
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
                          isGuest
                              ? AppLanguage.t(
                                  en: 'Guest',
                                  ko: '게스트',
                                  ja: 'ゲスト',
                                  es: 'Invitado',
                                  zh: '访客',
                                )
                              : (user?.displayName ??
                                    AppLanguage.t(
                                      en: 'Runner',
                                      ko: '러너',
                                      ja: 'ランナー',
                                      es: 'Corredor',
                                      zh: '跑步者',
                                    )),
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
                                ? '${AppLanguage.t(en: 'Joined', ko: '가입일', ja: '加入日', es: 'Unido', zh: '加入日期')} ${createdAt.toDate().year}.${createdAt.toDate().month.toString().padLeft(2, '0')}.${createdAt.toDate().day.toString().padLeft(2, '0')}'
                                : '${AppLanguage.t(en: 'Joined', ko: '가입일', ja: '加入日', es: 'Unido', zh: '加入日期')} -';
                            return Column(
                              children: [
                                Text(
                                  dateStr,
                                  style: const TextStyle(
                                    color: Color(0xB3FFFFFF),
                                    fontSize: 12,
                                  ),
                                ),
                                if (data?['teamName'] != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    '${data!['teamName']}',
                                    style: const TextStyle(
                                      color: Color(0xFF00C896),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ],
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
                              AppLanguage.t(
                                en: 'My Info',
                                ko: '내 정보',
                                ja: '自分の情報',
                                es: 'Mi info',
                                zh: '我的信息',
                              ),
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
                              AppLanguage.t(
                                en: 'Friends',
                                ko: '친구',
                                ja: 'フレンド',
                                es: 'Amigos',
                                zh: '好友',
                              ),
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
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _tabIndex = 2),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: _tabIndex == 2
                                      ? const Color(0xFF00C896)
                                      : const Color(0xFF1E2535),
                                  width: 2,
                                ),
                              ),
                            ),
                            child: Text(
                              AppLanguage.t(
                                en: 'Badges',
                                ko: '배지',
                                ja: 'バッジ',
                                es: 'Insignias',
                                zh: '徽章',
                              ),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _tabIndex == 2
                                    ? const Color(0xFF00C896)
                                    : const Color(0xFF8899AA),
                                fontSize: 13,
                                fontWeight: _tabIndex == 2
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
                                        Text(
                                          AppLanguage.t(
                                            en: 'Total Donations',
                                            ko: '총 기부금',
                                            ja: '総寄付金',
                                            es: 'Total donado',
                                            zh: '总捐款',
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
                                        Text(
                                          AppLanguage.t(
                                            en: 'Total Distance',
                                            ko: '총 거리',
                                            ja: '総距離',
                                            es: 'Distancia total',
                                            zh: '总距离',
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
                                      Text(
                                        AppLanguage.t(
                                          en: 'Weekly Goal',
                                          ko: '이번 주 목표',
                                          ja: '今週の目標',
                                          es: 'Meta semanal',
                                          zh: '本周目标',
                                        ),
                                        style: const TextStyle(
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
                    Text(
                      AppLanguage.t(
                        en: 'Recent Runs',
                        ko: '최근 러닝',
                        ja: '最近のランニング',
                        es: 'Carreras recientes',
                        zh: '最近跑步',
                      ),
                      style: const TextStyle(
                        color: Color(0xB3FFFFFF),
                        fontSize: 13,
                      ),
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
                          return Text(
                            AppLanguage.t(
                              en: 'No running records yet',
                              ko: '아직 러닝 기록이 없어요',
                              ja: 'まだランニング記録がありません',
                              es: 'Aún no hay registros de carrera',
                              zh: '还没有跑步记录',
                            ),
                            style: const TextStyle(color: Color(0xFF8899AA)),
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
                    StreamBuilder<QuerySnapshot>(
                      stream: _db
                          .collection('users')
                          .doc(uid)
                          .collection('friendRequests')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const SizedBox();
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLanguage.t(
                                en: 'Friend Requests',
                                ko: '친구 요청',
                                ja: 'フレンド申請',
                                es: 'Solicitudes',
                                zh: '好友请求',
                              ),
                              style: const TextStyle(
                                color: Color(0xB3FFFFFF),
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...snapshot.data!.docs.map((doc) {
                              final fromUid = doc['from'] as String;
                              final fromUsername =
                                  doc['username'] as String? ?? '';
                              final initials = fromUsername.length >= 2
                                  ? fromUsername.substring(0, 2).toUpperCase()
                                  : fromUsername.toUpperCase();
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF141824),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(
                                      0xFF00C896,
                                    ).withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Row(
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
                                            fromUsername,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            AppLanguage.t(
                                              en: 'wants to be friends',
                                              ko: '친구 요청을 보냈어요',
                                              ja: 'フレンド申請が届きました',
                                              es: 'quiere ser tu amigo',
                                              zh: '发送了好友请求',
                                            ),
                                            style: const TextStyle(
                                              color: Color(0xFF8899AA),
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () async {
                                            await _db
                                                .collection('users')
                                                .doc(uid)
                                                .collection('friends')
                                                .doc(fromUid)
                                                .set({
                                                  'username': fromUsername,
                                                  'addedAt':
                                                      FieldValue.serverTimestamp(),
                                                });
                                            await _db
                                                .collection('users')
                                                .doc(fromUid)
                                                .collection('friends')
                                                .doc(uid)
                                                .set({
                                                  'username':
                                                      (await _db
                                                              .collection(
                                                                'users',
                                                              )
                                                              .doc(uid)
                                                              .get())
                                                          .data()?['username'] ??
                                                      '',
                                                  'addedAt':
                                                      FieldValue.serverTimestamp(),
                                                });
                                            await _db
                                                .collection('users')
                                                .doc(uid)
                                                .collection('friendRequests')
                                                .doc(fromUid)
                                                .delete();
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    AppLanguage.t(
                                                      en: 'Friend added!',
                                                      ko: '친구가 됐어요!',
                                                      ja: 'フレンドになりました！',
                                                      es: '¡Amigo agregado!',
                                                      zh: '已成为好友！',
                                                    ),
                                                  ),
                                                  backgroundColor: const Color(
                                                    0xFF00C896,
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                          child: Container(
                                            width: 36,
                                            height: 36,
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
                                              Icons.check,
                                              color: Color(0xFF00C896),
                                              size: 18,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        GestureDetector(
                                          onTap: () async {
                                            await _db
                                                .collection('users')
                                                .doc(uid)
                                                .collection('friendRequests')
                                                .doc(fromUid)
                                                .delete();
                                          },
                                          child: Container(
                                            width: 36,
                                            height: 36,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.redAccent
                                                  .withValues(alpha: 0.1),
                                              border: Border.all(
                                                color: Colors.redAccent
                                                    .withValues(alpha: 0.4),
                                                width: 1.5,
                                              ),
                                            ),
                                            child: const Icon(
                                              Icons.close,
                                              color: Colors.redAccent,
                                              size: 18,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }),
                            const SizedBox(height: 16),
                          ],
                        );
                      },
                    ),

                    Text(
                      AppLanguage.t(
                        en: 'My Friends',
                        ko: '내 친구',
                        ja: 'マイフレンド',
                        es: 'Mis amigos',
                        zh: '我的好友',
                      ),
                      style: const TextStyle(
                        color: Color(0xB3FFFFFF),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    StreamBuilder<QuerySnapshot>(
                      stream: _db
                          .collection('users')
                          .doc(uid)
                          .collection('friends')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                AppLanguage.t(
                                  en: 'No friends yet\nAdd friends from the menu!',
                                  ko: '아직 친구가 없어요\n메뉴에서 친구를 추가해보세요!',
                                  ja: 'まだフレンドがいません\nメニューからフレンドを追加しましょう！',
                                  es: 'Aún no tienes amigos\n¡Agrega amigos desde el menú!',
                                  zh: '还没有好友\n从菜单添加好友！',
                                ),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
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
                            final username =
                                doc['username'] ??
                                AppLanguage.t(
                                  en: 'Unknown',
                                  ko: '알 수 없음',
                                  ja: '不明',
                                  es: 'Desconocido',
                                  zh: '未知',
                                );
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
                                                  '${AppLanguage.t(en: 'Total', ko: '총', ja: '合計', es: 'Total', zh: '总计')} ${friendKm.toStringAsFixed(1)}km',
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
                                              Text(
                                                AppLanguage.t(
                                                  en: 'Donated',
                                                  ko: '총 기부',
                                                  ja: '総寄付',
                                                  es: 'Donado',
                                                  zh: '已捐款',
                                                ),
                                                style: const TextStyle(
                                                  color: Color(0xFF8899AA),
                                                  fontSize: 10,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              GestureDetector(
                                                onTap: () async {
                                                  final confirm = await showDialog<bool>(
                                                    context: context,
                                                    builder: (context) => AlertDialog(
                                                      backgroundColor:
                                                          const Color(
                                                            0xFF141824,
                                                          ),
                                                      title: Text(
                                                        AppLanguage.t(
                                                          en: 'Remove Friend',
                                                          ko: '친구 삭제',
                                                          ja: 'フレンド削除',
                                                          es: 'Eliminar amigo',
                                                          zh: '删除好友',
                                                        ),
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                      content: Text(
                                                        AppLanguage.t(
                                                          en: 'Are you sure?',
                                                          ko: '정말 삭제할까요?',
                                                          ja: '本当に削除しますか？',
                                                          es: '¿Estás seguro?',
                                                          zh: '确定删除吗？',
                                                        ),
                                                        style: const TextStyle(
                                                          color: Color(
                                                            0xB3FFFFFF,
                                                          ),
                                                          fontSize: 13,
                                                        ),
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                context,
                                                                false,
                                                              ),
                                                          child: Text(
                                                            AppLanguage.t(
                                                              en: 'Cancel',
                                                              ko: '취소',
                                                              ja: 'キャンセル',
                                                              es: 'Cancelar',
                                                              zh: '取消',
                                                            ),
                                                            style:
                                                                const TextStyle(
                                                                  color: Color(
                                                                    0xFF8899AA,
                                                                  ),
                                                                ),
                                                          ),
                                                        ),
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                context,
                                                                true,
                                                              ),
                                                          child: Text(
                                                            AppLanguage.t(
                                                              en: 'Remove',
                                                              ko: '삭제',
                                                              ja: '削除',
                                                              es: 'Eliminar',
                                                              zh: '删除',
                                                            ),
                                                            style:
                                                                const TextStyle(
                                                                  color: Colors
                                                                      .redAccent,
                                                                ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                  if (confirm == true) {
                                                    await _db
                                                        .collection('users')
                                                        .doc(uid)
                                                        .collection('friends')
                                                        .doc(friendUid)
                                                        .delete();
                                                  }
                                                },
                                                child: Text(
                                                  AppLanguage.t(
                                                    en: 'Remove',
                                                    ko: '삭제',
                                                    ja: '削除',
                                                    es: 'Eliminar',
                                                    zh: '删除',
                                                  ),
                                                  style: const TextStyle(
                                                    color: Colors.redAccent,
                                                    fontSize: 10,
                                                  ),
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
                                          Text(
                                            AppLanguage.t(
                                              en: 'Weekly Goal',
                                              ko: '주간 목표',
                                              ja: '週間目標',
                                              es: 'Meta semanal',
                                              zh: '每周目标',
                                            ),
                                            style: const TextStyle(
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
                  if (_tabIndex == 2) ...[
                    StreamBuilder<DocumentSnapshot>(
                      stream: _db.collection('users').doc(uid).snapshots(),
                      builder: (context, snapshot) {
                        final data = snapshot.data?.data() as Map?;
                        final equippedId = data?['equippedBadge'] as String?;
                        final badges = (data?['badges'] as List? ?? []);
                        final earnedIds = badges
                            .map((e) => e['id'] as String)
                            .toList();
                        final equipped = equippedId != null
                            ? BadgeData.getById(equippedId)
                            : null;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (equipped != null) ...[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF141824),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: BadgeData.rarityColor(
                                      equipped.rarity,
                                    ).withValues(alpha: 0.4),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      _badgeEmoji(equippedId!),
                                      style: const TextStyle(fontSize: 36),
                                    ),
                                    const SizedBox(width: 14),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          equipped.name,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: BadgeData.rarityColor(
                                              equipped.rarity,
                                            ).withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: Text(
                                            BadgeData.rarityName(
                                              equipped.rarity,
                                            ),
                                            style: TextStyle(
                                              color: BadgeData.rarityColor(
                                                equipped.rarity,
                                              ),
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                            Text(
                              '${earnedIds.length} / ${BadgeData.all.length} ${AppLanguage.t(en: 'badges earned', ko: '배지 획득', ja: 'バッジ獲得', es: 'insignias obtenidas', zh: '徽章已获得')}',
                              style: const TextStyle(
                                color: Color(0xFF8899AA),
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: BadgeData.all.isEmpty
                                    ? 0
                                    : earnedIds.length / BadgeData.all.length,
                                backgroundColor: const Color(0xFF1E2535),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFF00C896),
                                ),
                                minHeight: 5,
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const BadgeCollectionScreen(),
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF141824),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 15,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    side: const BorderSide(
                                      color: Color(0xFF1E2535),
                                    ),
                                  ),
                                ),
                                child: Text(
                                  AppLanguage.t(
                                    en: 'View All Badges',
                                    ko: '전체 배지 보기',
                                    ja: '全バッジを見る',
                                    es: 'Ver todas las insignias',
                                    zh: '查看所有徽章',
                                  ),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
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
                            Text(
                              AppLanguage.t(
                                en: 'Settings',
                                ko: '설정',
                                ja: '設定',
                                es: 'Configuración',
                                zh: '设置',
                              ),
                              style: const TextStyle(
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
                        title: AppLanguage.t(
                          en: 'Security',
                          ko: '보안',
                          ja: 'セキュリティ',
                          es: 'Seguridad',
                          zh: '安全',
                        ),
                        subtitle: AppLanguage.t(
                          en: 'Password · Email',
                          ko: '비밀번호 · 이메일',
                          ja: 'パスワード・メール',
                          es: 'Contraseña · Email',
                          zh: '密码 · 邮箱',
                        ),
                        onTap: _showSecurityDialog,
                      ),
                      _MenuItem(
                        icon: Icons.person_add_outlined,
                        title: AppLanguage.t(
                          en: 'Add Friend',
                          ko: '친구 추가',
                          ja: 'フレンド追加',
                          es: 'Agregar amigo',
                          zh: '添加好友',
                        ),
                        subtitle: AppLanguage.t(
                          en: 'Find friends to run with',
                          ko: '함께 달릴 친구 찾기',
                          ja: '一緒に走る友達を探す',
                          es: 'Encuentra amigos para correr',
                          zh: '寻找一起跑步的好友',
                        ),
                        onTap: _showFriendDialog,
                      ),
                      _MenuItem(
                        icon: Icons.groups_outlined,
                        title: AppLanguage.t(
                          en: 'Team Management',
                          ko: '팀 관리',
                          ja: 'チーム管理',
                          es: 'Gestión de equipo',
                          zh: '团队管理',
                        ),
                        subtitle: AppLanguage.t(
                          en: 'Invite code · Leave team',
                          ko: '코드 확인 · 팀 나가기',
                          ja: 'コード確認・脱退',
                          es: 'Código · Salir del equipo',
                          zh: '邀请码 · 退出团队',
                        ),
                        onTap: () {
                          setState(() => _menuOpen = false);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const TeamManageScreen(),
                            ),
                          );
                        },
                      ),
                      _MenuItem(
                        icon: Icons.location_on_outlined,
                        title: AppLanguage.t(
                          en: 'Change Location',
                          ko: '동네 변경',
                          ja: '地域変更',
                          es: 'Cambiar ubicación',
                          zh: '更改地区',
                        ),
                        subtitle: AppLanguage.t(
                          en: 'Set your activity area',
                          ko: '내 활동 지역 설정',
                          ja: '活動地域を設定',
                          es: 'Configura tu área de actividad',
                          zh: '设置您的活动区域',
                        ),
                        onTap: _showLocationDialog,
                      ),
                      _MenuItem(
                        icon: Icons.help_outline,
                        title: AppLanguage.t(
                          en: 'Help',
                          ko: '도움말',
                          ja: 'ヘルプ',
                          es: 'Ayuda',
                          zh: '帮助',
                        ),
                        subtitle: AppLanguage.t(
                          en: 'FAQ',
                          ko: '자주 묻는 질문',
                          ja: 'よくある質問',
                          es: 'Preguntas frecuentes',
                          zh: '常见问题',
                        ),
                        onTap: _showHelpDialog,
                      ),
                      _MenuItem(
                        icon: Icons.notifications_outlined,
                        title: AppLanguage.t(
                          en: 'Notifications',
                          ko: '알림 설정',
                          ja: '通知設定',
                          es: 'Notificaciones',
                          zh: '通知',
                        ),
                        subtitle: AppLanguage.t(
                          en: 'Manage push notifications',
                          ko: '푸시 알림 관리',
                          ja: 'プッシュ通知を管理',
                          es: 'Gestionar notificaciones push',
                          zh: '管理推送通知',
                        ),
                        onTap: _showNotificationDialog,
                      ),
                      const Divider(color: Color(0xFF1E2535)),
                      ListTile(
                        leading: const Icon(
                          Icons.logout,
                          color: Colors.redAccent,
                        ),
                        title: Text(
                          AppLanguage.t(
                            en: 'Logout',
                            ko: '로그아웃',
                            ja: 'ログアウト',
                            es: 'Cerrar sesión',
                            zh: '退出登录',
                          ),
                          style: const TextStyle(color: Colors.redAccent),
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
