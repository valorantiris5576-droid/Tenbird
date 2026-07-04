import 'dart:async';
import '../app_language.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../widgets/glass_container.dart';
import '../services/weather_service.dart';
import '../app_language.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.onGoToRunning,
    required this.onGoToChallenge,
  });
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
  String _temp = "Loading...";
  String _weatherDescription = "";
  late final String _randomQuote;

  List<String> get _quotes => [
    AppLanguage.t(
      en: 'Every 1km you run, 10 won is donated',
      ko: '1km를 달릴 때마다 10원이 기부됩니다',
      ja: '1kmごとに10ウォンが寄付されます',
      es: 'Por cada 1km, se donan 10 wones',
      zh: '每跑1公里，捐赠10韩元',
    ),
    AppLanguage.t(
      en: 'One step at a time, one step for the world',
      ko: '오늘도 한 걸음, 세상도 한 걸음',
      ja: '一歩一歩、世界も一歩',
      es: 'Un paso a la vez, un paso para el mundo',
      zh: '一步一步，世界也在前进',
    ),
    AppLanguage.t(
      en: 'The more you run, the more you change the world',
      ko: '달리는 만큼 세상이 바뀝니다',
      ja: '走るほど、世界が変わります',
      es: 'Cuanto más corres, más cambias el mundo',
      zh: '跑得越多，世界改变越多',
    ),
    AppLanguage.t(
      en: 'Your sweat becomes someone else\'s hope',
      ko: '당신의 땀이 누군가의 희망이 됩니다',
      ja: 'あなたの汗が誰かの希望になります',
      es: 'Tu sudor se convierte en la esperanza de alguien',
      zh: '你的汗水成为他人的希望',
    ),
    AppLanguage.t(
      en: 'Small steps create big changes',
      ko: '작은 발걸음이 큰 변화를 만듭니다',
      ja: '小さな一歩が大きな変化を生む',
      es: 'Pequeños pasos crean grandes cambios',
      zh: '小步伐创造大变化',
    ),
    AppLanguage.t(
      en: 'Together we can go further',
      ko: '함께 달리면 더 멀리 갈 수 있어요',
      ja: '一緒に走ればもっと遠くへ行ける',
      es: 'Juntos podemos llegar más lejos',
      zh: '一起跑，可以走得更远',
    ),
  ];

  Future<void> _signOut() async {
    await _auth.signOut();
  }

  @override
  void initState() {
    super.initState();
    _randomQuote = _quotes[Random().nextInt(_quotes.length)];
    _updateTime();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer t) => _updateTime(),
    );
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
      _timeString = DateFormat('hh:mm aa').format(now);
      _dateString = DateFormat('MMM d (E)').format(now);
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
        _temp = "Error";
        _weatherDescription = "Failed to load weather";
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
                        isGuest
                            ? AppLanguage.t(
                                en: 'Guest',
                                ko: '게스트',
                                ja: 'ゲスト',
                                es: 'Invitado',
                                zh: '访客',
                              )
                            : (user?.displayName ?? ''),
                        style: const TextStyle(
                          color: Color(0xB3FFFFFF),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _signOut,
                        icon: const Icon(
                          Icons.logout,
                          color: Color(0xFF8899AA),
                          size: 20,
                        ),
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
                          Text(
                            _timeString,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            _dateString,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.wb_sunny,
                                color: Colors.orange,
                                size: 28,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _temp,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            _weatherDescription,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
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
                  if (!snapshot.hasData) return const SizedBox();
                  final data = snapshot.data?.data() as Map?;
                  if (data == null) return const SizedBox();
                  final total = data['totalDonation'] ?? 0;
                  final totalKm = (total / 10).toStringAsFixed(0);
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
                        Text(
                          AppLanguage.t(
                            en: 'Total Donations',
                            ko: '전체 기부 누적',
                            ja: '総寄付額',
                            es: 'Donaciones totales',
                            zh: '总捐款',
                          ),
                          style: const TextStyle(
                            color: Color(0xB3FFFFFF),
                            fontSize: 13,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '₩ $total',
                          style: const TextStyle(
                            color: Color(0xFF00C896),
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          AppLanguage.t(
                            en: 'Distance run together: ${totalKm}km',
                            ko: '함께 달린 거리 ${totalKm}km',
                            ja: '一緒に走った距離: ${totalKm}km',
                            es: 'Distancia recorrida juntos: ${totalKm}km',
                            zh: '共同跑过的距离: ${totalKm}km',
                          ),
                          style: const TextStyle(
                            color: Color(0xB3FFFFFF),
                            fontSize: 12,
                          ),
                        ),
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
                        Text(
                          AppLanguage.t(
                            en: 'My Donations',
                            ko: '내 기부금',
                            ja: '私の寄付',
                            es: 'Mis donaciones',
                            zh: '我的捐款',
                          ),
                          style: const TextStyle(
                            color: Color(0xB3FFFFFF),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '₩ $myDon',
                          style: const TextStyle(
                            color: Color(0xFF00C896),
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppLanguage.t(
                            en: 'Total distance: ${km.toStringAsFixed(1)}km',
                            ko: '총 ${km.toStringAsFixed(1)}km 달림',
                            ja: '合計距離: ${km.toStringAsFixed(1)}km',
                            es: 'Distancia total: ${km.toStringAsFixed(1)}km',
                            zh: '总距离: ${km.toStringAsFixed(1)}km',
                          ),
                          style: const TextStyle(
                            color: Color(0xB3FFFFFF),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF111827),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0x10FFFFFF)),
                ),
                child: Center(
                  child: Text(
                    _randomQuote,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xB3FFFFFF),
                      fontSize: 13,
                    ),
                  ),
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
                    border: Border.all(
                      color: const Color(0xFF00C896).withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLanguage.t(
                              en: 'Challenge',
                              ko: '챌린지',
                              ja: 'チャレンジ',
                              es: 'Desafío',
                              zh: '挑战',
                            ),
                            style: const TextStyle(
                              color: Color(0xFF00C896),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppLanguage.t(
                              en: 'Cool challenges for this summer!',
                              ko: '여름을 시원하게 날려줄 챌린지',
                              ja: '夏を盛り上げるチャレンジ！',
                              es: '¡Desafíos geniales para este verano!',
                              zh: '夏日挑战来袭！',
                            ),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            AppLanguage.t(
                              en: 'Bonus donations when you complete!',
                              ko: '달성하면 기부금 보너스!',
                              ja: '達成したら寄付ボーナス！',
                              es: '¡Donaciones extra al completar!',
                              zh: '完成后获得额外捐款！',
                            ),
                            style: const TextStyle(
                              color: Color(0xB3FFFFFF),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: Color(0xFF00C896),
                        size: 16,
                      ),
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    AppLanguage.t(
                      en: 'Start Running!',
                      ko: '지금 달리러 가기',
                      ja: '走り始める！',
                      es: '¡Empezar a correr!',
                      zh: '开始跑步！',
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
