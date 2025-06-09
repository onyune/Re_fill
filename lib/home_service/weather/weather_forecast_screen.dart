import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:refill/colors.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class WeatherForecastScreen extends StatefulWidget {
  const WeatherForecastScreen({super.key});

  @override
  State<WeatherForecastScreen> createState() => _WeatherForecastScreenState();
}

Color getWeatherColor(String main) {
  switch (main.toLowerCase()) {
    case '맑음':
      return Colors.orangeAccent;
    case '구름많음':
    case '흐림':
      return Colors.grey;
    case '비':
    case '실비':
    case '약한 비':
      return Colors.blueAccent;
    case '눈':
      return Colors.lightBlueAccent;
    case '천둥번개':
      return Colors.deepPurpleAccent;
    default:
      return AppColors.primary;
  }
}

String getWeatherEmoji(String main) {
  switch (main.toLowerCase()) {
    case 'clear':
      return '☀️';
    case 'clouds':
      return '☁️';
    case 'rain':
    case 'drizzle':
      return '🌧️';
    case 'thunderstorm':
      return '⛈️';
    case 'snow':
      return '❄️';
    case 'mist':
    case 'fog':
      return '🌫️';
    default:
      return '🌈';
  }
}

String formatWeatherText(String main) {
  switch (main.toLowerCase()) {
    case 'clear':
      return '맑음';
    case 'clouds':
      return '흐림';
    case 'rain':
    case 'drizzle':
      return '비';
    case 'thunderstorm':
      return '천둥번개';
    case 'snow':
      return '눈';
    case 'mist':
    case 'fog':
      return '안개';
    default:
      return main;
  }
}

class _WeatherForecastScreenState extends State<WeatherForecastScreen> {
  final List<Map<String, dynamic>> dailyForecasts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadForecast();
  }

  Future<void> _loadForecast() async {
    try {
      print('⏳ 날씨 예보 불러오는 중...');
      const apiKey = '3a7bc2dc7a3b4025ce04a27e31923af7';
      final lat = 35.1595;
      final lon = 126.8526;

      final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&units=metric&lang=kr&appid=$apiKey',
      );

      final response = await http.get(url);
      print('📡 응답 상태 코드: ${response.statusCode}');

      if (response.statusCode != 200) {
        throw Exception('예보 API 오류: ${response.body}');
      }

      final data = json.decode(response.body);
      final List list = data['list'];

      final Map<String, List<Map<String, dynamic>>> grouped = {};

      for (var entry in list) {
        final dtTxt = entry['dt_txt'];
        final date = dtTxt.substring(0, 10);

        grouped.putIfAbsent(date, () => []).add(entry);
      }

      final formatter = DateFormat('M월 d일 (E)', 'ko');


      final results = grouped.entries.take(5).map((e) {
        final date = DateTime.parse(e.key);
        final list = e.value;
        if (grouped.isEmpty) {
          print('⚠️ grouped에 날씨가 없음!');
        }

        double min = 100;
        double max = -100;
        String main = '';
        String icon = '';

        for (var item in list) {
          final temp = (item['main']['temp'] as num).toDouble();
          if (temp < min) min = temp;
          if (temp > max) max = temp;
        }

        if (list.length > 4) {
          main = list[4]['weather'][0]['main'];
          icon = list[4]['weather'][0]['icon'];
        } else {
          main = list[0]['weather'][0]['main'];
          icon = list[0]['weather'][0]['icon'];
        }

        return {
          'date': formatter.format(date),
          'main': main,
          'icon': icon,
          'min': min.toStringAsFixed(1),
          'max': max.toStringAsFixed(1),
        };
      }).toList();

      print('📦 grouped keys: ${grouped.keys}');
      print('📅 dailyForecasts 결과: $results');

      setState(() {
        dailyForecasts.addAll(results);
        isLoading = false;
      });
    } catch (e) {
      print('🔥 에러 발생: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('날씨 예보'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
        itemCount: dailyForecasts.length,
        separatorBuilder: (_, __) => const Divider(height: 0),
        itemBuilder: (context, index) {
          final day = dailyForecasts[index];
          final color = getWeatherColor(formatWeatherText(day['main']));

          return ListTile(
            leading: Text(
              getWeatherEmoji(day['main']),
              style: const TextStyle(fontSize: 28),
            ),
            title: Text(
              day['date'],
              style: TextStyle(fontWeight: FontWeight.bold, color: color),
            ),
            subtitle: Text(
              formatWeatherText(day['main']),
              style: TextStyle(color: color, fontSize: 14),
            ),
            trailing: Text(
              '${day['max']}° / ${day['min']}°',
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
      ),
    );
  }
}