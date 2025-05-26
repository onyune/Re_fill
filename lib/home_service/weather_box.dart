import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:refill/colors.dart';

class WeatherBox extends StatefulWidget {
  const WeatherBox({super.key});

  @override
  State<WeatherBox> createState() => _WeatherBoxState();
}

class _WeatherBoxState extends State<WeatherBox> {
  String weather = '로딩 중...';
  String temperature = '';
  String humidity = '';
  IconData weatherIcon = Icons.wb_sunny; // 기본 아이콘

  @override
  void initState() {
    super.initState();
    loadWeather();
  }

  Future<void> loadWeather() async {
    try {
      // 🔹 서울 고정 좌표
      final double lat = 37.5665;
      final double lon = 126.9780;

      final data = await _fetchWeather(lat, lon);
      print("날씨 데이터: $data");

      final weatherMain = data['weather'][0]['main'];
      final temp = data['main']['temp'];
      final humid = data['main']['humidity'];

      setState(() {
        weather = data['weather'][0]['description'];
        temperature = '${temp.toStringAsFixed(1)}°C'; // 소수점 1자리
        humidity = '습도 $humid%';
        weatherIcon = _getWeatherIcon(weatherMain);
      });
    } catch (e) {
      print("날씨 로딩 실패: $e");
      setState(() {
        weather = '불러오기 실패';
        temperature = '';
        humidity = '';
        weatherIcon = Icons.error;
      });
    }
  }

  Future<Map<String, dynamic>> _fetchWeather(double lat, double lon) async {
    const apiKey = '3a7bc2dc7a3b4025ce04a27e31923af7';
    final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&units=metric&lang=kr&appid=$apiKey');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('날씨 데이터 오류');
    }
  }

  IconData _getWeatherIcon(String weatherMain) {
    switch (weatherMain.toLowerCase()) {
      case 'clear':
        return Icons.wb_sunny;
      case 'clouds':
        return Icons.cloud;
      case 'rain':
        return Icons.grain;
      case 'snow':
        return Icons.ac_unit;
      case 'thunderstorm':
        return Icons.flash_on;
      case 'drizzle':
        return Icons.grain;
      case 'mist':
      case 'fog':
        return Icons.blur_on;
      default:
        return Icons.wb_cloudy;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(weatherIcon, size: 32, color: AppColors.primary),
        const SizedBox(height: 8),
        Text(weather, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
        Text(temperature, style: const TextStyle(color: AppColors.primary)),
        Text(humidity, style: const TextStyle(color: AppColors.primary)),
      ],
    );
  }
}
