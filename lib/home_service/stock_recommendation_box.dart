// 홈 화면 > 하단 재고 예측 추천 버튼

import 'package:flutter/material.dart';
import 'package:refill/colors.dart';

class StockRecommendationBox extends StatelessWidget {
  const StockRecommendationBox({super.key});

  @override
  Widget build(BuildContext context) {
    final mainBlue = AppColors.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: mainBlue),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('재고 예측 추천',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
          const SizedBox(height: 8),
          const Text('오늘 아이스류 소비 증가 예상!', style: TextStyle(color: AppColors.primary)),
          const SizedBox(height: 4),
          const Text('• 아이스 아메리카노', style: TextStyle(color: AppColors.primary)),
          const Text('• 얼음컵 등', style: TextStyle(color: AppColors.primary)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('발주에 추가'),
              style: ElevatedButton.styleFrom(
                backgroundColor: mainBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
