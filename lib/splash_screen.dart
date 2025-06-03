import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:refill/colors.dart';
import 'package:refill/providers/holiday_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // 내일 공휴일 여부 계산 후 Provider에 반영
    Future.microtask(() {
      checkTomorrowHoliday(context);
    });

    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  void checkTomorrowHoliday(BuildContext context) {
    final holidayProvider = Provider.of<HolidayProvider>(context, listen: false);
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final isWeekend = tomorrow.weekday == DateTime.saturday || tomorrow.weekday == DateTime.sunday;

    holidayProvider.updateTomorrowHoliday(isWeekend);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Text(
          'Re:fill',
          style: TextStyle(
            color: AppColors.background,
            fontSize: 40,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}
