import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? storeName;
  bool isLoading = true;
  static const mainBlue = Color(0xFF2563EB); // Re:fill 주색

  @override
  void initState() {
    super.initState();
    _loadStoreName();
  }

  Future<void> _loadStoreName() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('stores')
          .where('ownerUid', isEqualTo: uid)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          storeName = snapshot.docs.first['storeName'];
          isLoading = false;
        });
      } else {
        setState(() {
          storeName = '매장을 먼저 생성해주세요';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        storeName = '매장 정보를 불러오는 중 오류';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: const Text("홈"),
        backgroundColor: mainBlue,
        foregroundColor: Colors.white,
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 동적으로 불러온 매장명
                Text(
                  isLoading ? '불러오는 중...' : (storeName ?? '매장명 없음'),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: mainBlue,
                  ),
                ),
                const SizedBox(height: 16),

                // 검색창
                TextField(
                  decoration: InputDecoration(
                    hintText: '검색',
                    prefixIcon: const Icon(Icons.search, color: mainBlue),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: mainBlue, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: mainBlue),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 한눈에 보기 (날씨 + 재고 요약)
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 날씨 카드
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: mainBlue),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.wb_sunny, size: 32, color: mainBlue),
                              SizedBox(height: 8),
                              Text('맑음', style: TextStyle(fontWeight: FontWeight.bold, color: mainBlue)),
                              Text('23°C', style: TextStyle(color: mainBlue)),
                              Text('습도 55%', style: TextStyle(color: mainBlue)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // 재고 요약 카드
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: mainBlue),
                          ),
                          child: Column(
                            children: const [
                              Icon(Icons.show_chart, size: 32, color: mainBlue),
                              SizedBox(height: 8),
                              Text('재고 현황 요약', style: TextStyle(fontWeight: FontWeight.bold, color: mainBlue)),
                              Text('남은 수량 100', style: TextStyle(color: mainBlue)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 재고 예측 추천
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.only(top: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: mainBlue),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('재고 예측 추천',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: mainBlue)),
                      const SizedBox(height: 8),
                      const Text('오늘 아이스류 소비 증가 예상!', style: TextStyle(color: mainBlue)),
                      const SizedBox(height: 4),
                      const Text('• 아이스 아메리카노', style: TextStyle(color: mainBlue)),
                      const Text('• 얼음컵 등', style: TextStyle(color: mainBlue)),
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
