import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:refill/colors.dart';
import 'store_header.dart';
import 'low_stock_button.dart';
import 'weather/weather_box.dart';
import 'holiday_calendar.dart';
import 'stock_recommendation_box.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {


  String? userRole;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserRole();
  }

  Future<void> fetchUserRole() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final role = userDoc.data()?['role'] ?? 'staff';

    setState(() {
      userRole = role;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const StoreHeader(),
              const SizedBox(height: 16),
              if (userRole != 'staff') const LowStockButton(),
              const WeatherBox(),
              const SizedBox(height: 24),
              const HolidayCalendar(),
              const SizedBox(height: 24),
              if (userRole != 'staff') const StockRecommendationBox(),
            ],
          ),
        ),
      ),
    );
  }
}
