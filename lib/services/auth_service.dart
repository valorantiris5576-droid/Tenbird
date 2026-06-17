import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class AuthService {
  AuthService._();

  static final _auth = FirebaseAuth.instance;
  static final _users = FirebaseFirestore.instance.collection('users');

  static Future<void> signIn({
    required String username,
    required String email,
    required String password,
  }) async {
    final normalizedUsername = username.trim();
    final normalizedEmail = email.trim().toLowerCase();

    final match = await _users
        .where('email', isEqualTo: normalizedEmail)
        .where('username', isEqualTo: normalizedUsername)
        .limit(1)
        .get();

    if (match.docs.isEmpty) {
      throw FirebaseAuthException(
        code: 'invalid-credential',
        message: 'Username and email do not match our records.',
      );
    }

    await _auth.signInWithEmailAndPassword(
      email: normalizedEmail,
      password: password,
    );
  }

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

  static Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim().toLowerCase());
  }

  static Future<void> signInWithFacebook() async {
    final result = await FacebookAuth.instance.login(
      permissions: ['email', 'public_profile'],
    );

    if (result.status == LoginStatus.cancelled) {
      throw FirebaseAuthException(
        code: 'facebook-login-cancelled',
        message: 'Facebook login was cancelled.',
      );
    }

    if (result.status != LoginStatus.success || result.accessToken == null) {
      throw FirebaseAuthException(
        code: 'facebook-login-failed',
        message: 'Facebook login failed. Please try again.',
      );
    }

    final credential = FacebookAuthProvider.credential(
      result.accessToken!.tokenString,
    );
    final userCredential = await _auth.signInWithCredential(credential);
    final user = userCredential.user;

    if (user == null) return;

    final doc = await _users.doc(user.uid).get();
    if (doc.exists) return;

    final profile = await FacebookAuth.instance.getUserData();
    final username = (profile['name'] as String?)?.trim();
    final email = (profile['email'] as String?)?.trim().toLowerCase() ??
        user.email?.toLowerCase();

    await _users.doc(user.uid).set({
      'username': username?.isNotEmpty == true ? username : 'user_${user.uid.substring(0, 6)}',
      'email': email ?? '',
      'createdAt': FieldValue.serverTimestamp(),
      'provider': 'facebook',
    });
  }

  static String messageFor(FirebaseAuthException e) {
    return switch (e.code) {
      'invalid-email' => 'Please enter a valid email address.',
      'invalid-credential' ||
      'user-not-found' ||
      'wrong-password' =>
        'Invalid username, email, or password.',
      'username-already-in-use' => 'This username is already taken.',
      'email-already-in-use' => 'An account with this email already exists.',
      'weak-password' => 'Password must be at least 6 characters.',
      'user-disabled' => 'This account has been disabled.',
      'facebook-login-cancelled' => 'Facebook login was cancelled.',
      'facebook-login-failed' => 'Facebook login failed. Please try again.',
      _ => e.message ?? 'Something went wrong. Please try again.',
    };
  }
}
