import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 지점 이름
                Text(
                  'OO커피 OO점',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // 검색창
                TextField(
                  decoration: InputDecoration(
                    hintText: '검색',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 24),

                // 한눈에 보기 섹션 (날씨 + 그래프)
                Row(
                  children: [
                    // 날씨 카드
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F7FA),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: const [
                            Icon(Icons.wb_sunny, size: 32, color: Colors.orange),
                            SizedBox(height: 8),
                            Text('맑음', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('23°C'),
                            Text('습도 55%'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // 그래프 카드 (간단 요약용)
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDE7F6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: const [
                            Icon(Icons.show_chart, size: 32, color: Colors.deepPurple),
                            SizedBox(height: 8),
                            Text('재고 현황 요약', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('남은 수량 100'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 재고 예측 추천
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('재고 예측 추천', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const Text('오늘 아이스류 소비 증가 예상!'),
                      const SizedBox(height: 4),
                      const Text('• 아이스 아메리카노'),
                      const Text('• 얼음컵 등'),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.add_shopping_cart),
                        label: const Text('발주에 추가'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
