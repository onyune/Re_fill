//현재 날씨(main 상태)를 전역에서 사용할 수 있도록 저장하는 Provider
import 'package:flutter/material.dart';

class WeatherProvider extends ChangeNotifier {
  String _weatherMain = 'clear'; // 초기값
  String get weatherMain => _weatherMain;

  void updateWeather(String main) {
    _weatherMain = main;
    notifyListeners();
  }
}
