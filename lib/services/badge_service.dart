import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/badge_model.dart';

class BadgeService {
  static final _db = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static String? get _uid => _auth.currentUser?.uid;

  static Future<List<String>> getEarnedBadgeIds() async {
    if (_uid == null) return [];
    final doc = await _db.collection('users').doc(_uid).get();
    final data = doc.data();
    if (data == null) return [];
    final badges = data['badges'] as List?;
    return badges?.map((e) => e['id'] as String).toList() ?? [];
  }

  static Future<Map<String, dynamic>?> getBadgeEntry(String badgeId) async {
    if (_uid == null) return null;
    final doc = await _db.collection('users').doc(_uid).get();
    final data = doc.data();
    if (data == null) return null;
    final badges = data['badges'] as List? ?? [];
    try {
      return badges.firstWhere((e) => e['id'] == badgeId)
          as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  static Future<void> awardBadge(String badgeId) async {
    if (_uid == null) return;
    final existing = await getBadgeEntry(badgeId);
    if (existing != null) return;
    await _db.collection('users').doc(_uid).update({
      'badges': FieldValue.arrayUnion([
        {'id': badgeId, 'earnedAt': DateTime.now().toIso8601String()},
      ]),
    });
  }

  static Future<void> equipBadge(String badgeId) async {
    if (_uid == null) return;
    await _db.collection('users').doc(_uid).set({
      'equippedBadge': badgeId,
    }, SetOptions(merge: true));
  }

  static Future<void> unequipBadge() async {
    if (_uid == null) return;
    await _db.collection('users').doc(_uid).update({
      'equippedBadge': FieldValue.delete(),
    });
  }

  static Future<String?> getEquippedBadgeId() async {
    if (_uid == null) return null;
    final doc = await _db.collection('users').doc(_uid).get();
    return doc.data()?['equippedBadge'] as String?;
  }

  static Future<List<String>> checkAndAwardBadges({
    required double totalKm,
    required int totalDonation,
    required int totalRuns,
    required int consecutiveDays,
    required int friendCount,
    required int completedChallenges,
    required bool hasTeam,
    required bool isTeamFounder,
    required int nightRuns,
    required int earlyRuns,
    required bool hasJoinedChallenge,
  }) async {
    final earned = await getEarnedBadgeIds();
    final newBadges = <String>[];

    Future<void> check(String id, bool condition) async {
      if (condition && !earned.contains(id)) {
        await awardBadge(id);
        newBadges.add(id);
      }
    }

    await check('first_run', totalRuns >= 1);
    await check('run_5km', totalKm >= 5);
    await check('run_10km', totalKm >= 10);
    await check('run_42km', totalKm >= 42.195);
    await check('run_100km', totalKm >= 100);
    await check('run_7days', consecutiveDays >= 7);
    await check('team_founder', isTeamFounder);
    await check('team_member', hasTeam);
    await check('friend_added', friendCount >= 1);
    await check('challenge_1', completedChallenges >= 1);
    await check('challenge_3', completedChallenges >= 3);
    await check('donation_first', totalDonation >= 1);
    await check('donation_1000', totalDonation >= 1000);
    await check('donation_10000', totalDonation >= 10000);
    await check('hidden_night_owl', nightRuns >= 3);
    await check('hidden_early_bird', earlyRuns >= 5);
    await check('hidden_marathon', totalKm >= 42.195 && !hasJoinedChallenge);

    return newBadges;
  }

  static Future<Map<String, double>> getBadgeProgress({
    required double totalKm,
    required int totalDonation,
    required int totalRuns,
    required int consecutiveDays,
    required int nightRuns,
    required int earlyRuns,
    required int completedChallenges,
  }) async {
    return {
      'first_run': (totalRuns / 1).clamp(0, 1),
      'run_5km': (totalKm / 5).clamp(0, 1),
      'run_10km': (totalKm / 10).clamp(0, 1),
      'run_42km': (totalKm / 42.195).clamp(0, 1),
      'run_100km': (totalKm / 100).clamp(0, 1),
      'run_7days': (consecutiveDays / 7).clamp(0, 1),
      'challenge_1': (completedChallenges / 1).clamp(0, 1),
      'challenge_3': (completedChallenges / 3).clamp(0, 1),
      'donation_first': (totalDonation / 1).clamp(0, 1),
      'donation_1000': (totalDonation / 1000).clamp(0, 1),
      'donation_10000': (totalDonation / 10000).clamp(0, 1),
      'hidden_night_owl': (nightRuns / 3).clamp(0, 1),
      'hidden_early_bird': (earlyRuns / 5).clamp(0, 1),
      'hidden_marathon': (totalKm / 42.195).clamp(0, 1),
    };
  }
}
