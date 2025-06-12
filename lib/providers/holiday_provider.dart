// 오늘이 공휴일인지 여부를 앱 전역에서 관리하는 Provider
import 'package:flutter/material.dart';

class HolidayProvider extends ChangeNotifier {
  bool _isTodayHoliday = false;
  bool _isTomorrowHoliday = false;

  bool get isTodayHoliday => _isTodayHoliday;
  bool get isTomorrowHoliday => _isTomorrowHoliday;

  void updateHoliday(bool value) {
    _isTodayHoliday = value;
    notifyListeners();
  }

  void updateTomorrowHoliday(bool value) {
    _isTomorrowHoliday = value;
    notifyListeners();
  }
}

