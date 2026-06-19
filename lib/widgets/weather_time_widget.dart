import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/weather_service.dart';
import 'glass_container.dart';

class WeatherTimeWidget extends StatefulWidget {
  const WeatherTimeWidget({super.key});

  @override
  State<WeatherTimeWidget> createState() => _WeatherTimeWidgetState();
}

class _WeatherTimeWidgetState extends State<WeatherTimeWidget> {
  final WeatherService _weatherService = WeatherService();

  String _timeString = '';
  String _dateString = '';
  Timer? _timer;
  String _temp = "로딩 중...";
  String _weatherDescription = "";

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer =
        Timer.periodic(const Duration(seconds: 1), (Timer t) => _updateTime());
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
          _weatherDescription =
              weatherArray[0]['description']?.toString() ?? "";
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
    return GlassContainer(
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
    );
  }
}