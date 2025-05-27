//재고예측 상세보기 버튼 클릭시 나타나는 화면
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:refill/colors.dart';
import 'package:refill/home_service/weather/stock_forecast.dart';
import 'package:refill/providers/weather_provider.dart';
import 'package:refill/providers/holiday_provider.dart';
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

    final weatherMain = Provider.of<WeatherProvider>(context, listen: false).weatherMain;
    final isHoliday = Provider.of<HolidayProvider>(context, listen: false).isTodayHoliday;

    final items = await getPredictedLowStockItems(
      storeId: storeId,
      weatherMain: weatherMain,
      isHoliday: isHoliday,
    );

    String summary = '';
    if (weatherMain == 'clear') summary += '☀️ 내일은 맑은 날씨가 예상됩니다.\n';
    else if (weatherMain == 'rain' || weatherMain == 'drizzle') summary += '🌧️ 내일은 비가 올 것으로 보입니다.\n';
    else if (weatherMain == 'snow') summary += '❄️ 내일은 눈이 내릴 가능성이 있습니다.\n';
    else summary += '🌤️ 내일 날씨는 변동 가능성이 있습니다.\n';

    if (isHoliday) {
      summary += '📅 내일은 공휴일입니다. 유동 인구가 증가할 수 있습니다.\n';
    } else {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      if (tomorrow.weekday == DateTime.saturday) {
        summary += '📌 내일은 주말입니다. 매출 증가에 대비해 재고 확보가 필요합니다.\n';
      }
    }

    summary += '\n🔎 아래 품목들의 추가 발주를 추천합니다.';

    setState(() {
      forecastSummary = summary;
      predictedItems = items;
      isLoading = false;
    });
    print("🌟 예측된 품목 수: ${items.length}");
    for (var item in items) {
      print("▶ ${item['name']} / 수량: ${item['quantity']} / 예측필요: ${item['predictedMin']}");
    }

  }

  void _showConfirmationDialog() {
    final selected = predictedItems.where((item) => selectedItems.contains(item['name'])).toList();
    for (var item in selected) {
      customCounts[item['name']] = (item['predictedMin'] - item['quantity']).clamp(1, 99);
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateDialog) {
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
                          customCounts[name] = (customCounts[name]! - 1).clamp(1, 99);
                        });
                      },
                    ),
                    Text('${customCounts[name]}개'),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        setStateDialog(() {
                          customCounts[name] = (customCounts[name]! + 1).clamp(1, 99);
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
                onPressed: () {
                  Navigator.pop(context);
                  Future.delayed(Duration.zero, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OrderScreen(prefilledCounts: customCounts),
                      ),
                    );
                  });
                },

                child: const Text('추가하기'),
              ),
            ],
          );
        });
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
            child: Text(forecastSummary, style: const TextStyle(fontSize: 14)),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: predictedItems.length,
              itemBuilder: (context, i) {
                final item = predictedItems[i];
                return CheckboxListTile(
                  title: Text(item['name']),
                  subtitle: Text("현재 ${item['quantity']}개 / 예측 필요 ${item['predictedMin']}개"),
                  value: selectedItems.contains(item['name']),
                  onChanged: (val) {
                    setState(() {
                      if (val == true) {
                        selectedItems.add(item['name']);
                      } else {
                        selectedItems.remove(item['name']);
                      }
                    });
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: selectedItems.isEmpty ? null : _showConfirmationDialog,
              child: const Text('발주 목록에 추가하기', style: TextStyle(color: Colors.white)),
            ),
          )
        ],
      ),
    );
  }
}
