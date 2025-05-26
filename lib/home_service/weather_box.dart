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
  IconData weatherIcon = Icons.wb_sunny;

  @override
  void initState() {
    super.initState();
    loadWeather();
  }

  Future<void> loadWeather() async {
    try {
      final double lat = 37.5665; // 서울
      final double lon = 126.9780;

      final data = await _fetchWeather(lat, lon);
      final weatherMain = data['weather'][0]['main'];
      final temp = data['main']['temp'];
      final humid = data['main']['humidity'];

      setState(() {
        weather = data['weather'][0]['description'];
        temperature = '${temp.toStringAsFixed(1)}°C';
        humidity = '습도 $humid%';
        weatherIcon = _getWeatherIcon(weatherMain);
      });
    } catch (e) {
      print("날씨 로딩 실패: $e");
      setState(() {
        weather = '날씨 불러오기 실패';
        temperature = '';
        humidity = '';
        weatherIcon = Icons.error;
      });
    }
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
      throw Exception('날씨 정보 불러오기 실패');
    }
  }

  IconData _getWeatherIcon(String weatherMain) {
    switch (weatherMain.toLowerCase()) {
      case 'clear':
        return Icons.wb_sunny;
      case 'clouds':
        return Icons.cloud;
      case 'rain':
      case 'drizzle':
        return Icons.grain;
      case 'snow':
        return Icons.ac_unit;
      case 'thunderstorm':
        return Icons.flash_on;
      case 'mist':
      case 'fog':
        return Icons.blur_on;
      default:
        return Icons.wb_cloudy;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(weatherIcon, size: 24, color: AppColors.primary),
        const SizedBox(width: 12),
        Text(weather, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
        const SizedBox(width: 12),
        Text(temperature, style: const TextStyle(color: AppColors.primary)),
        const SizedBox(width: 12),
        Text(humidity, style: const TextStyle(color: AppColors.primary)),
      ],
    );
  }
}
