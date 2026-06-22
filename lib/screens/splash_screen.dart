import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../theme/app_colors.dart';
import '../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const _lottieAsset = 'assets/man running.json';
  static const _runnerWidth = 140.0;
  static const _runDuration = Duration(milliseconds: 4500);

  late final AnimationController _controller;
  Animation<double>? _position;
  bool _started = false;

  final List<String> _letters = ['S', 'T', 'E', 'P', 'G', 'I', 'V', 'E'];
  int _visibleLetters = 0;
  bool _showSubtitle = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _runDuration);
    _controller.addStatusListener(_onAnimationStatus);
    WidgetsBinding.instance.addPostFrameCallback((_) => _startRun());
  }

  void _startRun() {
    if (_started || !mounted) return;
    _started = true;

    final screenWidth = MediaQuery.sizeOf(context).width;
    _position = Tween<double>(
      begin: -_runnerWidth,
      end: screenWidth + _runnerWidth,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));

    setState(() {});
    _controller.forward();
    _startTyping();
  }

  void _startTyping() async {
    await Future.delayed(const Duration(milliseconds: 1200));
    for (int i = 0; i < _letters.length; i++) {
      if (!mounted) return;
      await Future.delayed(const Duration(milliseconds: 280));
      setState(() => _visibleLetters = i + 1);
    }
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;
    setState(() => _showSubtitle = true);
    await Future.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;
    _onAnimationStatus(AnimationStatus.completed);
  }

  void _onAnimationStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed || !mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 1050),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const AuthWrapper(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _skipToLogin() {
    _controller.stop();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const AuthWrapper()),
    );
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_onAnimationStatus);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final position = _position;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: IconButton(
              onPressed: _skipToLogin,
              icon: const Icon(Icons.close, color: Colors.white54),
            ),
          ),
        ],
      ),
      body: position == null
          ? const SizedBox.shrink()
          : AnimatedBuilder(
              animation: position,
              builder: (context, child) {
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      left: position.value,
                      bottom: screenHeight * 0.28,
                      child: child!,
                    ),
                    Positioned(
                      bottom: screenHeight * 0.38,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_letters.length, (i) {
                          return AnimatedOpacity(
                            opacity: i < _visibleLetters ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 200),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: Text(
                                _letters[i],
                                style: const TextStyle(
                                  color: Color(0xFF4DFFCC),
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    Positioned(
                      bottom: screenHeight * 0.32,
                      left: 0,
                      right: 0,
                      child: AnimatedOpacity(
                        opacity: _showSubtitle ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 600),
                        child: const Text(
                          '당신의 한 발자국이 이 세상을 바꿉니다',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xB3FFFFFF),
                            fontSize: 13,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
              child: Transform.flip(
                flipX: true,
                child: Lottie.asset(
                  _lottieAsset,
                  width: _runnerWidth,
                  repeat: true,
                  fit: BoxFit.contain,
                ),
              ),
            ),
    );
  }
}
