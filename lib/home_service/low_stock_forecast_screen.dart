import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:refill/colors.dart';
import 'package:refill/home_service/weather/stock_forecast.dart';
import 'package:refill/order_service/order_screen.dart';

class LowStockForecastScreen extends StatefulWidget {
  const LowStockForecastScreen({super.key});

  @override
  State<LowStockForecastScreen> createState() => _LowStockForecastScreenState();
}

class _LowStockForecastScreenState extends State<LowStockForecastScreen> {
  List<Map<String, dynamic>> predictedItems = [];
  Set<String> selectedItems = {};
  Map<String, int> customCounts = {};
  bool isLoading = true;
  String forecastSummary = '';

  @override
  void initState() {
    super.initState();
    loadForecastData();
  }

  Future<void> loadForecastData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final storeId = userDoc['storeId'];

    final items = await getPredictedStockRecommendations(storeId: storeId);
    final filtered = items.where((item) {
      final q = item['quantity'];
      final need = item['predictedNeed'];
      if (q is! int || need is! int || need == 0) return false;

      final shortageRate = (need - q) / need;
      return shortageRate >= 0.3; // 30% 이상 부족한 경우만
    }).toList();

    setState(() {
      forecastSummary = '📊 내일 수요를 기반으로 한 자동 발주 추천입니다.\n예상 수요보다 적은 품목에 대해 발주를 제안합니다.';
      predictedItems = filtered;
      isLoading = false;
    });
  }

  Future<Map<String, int>?> _showConfirmationDialog() async {
    final selected = predictedItems
        .where((item) => selectedItems.contains(item['name']))
        .toList();

    for (var item in selected) {
      customCounts[item['name']] = (item['recommendedExtra']).clamp(1, 99);
    }

    return showDialog<Map<String, int>>(  // ✅ 반드시 return 해야 함
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('발주 수량 확인'),
              content: SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    children: selected.map((item) {
                      final name = item['name'];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Text(name)),
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () {
                                setStateDialog(() {
                                  customCounts[name] =
                                      (customCounts[name]! - 1).clamp(1, 99);
                                });
                              },
                            ),
                            Text('${customCounts[name]}개'),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                setStateDialog(() {
                                  customCounts[name] =
                                      (customCounts[name]! + 1).clamp(1, 99);
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, null),
                  child: const Text('취소'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, Map<String, int>.from(customCounts)); // ✅ 리턴값 전달
                  },
                  child: const Text('추가하기'),
                ),
              ],
            );
          },
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('재고 예측 현황'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  forecastSummary,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                const Text(
                  '※ 예측 수요는 날씨/공휴일/요일 기반으로 Cloud Functions에서 계산됩니다.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: predictedItems.length,
              itemBuilder: (context, i) {
                final item = predictedItems[i];
                final name = item['name'];
                final quantity = item['quantity'];
                final predicted = item['predictedNeed'];

                return CheckboxListTile(
                  title: Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("현재 $quantity개 / 예측 필요 $predicted개"),
                  value: selectedItems.contains(name),
                  onChanged: (val) {
                    setState(() {
                      if (val == true) {
                        selectedItems.add(name);
                      } else {
                        selectedItems.remove(name);
                      }
                    });
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (selectedItems.isNotEmpty)
                  Text(
                    '${selectedItems.length}개 선택됨',
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                const SizedBox(height: 4),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    onPressed: selectedItems.isEmpty
                        ? null
                        : () async {
                      final counts = await _showConfirmationDialog();
                      if (!mounted || counts == null) return;

                      Future.microtask(() async {
                        final result = await Navigator.of(context, rootNavigator: true).push(
                          MaterialPageRoute(
                            builder: (_) => OrderScreen(prefilledCounts: counts),
                          ),
                        );
                        if (result == 'ordered') {
                          loadForecastData();
                        }
                      });
                    },
                    child: const Text(
                      '발주 목록에 추가하기',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
