import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

import 'package:geolocator/geolocator.dart';

class RunningScreen extends StatefulWidget {
  RunningScreen({super.key});
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
    return "${m.toString().padLeft(2,'0')}:${s.toString().padLeft(2, '0')}";
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

  

  Future<void> _startStop() async{
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
            const SnackBar(content: Text('위치 권한이 필요해요!')),
          );
        }
        return;
      }
      setState(() => _isRunning = true);
      _lastPosition = null;

      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        setState(() => _seconds++);
      });
      _positionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 5,
        ),
      ). listen((Position pos) {
        if (_lastPosition != null) {
          final dist = Geolocator.distanceBetween(
            _lastPosition!.latitude,
            _lastPosition!.longitude,
            pos.latitude,
            pos.longitude,
          );
          setState(() => _distanceKm += dist / 1000);
        }
        _lastPosition = pos;
      });
    }
  }

  Future<void> _saveRun() async {
    final user = _auth.currentUser;
    if (user == null || _distanceKm < 0.01) return;

    final donation=_donation;
    final batch= _db.batch();

    final userRef = _db.collection('users').doc(user.uid);
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
      'createdAt': FieldValue.serverTimestamp()
    });

    await batch.commit();

    setState(() {
      _distanceKm = 0.0;
      _seconds = 0;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _positionStream?.cancel();
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
                  const Text(
                    '러닝',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _isRunning ? 'Running...' : 'Monday Morning Run',
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
                    style: TextStyle(
                      color: Color(0xB3FFFFFF),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _StatBox(label: '페이스', value: _pace),
                      const SizedBox(width: 8),
                      _StatBox(label: '시간', value: _time),
                      const SizedBox(width: 8),
                      _StatBox(
                        label: '기부금',
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
                  Container(
                    color: const Color(0xFF141824),
                    child: CustomPaint(
                      painter: _MapPainter(),
                      child: const SizedBox.expand(),
                    ),
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
                            Container(
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
                            Container(
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
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          '목표 설정',
                          style: TextStyle(
                            color: Color(0xFF8899AA),
                            fontSize: 12,
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
  const _StatBox ({required this.label, required this.value, this.valueColor = Colors.white});
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
            Text(label,style: const TextStyle(color: Color(0xFF8899AA), fontSize: 10)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(color: valueColor, fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
    ..color = const Color(0xFF1E2535)
    ..strokeWidth = 0.5;
    for (double y = 0; y < size.height; y += 44) {
      canvas.drawLine(Offset(0,y), Offset(size.width, y), gridPaint);
    }
    for (double x = 0; x < size.width; x += 44) {
      canvas.drawLine(Offset(x,0), Offset(x, size.height), gridPaint);
    }
    final blockPaint = Paint() ..color = const Color(0xFF1A2235);
    canvas.drawRect(Rect.fromLTWH(10, 20, 60, 30), blockPaint);
    canvas.drawRect(Rect.fromLTWH(80, 40, 50, 40), blockPaint);
    canvas.drawRect(Rect.fromLTWH(140, 25, 70, 28), blockPaint);
    canvas.drawRect(Rect.fromLTWH(20, 100, 80, 22), blockPaint);
    canvas.drawRect(Rect.fromLTWH(110, 90, 60, 35), blockPaint);
    canvas.drawRect(Rect.fromLTWH(10, 160, 45, 50), blockPaint);
    canvas.drawRect(Rect.fromLTWH(65, 150, 90, 32), blockPaint);
    canvas.drawRect(Rect.fromLTWH(160, 140, 55, 55), blockPaint);
    final routePaint = Paint()
    ..color = const Color(0xFF00C896)
    ..strokeWidth = 2.5
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(20, size.height * 0.75)
      ..lineTo(55, size.height * 0.55)
      ..lineTo(90, size.height * 0.65)
      ..lineTo(125, size.height * 0.35)
      ..lineTo(160, size.height * 0.45)
      ..lineTo(200, size.height * 0.25);
    canvas.drawPath(path, routePaint);
    canvas.drawCircle(
      Offset(20, size.height * 0.75), 5,
      Paint()..color = const Color(0xFF1D9E75),
    );
    canvas.drawCircle(
      Offset(200, size.height * 0.25), 6,
      Paint()..color = const Color(0xFF00C896),
    );
  }
  
  @override
  bool shouldRepaint(_MapPainter oldDelegate) => false;
}