import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../app_language.dart';

class RunningScreen extends StatefulWidget {
  const RunningScreen({super.key});
  @override
  State<RunningScreen> createState() => _RunningScreenState();
}

class _RunningScreenState extends State<RunningScreen> {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  bool _isRunning = false;
  double _distanceKm = 0.0;
  int _seconds = 0;
  Timer? _timer;
  Position? _lastPosition;
  StreamSubscription<Position>? _positionStream;
  LatLng _currentLatLng = const LatLng(37.5665, 126.9780);
  final MapController _mapController = MapController();
  final List<LatLng> _routePoints = [];

  int get _donation => (_distanceKm * 10).floor();

  String get _pace {
    if (_distanceKm == 0 || _seconds == 0) return "--'--\"";
    final paceSeconds = (_seconds / _distanceKm).round();
    final m = paceSeconds ~/ 60;
    final s = paceSeconds % 60;
    return "$m'${s.toString().padLeft(2, '0')}\"";
  }

  String get _time {
    final m = _seconds ~/ 60;
    final s = _seconds % 60;
    return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }

  Future<bool> _checkPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }
    if (permission == LocationPermission.deniedForever) return false;
    return true;
  }

  void _showComingSoon() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF141824),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          AppLanguage.t(
            en: 'Coming Soon',
            ko: '준비 중',
            ja: '準備中',
            es: 'Próximamente',
            zh: '即将推出',
          ),
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          AppLanguage.t(
            en: 'This feature is coming soon!',
            ko: '이 기능은 준비중이에요!',
            ja: 'この機能は準備中です！',
            es: '¡Esta función estará disponible pronto!',
            zh: '此功能即将推出！',
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

  Future<void> _startStop() async {
    if (_isRunning) {
      _timer?.cancel();
      _positionStream?.cancel();
      setState(() => _isRunning = false);
      _saveRun();
    } else {
      final ok = await _checkPermission();
      if (!ok) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLanguage.t(
                  en: 'Location permission required!',
                  ko: '위치 권한이 필요해요!',
                  ja: '位置情報の許可が必要です！',
                  es: '¡Se requiere permiso de ubicación!',
                  zh: '需要位置权限！',
                ),
              ),
            ),
          );
        }
        return;
      }
      setState(() {
        _isRunning = true;
        _routePoints.clear();
      });
      _lastPosition = null;

      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        setState(() => _seconds++);
      });

      _positionStream =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 5,
            ),
          ).listen((Position pos) {
            final newLatLng = LatLng(pos.latitude, pos.longitude);
            if (_lastPosition != null) {
              final dist = Geolocator.distanceBetween(
                _lastPosition!.latitude,
                _lastPosition!.longitude,
                pos.latitude,
                pos.longitude,
              );
              setState(() {
                _distanceKm += dist / 1000;
                _currentLatLng = newLatLng;
                _routePoints.add(newLatLng);
              });
              _mapController.move(newLatLng, 15);
            } else {
              setState(() {
                _currentLatLng = newLatLng;
                _routePoints.add(newLatLng);
              });
              _mapController.move(newLatLng, 15);
            }
            _lastPosition = pos;
          });
    }
  }

  Future<void> _saveRun() async {
    final user = _auth.currentUser;
    if (user == null || _distanceKm < 0.01) return;

    final donation = _donation;
    final userRef = _db.collection('users').doc(user.uid);

    final batch = _db.batch();

    batch.set(userRef, {
      'totalDonation': FieldValue.increment(donation),
      'totalKm': FieldValue.increment(_distanceKm),
    }, SetOptions(merge: true));

    final globalRef = _db.collection('global').doc('stats');
    batch.set(globalRef, {
      'totalDonation': FieldValue.increment(donation),
    }, SetOptions(merge: true));

    final runRef = _db
        .collection('users')
        .doc(user.uid)
        .collection('runs')
        .doc();
    batch.set(runRef, {
      'distanceKm': _distanceKm,
      'seconds': _seconds,
      'donation': donation,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();

    final savedDistance = _distanceKm;

    setState(() {
      _distanceKm = 0.0;
      _seconds = 0;
      _routePoints.clear();
    });

    if (mounted) {
      _showEchoPrompt(user.uid, savedDistance);
    }
  }

  void _showEchoPrompt(String uid, double distanceKm) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF141824),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          AppLanguage.t(
            en: 'Nice work today!',
            ko: '수고했어 오늘도!',
            ja: '今日もお疲れさま！',
            es: '¡Buen trabajo hoy!',
            zh: '今天辛苦了！',
          ),
          style: const TextStyle(color: Colors.white, fontSize: 17),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLanguage.t(
                en: 'Leave a note for yourself, 1 year from now.',
                ko: '1년 후의 나에게 한마디 남겨볼래?',
                ja: '1年後の自分にひとこと残そう。',
                es: 'Déjate una nota para dentro de 1 año.',
                zh: '给一年后的自己留句话吧。',
              ),
              style: const TextStyle(color: Color(0xB3FFFFFF), fontSize: 13),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: AppLanguage.t(
                  en: 'Write a short note...',
                  ko: '짧게 남겨봐...',
                  ja: '短く書いてみて...',
                  es: 'Escribe algo corto...',
                  zh: '写几句话...',
                ),
                hintStyle: const TextStyle(color: Color(0xFF4A5568)),
                filled: true,
                fillColor: const Color(0xFF0A0E1A),
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
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              AppLanguage.t(
                en: 'Skip',
                ko: '건너뛰기',
                ja: 'スキップ',
                es: 'Omitir',
                zh: '跳过',
              ),
              style: const TextStyle(color: Color(0xFF8899AA)),
            ),
          ),
          TextButton(
            onPressed: () async {
              final text = controller.text.trim();
              Navigator.pop(ctx);
              if (text.isEmpty) return;
              final now = DateTime.now();
              await _db.collection('users').doc(uid).collection('echoes').add({
                'text': text,
                'distanceKm': distanceKm,
                'createdAt': FieldValue.serverTimestamp(),
                'revealAt': Timestamp.fromDate(
                  now.add(const Duration(days: 365)),
                ),
                'shown': false,
              });
            },
            child: Text(
              AppLanguage.t(
                en: 'Save',
                ko: '저장',
                ja: '保存',
                es: 'Guardar',
                zh: '保存',
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
  }

  @override
  void dispose() {
    _timer?.cancel();
    _positionStream?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLanguage.t(
                      en: 'Running',
                      ko: '러닝',
                      ja: 'ランニング',
                      es: 'Correr',
                      zh: '跑步',
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _isRunning
                        ? AppLanguage.t(
                            en: 'Running...',
                            ko: '달리는 중...',
                            ja: '走っています...',
                            es: 'Corriendo...',
                            zh: '跑步中...',
                          )
                        : AppLanguage.t(
                            en: 'Ready to run!',
                            ko: '달릴 준비 됐나요?',
                            ja: '走る準備はできていますか？',
                            es: '¡Listo para correr!',
                            zh: '准备好跑步了吗？',
                          ),
                    style: const TextStyle(
                      color: Color(0xB3FFFFFF),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _distanceKm.toStringAsFixed(2),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 52,
                      fontWeight: FontWeight.bold,
                      height: 1,
                    ),
                  ),
                  const Text(
                    'km',
                    style: TextStyle(color: Color(0xB3FFFFFF), fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _StatBox(
                        label: AppLanguage.t(
                          en: 'Pace',
                          ko: '페이스',
                          ja: 'ペース',
                          es: 'Ritmo',
                          zh: '配速',
                        ),
                        value: _pace,
                      ),
                      const SizedBox(width: 8),
                      _StatBox(
                        label: AppLanguage.t(
                          en: 'Time',
                          ko: '시간',
                          ja: '時間',
                          es: 'Tiempo',
                          zh: '时间',
                        ),
                        value: _time,
                      ),
                      const SizedBox(width: 8),
                      _StatBox(
                        label: AppLanguage.t(
                          en: 'Donation',
                          ko: '기부금',
                          ja: '寄付金',
                          es: 'Donación',
                          zh: '捐款',
                        ),
                        value: '₩$_donation',
                        valueColor: const Color(0xFF00C896),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _currentLatLng,
                      initialZoom: 17,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.run_donate',
                      ),
                      if (_routePoints.length > 1)
                        PolylineLayer(
                          polylines: [
                            Polyline(
                              points: _routePoints,
                              strokeWidth: 4,
                              color: const Color(0xFF00C896),
                            ),
                          ],
                        ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _currentLatLng,
                            width: 20,
                            height: 20,
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Color(0xFF00C896),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Positioned(
                    bottom: 24,
                    left: 0,
                    right: 0,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              onTap: _showComingSoon,
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF141824),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFF1E2535),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.settings,
                                  color: Color(0xFF8899AA),
                                  size: 20,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: _startStop,
                              child: Container(
                                width: 72,
                                height: 72,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF00C896),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _isRunning ? Icons.stop : Icons.play_arrow,
                                  color: const Color(0xFF0A0E1A),
                                  size: 36,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: _showComingSoon,
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF141824),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFF1E2535),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.music_note,
                                  color: Color(0xFF8899AA),
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: _showComingSoon,
                          child: Text(
                            AppLanguage.t(
                              en: 'Set Goal',
                              ko: '목표 설정',
                              ja: '目標設定',
                              es: 'Establecer meta',
                              zh: '设定目标',
                            ),
                            style: const TextStyle(
                              color: Color(0xFF8899AA),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
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
}

class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.label,
    required this.value,
    this.valueColor = Colors.white,
  });
  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF141824),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF1E2535)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(color: Color(0xFF8899AA), fontSize: 10),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: valueColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
