import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'screens/main_screen.dart';
import 'screens/login_screen.dart';
import 'screens/coach_intro_screen.dart';
import 'widgets/coach_overlay.dart';
import 'app_language_notifier.dart';
import 'app_language.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('ko', null);
  runApp(const StepGiveApp());
}

class StepGiveApp extends StatefulWidget {
  const StepGiveApp({super.key});
  @override
  State<StepGiveApp> createState() => _StepGiveAppState();
}

class _StepGiveAppState extends State<StepGiveApp> {
  @override
  void initState() {
    super.initState();
    AppLanguageNotifier.instance.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StepGive',
      debugShowCheckedModeBanner: false,
      navigatorKey: coachNavigatorKey,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF0A0E1A),
        colorScheme: const ColorScheme.dark(primary: Color(0xFF00C896)),
      ),
      home: const SplashScreen(),
      builder: (context, child) {
        return Stack(
          children: [?child, const _GlobalCoachHost(), const _EchoRevealHost()],
        );
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF050810),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF00C896)),
            ),
          );
        }
        if (snapshot.hasData) return const MainScreen();
        return const LoginScreen();
      },
    );
  }
}

class _GlobalCoachHost extends StatefulWidget {
  const _GlobalCoachHost();
  @override
  State<_GlobalCoachHost> createState() => _GlobalCoachHostState();
}

class _GlobalCoachHostState extends State<_GlobalCoachHost> {
  bool _showOverlay = false;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) _check();
    });
    coachRestartNotifier.addListener(_forceReplay);
  }

  @override
  void dispose() {
    coachRestartNotifier.removeListener(_forceReplay);
    super.dispose();
  }

  Future<void> _check() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    final seen = doc.data()?['onboardingSeen'] ?? false;
    if (!seen && mounted) {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'onboardingSeen': true,
      }, SetOptions(merge: true));
      await _playIntro();
    }
  }

  Future<void> _forceReplay() async {
    if (!mounted) return;
    setState(() => _showOverlay = false);
    await _playIntro();
  }

  Future<void> _playIntro() async {
    final nav = coachNavigatorKey.currentState;
    if (nav == null) return;
    await nav.push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, _, _) => CoachIntroScreen(onDone: () => nav.pop()),
        transitionsBuilder: (_, anim, _, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
    if (mounted) setState(() => _showOverlay = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_showOverlay) return const SizedBox.shrink();
    return const CoachOverlay();
  }
}

class _EchoRevealHost extends StatefulWidget {
  const _EchoRevealHost();
  @override
  State<_EchoRevealHost> createState() => _EchoRevealHostState();
}

class _EchoRevealHostState extends State<_EchoRevealHost> {
  bool _checked = false;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null && !_checked) {
        _checked = true;
        _checkEchoes(user.uid);
      }
    });
  }

  Future<void> _checkEchoes(String uid) async {
    final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('echoes')
        .where('shown', isEqualTo: false)
        .where('revealAt', isLessThanOrEqualTo: Timestamp.now())
        .get();
    for (final doc in snap.docs) {
      await _showLetter(doc);
    }
  }

  Future<void> _showLetter(QueryDocumentSnapshot doc) async {
    final data = doc.data() as Map;
    final text = data['text'] as String? ?? '';
    final createdAt = data['createdAt'] as Timestamp?;
    final distanceKm = ((data['distanceKm'] ?? 0.0) as num).toDouble();
    final dateStr = createdAt != null
        ? '${createdAt.toDate().year}.${createdAt.toDate().month.toString().padLeft(2, '0')}.${createdAt.toDate().day.toString().padLeft(2, '0')}'
        : '';
    final dialogContext = coachNavigatorKey.currentContext;
    if (dialogContext == null) return;
    await showDialog(
      context: dialogContext,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF141824),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          AppLanguage.t(
            en: 'A letter from a year ago',
            ko: '1년 전 오늘, 너가 남긴 말이야',
            ja: '1年前の今日、あなたが残した言葉だよ',
            es: 'Una carta de hace un año',
            zh: '一年前的今天，你留下的话',
          ),
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (dateStr.isNotEmpty)
              Text(
                distanceKm > 0
                    ? '$dateStr · ${distanceKm.toStringAsFixed(1)}km'
                    : dateStr,
                style: const TextStyle(color: Color(0xFF8899AA), fontSize: 12),
              ),
            const SizedBox(height: 10),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                height: 1.6,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              AppLanguage.t(
                en: 'Thanks, past me',
                ko: '고마워, 그때의 나',
                ja: 'ありがとう、あの日の自分',
                es: 'Gracias, yo del pasado',
                zh: '谢谢，那时的我',
              ),
              style: const TextStyle(
                color: Color(0xFF00C896),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
    await doc.reference.update({'shown': true});
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
