// 날씨/공휴일 조건에 따라 재고 부족 품목을 예측하는 유틸 함수
import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<Map<String, dynamic>>> getPredictedStockRecommendations({
  required String storeId,
  required String weatherMain,
  required bool isHoliday,
}) async {
  final stockSnap = await FirebaseFirestore.instance
      .collection('stocks')
      .doc(storeId)
      .collection('items')
      .get();

  final templateSnap = await FirebaseFirestore.instance
      .collection('orderTemplates')
      .get();

  // orderTemplates 기준 name 매핑
  final Map<String, String> nameMap = {
    for (var doc in templateSnap.docs)
      doc.id: (doc.data()['name'] ?? '이름없음') as String
  };

  List<Map<String, dynamic>> result = [];

  for (final doc in stockSnap.docs) {
    final data = doc.data();
    final itemId = doc.id;

    final quantity = data['quantity'] ?? 0;
    final minQuantity = data['minQuantity'] ?? 0;

    int demandBoost = 0;
    if (weatherMain == 'clear' || weatherMain == 'hot') demandBoost += 2;
    else if (weatherMain == 'rain' || weatherMain == 'snow') demandBoost += 0;
    else demandBoost += 1;

    if (isHoliday) demandBoost += 2;

    final predictedNeed = minQuantity + demandBoost;


    result.add({
      'name': nameMap[itemId] ?? itemId,
      'quantity': quantity,
      'minQuantity': minQuantity,
      'predictedNeed': predictedNeed,
      'recommendedExtra': (predictedNeed - quantity).clamp(0, 99),
    });
  }

  return result;
}
