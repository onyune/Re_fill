//예측된 재고 부족 품목 리스트를 보여주는 화면
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:refill/home_service/weather/stock_forecast.dart';
import 'package:refill/colors.dart';
import 'package:provider/provider.dart';
import 'package:refill/providers/weather_provider.dart';
import 'package:refill/providers/holiday_provider.dart';

class LowStockForecastScreen extends StatefulWidget {
  const LowStockForecastScreen({super.key});

  @override
  State<LowStockForecastScreen> createState() => _LowStockForecastScreenState();
}

class _LowStockForecastScreenState extends State<LowStockForecastScreen> {
  List<Map<String, dynamic>> items = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final storeId = userDoc['storeId'];

    // ✅ 실제 상태값 사용
    final weatherMain = Provider.of<WeatherProvider>(context, listen: false).weatherMain;
    final isHoliday = Provider.of<HolidayProvider>(context, listen: false).isTodayHoliday;

    final result = await getPredictedLowStockItems(
      storeId: storeId,
      weatherMain: weatherMain,
      isHoliday: isHoliday,
    );

    setState(() {
      items = result;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('재고 예측 현황'), backgroundColor: AppColors.primary),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
          ? const Center(child: Text("예측된 부족 항목 없음"))
          : ListView.builder(
        itemCount: items.length,
        itemBuilder: (_, i) {
          final item = items[i];
          return ListTile(
            title: Text(item['name']),
            subtitle: Text("현재 수량: ${item['quantity']} / 예상 필요: ${item['predictedMin']}"),
            trailing: const Icon(Icons.warning, color: Colors.red),
          );
        },
      ),
    );
  }
}
