import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_container.dart';
import 'sign_up_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isGuestLoading = false;
  bool _isGoogleLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      await AuthService.signIn(
        username: _usernameController.text,
        password: _passwordController.text,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = AuthService.messageFor(e));
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Something went wrong.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() { _isGoogleLoading = true; _errorMessage = null; });
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() => _isGoogleLoading = false);
        return;
      }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Google login failed.');
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  Future<void> _loginAsGuest() async {
    setState(() { _isGuestLoading = true; _errorMessage = null; });
    try {
      await FirebaseAuth.instance.signInAnonymously();
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Guest login failed.');
    } finally {
      if (mounted) setState(() => _isGuestLoading = false);
    }
  }

  Future<void> _showForgotPasswordDialog() async {
    final usernameController = TextEditingController();
    final emailController = TextEditingController();
    String? dialogError;
    bool sending = false;
    bool step2 = false;

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF141B2D),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            step2 ? 'Verify Your Identity' : 'Forgot Password?',
            style: const TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                step2
                    ? 'Enter the email address linked to your account.'
                    : 'Enter your username to get started.',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 16),
              if (!step2)
                TextField(
                  controller: usernameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Username',
                    labelStyle: const TextStyle(color: AppColors.textSecondary),
                    prefixIcon: const Icon(Icons.person_outline, color: AppColors.textSecondary),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.accent),
                    ),
                  ),
                ),
              if (step2)
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: const TextStyle(color: AppColors.textSecondary),
                    prefixIcon: const Icon(Icons.email_outlined, color: AppColors.textSecondary),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.accent),
                    ),
                  ),
                ),
              if (dialogError != null) ...[
                const SizedBox(height: 12),
                Text(dialogError!, style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: sending ? null : () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
            ),
            TextButton(
              onPressed: sending ? null : () async {
                if (!step2) {
                  final username = usernameController.text.trim();
                  if (username.isEmpty) {
                    setDialogState(() => dialogError = 'Enter your username.');
                    return;
                  }
                  setDialogState(() { sending = true; dialogError = null; });
                  final exists = await AuthService.usernameExists(username);
                  if (!exists) {
                    setDialogState(() { sending = false; dialogError = 'Username not found.'; });
                    return;
                  }
                  setDialogState(() { sending = false; step2 = true; });
                } else {
                  final email = emailController.text.trim();
                  if (email.isEmpty || !email.contains('@')) {
                    setDialogState(() => dialogError = 'Enter a valid email.');
                    return;
                  }
                  setDialogState(() { sending = true; dialogError = null; });
                  try {
                    await AuthService.sendPasswordResetWithEmailUpdate(
                      usernameController.text.trim(),
                      email,
                    );
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Reset link sent! Check your inbox.')),
                    );
                  } on FirebaseAuthException catch (e) {
                    setDialogState(() { sending = false; dialogError = AuthService.messageFor(e); });
                  } catch (_) {
                    setDialogState(() { sending = false; dialogError = 'Could not send reset email.'; });
                  }
                }
              },
              child: sending
                  ? const SizedBox(width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent))
                  : Text(step2 ? 'Send' : 'Next', style: const TextStyle(color: AppColors.accent)),
            ),
          ],
        ),
      ),
    );
    usernameController.dispose();
    emailController.dispose();
  }

  void _goToSignUp() {
    Navigator.of(context).push(PageRouteBuilder<void>(
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) => const SignUpScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          FadeTransition(opacity: animation, child: child),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final busy = _isLoading || _isGuestLoading || _isGoogleLoading;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const _LoginBackground(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Column(
                  children: [
                    const Text('StepGive',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: GlassContainer(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text('Welcome',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              GlassTextField(
                                controller: _usernameController,
                                label: 'Username',
                                icon: Icons.person_outline,
                                textInputAction: TextInputAction.next,
                                validator: (v) => v == null || v.trim().isEmpty ? 'Username is required' : null,
                              ),
                              const SizedBox(height: 10),
                              GlassTextField(
                                controller: _passwordController,
                                label: 'Password',
                                icon: Icons.lock_outline,
                                obscureText: _obscurePassword,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) => _login(),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                    color: AppColors.textSecondary,
                                  ),
                                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'Password is required';
                                  if (v.length < 6) return 'At least 6 characters';
                                  return null;
                                },
                              ),
                              if (_errorMessage != null) ...[
                                const SizedBox(height: 8),
                                Text(_errorMessage!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                                ),
                              ],
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  // Google 로그인 버튼
                                  Expanded(
                                    child: _SocialButton(
                                      label: 'Google',
                                      icon: Icons.g_mobiledata,
                                      iconColor: Colors.white,
                                      borderColor: Colors.white24,
                                      backgroundColor: Colors.white.withValues(alpha: 0.08),
                                      isLoading: _isGoogleLoading,
                                      onPressed: busy ? null : _loginWithGoogle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Guest 로그인 버튼
                                  Expanded(
                                    child: _SocialButton(
                                      label: 'Guest',
                                      icon: Icons.person_outline,
                                      iconColor: Colors.white54,
                                      borderColor: Colors.white24,
                                      backgroundColor: Colors.white.withValues(alpha: 0.05),
                                      isLoading: _isGuestLoading,
                                      onPressed: busy ? null : _loginAsGuest,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: busy ? null : _login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.accent,
                                    foregroundColor: AppColors.background,
                                    disabledBackgroundColor: AppColors.accent.withValues(alpha: 0.5),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(width: 22, height: 22,
                                          child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.background))
                                      : const Text('Login', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TextButton(
                                    onPressed: busy ? null : _showForgotPasswordDialog,
                                    child: const Text('Forgot password?', style: TextStyle(color: AppColors.textSecondary)),
                                  ),
                                  Container(width: 1, height: 16, color: Colors.white.withValues(alpha: 0.2)),
                                  TextButton(
                                    onPressed: busy ? null : _goToSignUp,
                                    child: const Text('Sign Up', style: TextStyle(color: AppColors.accent)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginBackground extends StatelessWidget {
  const _LoginBackground();
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: AppColors.background),
        Positioned(top: -80, right: -60,
          child: Container(width: 260, height: 260,
            decoration: BoxDecoration(shape: BoxShape.circle,
              color: AppColors.accent.withValues(alpha: 0.12)))),
        Positioned(bottom: -100, left: -80,
          child: Container(width: 300, height: 300,
            decoration: BoxDecoration(shape: BoxShape.circle,
              color: const Color(0xFF1A3A5C).withValues(alpha: 0.5)))),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label, required this.icon, required this.iconColor,
    required this.borderColor, required this.backgroundColor,
    required this.isLoading, required this.onPressed,
  });
  final String label;
  final IconData icon;
  final Color iconColor, borderColor, backgroundColor;
  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: BorderSide(color: borderColor),
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(horizontal: 8),
        ),
        child: isLoading
            ? SizedBox(width: 18, height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: iconColor))
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: iconColor, size: 20),
                  const SizedBox(width: 6),
                  Flexible(child: Text(label, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13))),
                ],
              ),
      ),
    );
  }
}