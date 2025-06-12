import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:refill/home_service/weather/stock_forecast.dart';
import 'package:provider/provider.dart';
import 'package:refill/providers/weather_provider.dart';
import 'package:refill/providers/holiday_provider.dart';
import 'package:refill/colors.dart';
import 'low_stock_forecast_screen.dart';

class StockRecommendationBox extends StatefulWidget {
  const StockRecommendationBox({super.key});

  @override
  State<StockRecommendationBox> createState() => _StockRecommendationBoxState();
}

class _StockRecommendationBoxState extends State<StockRecommendationBox> {
  bool isLoading = true;
  int shortageCount = 0;
  String weatherText = '';
  String demandSummary = '';

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<List<Map<String, dynamic>>> getFilteredPredictedItems({
    required String storeId,
    double shortageThreshold = 0.3,
  }) async {
    final items = await getPredictedStockRecommendations(storeId: storeId);
    return items.where((item) {
      final q = item['quantity'];
      final need = item['predictedNeed'];
      if (q is! int || need is! int || need == 0) return false;

      final shortageRate = (need - q) / need;
      return shortageRate >= shortageThreshold;
    }).toList();
  }

  Future<void> _loadRecommendations() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final storeId = userDoc['storeId'];

    final weatherMain = Provider.of<WeatherProvider>(context, listen: false).weatherMain;
    final isHoliday = Provider.of<HolidayProvider>(context, listen: false).isTomorrowHoliday;

    final filtered = await getFilteredPredictedItems(storeId: storeId); // ✅ 여기!!

    String weatherInfo = '';
    if (weatherMain.toLowerCase().contains('clear')) {
      weatherInfo = '☀️ 내일은 맑은 날씨가 예상돼요.';
    } else if (weatherMain.toLowerCase().contains('rain')) {
      weatherInfo = '🌧️ 내일은 비 소식이 있어요.';
    } else if (weatherMain.toLowerCase().contains('snow')) {
      weatherInfo = '❄️ 내일은 눈이 올 가능성이 있어요.';
    } else {
      weatherInfo = '🌤️ 내일 날씨는 흐릴 수 있어요.';
    }

    if (isHoliday) {
      weatherInfo += '\n📅 내일은 공휴일이라 손님이 많을 수 있어요.';
    } else {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      if (tomorrow.weekday == DateTime.saturday || tomorrow.weekday == DateTime.sunday) {
        weatherInfo += '\n📌 내일은 주말이에요. 매출 증가 가능성이 있어요.';
      }
    }

    setState(() {
      shortageCount = filtered.length;
      weatherText = weatherInfo;
      demandSummary = shortageCount == 0
          ? '지금은 재고가 충분해 보여요!'
          : '예상 수요 부족 품목이 $shortageCount개 있어요.';
      isLoading = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primary),
        borderRadius: BorderRadius.circular(12),
      ),
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '재고 예측 추천',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            weatherText,
            style: const TextStyle(fontSize: 13, color: AppColors.borderDefault),
          ),
          const SizedBox(height: 6),
          Text(
            demandSummary,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LowStockForecastScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('예측 상세보기', style: TextStyle(color: AppColors.background)),
            ),
          ),
        ],
      ),
    );
  }
}

