import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:refill/home_service/weather/stock_forecast.dart';
import 'package:refill/colors.dart';
import 'low_stock_forecast_screen.dart';

class StockRecommendationBox extends StatefulWidget {
  const StockRecommendationBox({super.key});

  @override
  State<StockRecommendationBox> createState() => _StockRecommendationBoxState();
}

class _StockRecommendationBoxState extends State<StockRecommendationBox> {
  List<String> recommendations = [];
  bool isLoading = true;
  String summaryText = '';

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final storeId = userDoc['storeId'];

    final items = await getPredictedStockRecommendations(storeId: storeId);

    final filtered = items.where((item) {
      final extra = item['recommendedExtra'];
      return extra != null && extra > 0;
    }).toList();

    setState(() {
      recommendations = filtered.map((e) => e['name'].toString()).toList();
      summaryText = recommendations.isEmpty
          ? '지금은 재고가 충분해 보여요!'
          : '날씨 및 요일 정보를 기반으로 예측된 추천 품목이에요.';
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
          ? const CircularProgressIndicator()
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '재고 예측 추천',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            summaryText,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          recommendations.isEmpty
              ? const Text(
            '예상 부족 품목 없음',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          )
              : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: recommendations.map((name) {
              return Row(
                children: [
                  const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(name, style: const TextStyle(fontSize: 14)),
                ],
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LowStockForecastScreen()),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('예측 상세보기', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
