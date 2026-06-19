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
  static const _runDuration = Duration(milliseconds: 3700);

  late final AnimationController _controller;
  Animation<double>? _position;
  bool _started = false;

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
  }

  void _onAnimationStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed || !mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 1050),
        pageBuilder: (context, animation, secondaryAnimation) => const AuthWrapper(),
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