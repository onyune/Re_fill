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

    setState(() {
      forecastSummary = '📊 내일 수요를 기반으로 한 자동 발주 추천입니다.\n'
          '예상 수요보다 적은 품목에 대해 발주를 제안합니다.';
      predictedItems = items;
      isLoading = false;
    });
  }

  void _showConfirmationDialog() {
    final selected = predictedItems
        .where((item) => selectedItems.contains(item['name']))
        .toList();
    for (var item in selected) {
      customCounts[item['name']] =
          (item['recommendedExtra']).clamp(1, 99);
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('발주 수량 확인'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: selected.map((item) {
                  final name = item['name'];
                  return Row(
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
                  );
                }).toList(),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('취소'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            OrderScreen(prefilledCounts: customCounts),
                      ),
                    );
                    loadForecastData(); // 돌아와서 다시 로드
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

  Color _getRiskColor(int quantity, int predictedNeed) {
    if (quantity < predictedNeed * 0.5) return Colors.redAccent;
    if (quantity < predictedNeed) return Colors.orange;
    return Colors.black87;
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
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _getRiskColor(quantity, predicted),
                    ),
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
                        : _showConfirmationDialog,
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
