import 'package:flutter/material.dart';
import 'package:refill/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:refill/home_service/weather_box.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? storeName;
  bool isLoading = true;
  static const mainBlue = AppColors.primary;

  @override
  void initState() {
    super.initState();
    _loadStoreName();
  }

  Future<void> _loadStoreName() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final storeId = userDoc.data()?['storeId'];

      if (storeId == null) {
        setState(() {
          storeName = '매장에 가입되지 않았습니다';
          isLoading = false;
        });
        return;
      }

      final storeDoc = await FirebaseFirestore.instance.collection('stores').doc(storeId).get();
      if (storeDoc.exists) {
        setState(() {
          storeName = storeDoc.data()?['storeName'] ?? '이름 없는 매장';
          isLoading = false;
        });
      } else {
        setState(() {
          storeName = '매장 정보를 찾을 수 없습니다';
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("홈"),
        backgroundColor: mainBlue,
        foregroundColor: AppColors.background,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isLoading ? '불러오는 중...' : (storeName ?? '매장명 없음'),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: mainBlue,
                  ),
                ),
                const SizedBox(height: 16),

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

                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Expanded(
                        child: WeatherBox(),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.background,
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

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.only(top: 16),
                  decoration: BoxDecoration(
                    color: AppColors.background,
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
                            foregroundColor: AppColors.background,
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
