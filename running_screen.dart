import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
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
            const SnackBar(content: Text('위치 권한이 필요해요!')),
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

      _positionStream = Geolocator.getPositionStream(
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
    final batch = _db.batch();

    final userRef = _db.collection('users').doc(user.uid);
    batch.set(userRef, {
      'totalDonation': FieldValue.increment(donation),
      'totalKm': FieldValue.increment(_distanceKm),
    }, SetOptions(merge: true));

    final globalRef = _db.collection('global').doc('stats');
    batch.set(globalRef, {
      'totalDonation': FieldValue.increment(donation),
    }, SetOptions(merge: true));

    final runRef = _db.collection('users').doc(user.uid).collection('runs').doc();
    batch.set(runRef, {
      'distanceKm': _distanceKm,
      'seconds': _seconds,
      'donation': donation,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();

    setState(() {
      _distanceKm = 0.0;
      _seconds = 0;
      _routePoints.clear();
    });
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
                  const Text('러닝', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(
                    _isRunning ? 'Running...' : 'Monday Morning Run',
                    style: const TextStyle(color: Color(0xB3FFFFFF), fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _distanceKm.toStringAsFixed(2),
                    style: const TextStyle(color: Colors.white, fontSize: 52, fontWeight: FontWeight.bold, height: 1),
                  ),
                  const Text('km', style: TextStyle(color: Color(0xB3FFFFFF), fontSize: 14)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _StatBox(label: '페이스', value: _pace),
                      const SizedBox(width: 8),
                      _StatBox(label: '시간', value: _time),
                      const SizedBox(width: 8),
                      _StatBox(label: '기부금', value: '₩$_donation', valueColor: const Color(0xFF00C896)),
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
                        urlTemplate: 'https://tiles.stadiamaps.com/tiles/outdoors/{z}/{x}/{y}.png',
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
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0xFF141824),
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFF1E2535)),
                              ),
                              child: const Icon(Icons.settings, color: Color(0xFF8899AA), size: 20),
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
                                border: Border.all(color: const Color(0xFF1E2535)),
                              ),
                              child: const Icon(Icons.music_note, color: Color(0xFF8899AA), size: 20),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text('목표 설정', style: TextStyle(color: Color(0xFF8899AA), fontSize: 12)),
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
  const _StatBox({required this.label, required this.value, this.valueColor = Colors.white});
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
            Text(label, style: const TextStyle(color: Color(0xFF8899AA), fontSize: 10)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(color: valueColor, fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}