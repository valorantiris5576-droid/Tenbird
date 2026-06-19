import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../widgets/glass_container.dart';
import '../services/weather_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.onGoToRunning, required this.onGoToChallenge});
  final VoidCallback onGoToRunning;
  final VoidCallback onGoToChallenge;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

final WeatherService _weatherService = WeatherService();

class _HomeScreenState extends State<HomeScreen> {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  String _timeString = '';
  String _dateString = '';
  Timer? _timer;
  String _temp = "로딩 중...";
  String _weatherDescription = "";

  Future<void> _signOut() async {
    await _auth.signOut();
  }

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) => _updateTime());
    _fetchWeatherData(37.5665, 126.9780);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateTime() {
    final DateTime now = DateTime.now();
    setState(() {
      _timeString = DateFormat('aa hh:mm', 'ko').format(now);
      _dateString = DateFormat('M월 d일 (E)', 'ko').format(now);
    });
  }

  Future<void> _fetchWeatherData(double lat, double lon) async {
    try {
      final data = await _weatherService.fetchWeather(lat, lon);
      final mainData = data['main'];
      final weatherArray = data['weather'] as List;
      setState(() {
        if (mainData != null) {
          _temp = "${(mainData['temp'] as num).round()}°C";
        }
        if (weatherArray.isNotEmpty) {
          _weatherDescription = weatherArray[0]['description'] ?? "";
        }
      });
    } catch (e) {
      setState(() {
        _temp = "에러";
        _weatherDescription = "날씨 로드 실패";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    final isGuest = user?.isAnonymous ?? false;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'StepGive',
                    style: TextStyle(
                      color: Color(0xFF00C896),
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        isGuest ? '게스트' : (user?.displayName ?? ''),
                        style: const TextStyle(color: Color(0xB3FFFFFF), fontSize: 14),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _signOut,
                        icon: const Icon(Icons.logout, color: Color(0xFF8899AA), size: 20),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              GlassContainer(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_timeString, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                          Text(_dateString, style: const TextStyle(fontSize: 14, color: Colors.white70)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.wb_sunny, color: Colors.orange, size: 28),
                              const SizedBox(width: 8),
                              Text(_temp, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                            ],
                          ),
                          Text(_weatherDescription, style: const TextStyle(fontSize: 14, color: Colors.white70)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              StreamBuilder<DocumentSnapshot>(
                stream: _db.collection('global').doc('stats').snapshots(),
                builder: (context, snapshot) {
                  final data = snapshot.data?.data() as Map?;
                  final total = data?['totalDonation'] ?? 0;
                  final totalKm = ((data?['totalDonation'] ?? 0) / 10).toStringAsFixed(0);
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111827),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0x4000C896)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('전체 기부 누적', style: TextStyle(color: Color(0xB3FFFFFF), fontSize: 13, letterSpacing: 0.5)),
                        const SizedBox(height: 10),
                        Text('₩ $total', style: const TextStyle(color: Color(0xFF00C896), fontSize: 40, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text('함께 달린 거리 ${totalKm}km', style: const TextStyle(color: Color(0xB3FFFFFF), fontSize: 12)),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 28),

              StreamBuilder<DocumentSnapshot>(
                stream: _db.collection('users').doc(user?.uid).snapshots(),
                builder: (context, snapshot) {
                  final data = snapshot.data?.data() as Map?;
                  final myDon = data?['totalDonation'] ?? 0;
                  final myKm = (data?['totalKm'] ?? 0.0);
                  final km = myKm is double ? myKm : (myKm as num).toDouble();
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111827),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0x10FFFFFF)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('내 기부금', style: TextStyle(color: Color(0xB3FFFFFF), fontSize: 13)),
                        const SizedBox(height: 8),
                        Text('₩ $myDon', style: const TextStyle(color: Color(0xFF00C896), fontSize: 28, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('총 ${km.toStringAsFixed(1)}km 달림', style: const TextStyle(color: Color(0xB3FFFFFF), fontSize: 12)),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFF111827),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0x10FFFFFF)),
                ),
                child: const Center(
                  child: Text('1km를 달릴 때마다  10원이 기부됩니다', style: TextStyle(color: Color(0xB3FFFFFF), fontSize: 13)),
                ),
              ),
              const SizedBox(height: 20),

              GestureDetector(
                onTap: widget.onGoToChallenge,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111827),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF00C896).withValues(alpha: 0.4)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('🏆 챌린지', style: TextStyle(color: Color(0xFF00C896), fontSize: 12, fontWeight: FontWeight.w500)),
                          SizedBox(height: 4),
                          Text('여름을 시원하게 날려줄 챌린지', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                          SizedBox(height: 2),
                          Text('달성하면 기부금 보너스!', style: TextStyle(color: Color(0xB3FFFFFF), fontSize: 12)),
                        ],
                      ),
                      Icon(Icons.arrow_forward_ios, color: Color(0xFF00C896), size: 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: widget.onGoToRunning,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C896),
                    foregroundColor: const Color(0xFF0A0E1A),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text('지금 달리러 가기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}