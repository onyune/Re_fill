import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class WeatherBox extends StatefulWidget {
  const WeatherBox({super.key});

  @override
  State<WeatherBox> createState() => _WeatherBoxState();
}

class _WeatherBoxState extends State<WeatherBox> {
  String weather = '로딩 중...';
  String temperature = '';
  String humidity = '';
  final Color mainBlue = const Color(0xFF2563EB);

  @override
  void initState() {
    super.initState();
    loadWeather();
  }

  Future<void> loadWeather() async {
    try {
      Position pos = await _getCurrentLocation();
      final data = await _fetchWeather(pos.latitude, pos.longitude);

      print("날씨 데이터: $data");

      setState(() {
        weather = data['weather'][0]['description'];
        temperature = '${data['main']['temp']}°C';
        humidity = '습도 ${data['main']['humidity']}%';
      });
    } catch (e) {
      print("에러: $e");
      setState(() {
        weather = '날씨 불러오기 실패';
        temperature = '';
        humidity = '';
      });
    }
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw Exception('위치 서비스 꺼짐');

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('위치 권한 거부됨');
      }
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 10),
    );
  }

  Future<Map<String, dynamic>> _fetchWeather(double lat, double lon) async {
    const apiKey = '3a7bc2dc7a3b4025ce04a27e31923af7';
    final url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&units=metric&lang=kr&appid=$apiKey',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print("응답 오류: ${response.body}");
      throw Exception('날씨 정보 불러오기 실패');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.wb_sunny, size: 24, color: Color(0xFF2563EB)),
        const SizedBox(width: 12),
        Text(weather, style: TextStyle(fontWeight: FontWeight.bold, color: mainBlue)),
        const SizedBox(width: 12),
        Text(temperature, style: TextStyle(color: mainBlue)),
        const SizedBox(width: 12),
        Text(humidity, style: TextStyle(color: mainBlue)),
      ],
    );
  }
}
