//오늘이 공휴일인지 여부를 앱 전역에서 관리하는 Provider
import 'package:flutter/material.dart';

class HolidayProvider extends ChangeNotifier {
  bool _isTodayHoliday = false;
  bool get isTodayHoliday => _isTodayHoliday;

  void updateHoliday(bool value) {
    _isTodayHoliday = value;
    notifyListeners();
  }
}
