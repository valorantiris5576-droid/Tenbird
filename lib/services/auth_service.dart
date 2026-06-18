import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService._();

  static final _auth = FirebaseAuth.instance;
  static final _users = FirebaseFirestore.instance.collection('users');

  // 유저네임으로 로그인
  static Future<void> signIn({
    required String username,
    required String password,
  }) async {
    final normalizedUsername = username.trim();
    final match = await _users
        .where('username', isEqualTo: normalizedUsername)
        .limit(1)
        .get();
    if (match.docs.isEmpty) {
      throw FirebaseAuthException(
        code: 'invalid-credential',
        message: 'Username not found.',
      );
    }
    final email = match.docs.first['email'] as String;
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  // 회원가입
  static Future<void> signUp({
    required String username,
    required String email,
    required String password,
  }) async {
    final normalizedUsername = username.trim();
    final normalizedEmail = email.trim().toLowerCase();

    final usernameTaken = await _users
        .where('username', isEqualTo: normalizedUsername)
        .limit(1)
        .get();
    if (usernameTaken.docs.isNotEmpty) {
      throw FirebaseAuthException(
        code: 'username-already-in-use',
        message: 'This username is already taken.',
      );
    }

    final credential = await _auth.createUserWithEmailAndPassword(
      email: normalizedEmail,
      password: password,
    );
    final user = credential.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'Account could not be created.',
      );
    }
    await user.updateDisplayName(normalizedUsername);
    await _users.doc(user.uid).set({
      'username': normalizedUsername,
      'email': normalizedEmail,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // username 존재 확인
  static Future<bool> usernameExists(String username) async {
    final match = await _users
        .where('username', isEqualTo: username.trim())
        .limit(1)
        .get();
    return match.docs.isNotEmpty;
  }

  // username + email 확인 후 재설정 링크 발송
  static Future<void> sendPasswordResetWithEmailUpdate(String username, String email) async {
    final normalizedEmail = email.trim().toLowerCase();
    final normalizedUsername = username.trim();

    final match = await _users
        .where('username', isEqualTo: normalizedUsername)
        .limit(1)
        .get();

    if (match.docs.isEmpty) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'Username not found.',
      );
    }

    final storedEmail = match.docs.first['email'] as String;

    // 가입할 때 쓴 이메일이랑 비교
    if (storedEmail != normalizedEmail) {
      throw FirebaseAuthException(
        code: 'invalid-credential',
        message: 'Email does not match our records.',
      );
    }

    // 같으면 재설정 링크 발송
    await _auth.sendPasswordResetEmail(email: storedEmail);
  }

  // 오류 메시지
  static String messageFor(FirebaseAuthException e) {
    return switch (e.code) {
      'invalid-email' => 'Please enter a valid email address.',
      'invalid-credential' ||
      'user-not-found' ||
      'wrong-password' => 'Invalid username or password.',
      'username-already-in-use' => 'This username is already taken.',
      'email-already-in-use' => 'An account with this email already exists.',
      'weak-password' => 'Password must be at least 6 characters.',
      'user-disabled' => 'This account has been disabled.',
      _ => e.message ?? 'Something went wrong. Please try again.',
    };
  }
}