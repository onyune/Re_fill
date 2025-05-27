// 날씨/공휴일 조건에 따라 재고 부족 품목을 예측하는 유틸 함수
import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<Map<String, dynamic>>> getPredictedLowStockItems({
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

  // 🔸 orderTemplates 기준 name 매핑
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
    if (minQuantity == null || minQuantity <= 0) continue;

    int adjustment = 0;
    if (weatherMain == 'rain' || weatherMain == 'drizzle') adjustment += 2;
    if (isHoliday) adjustment += 1;

    final predictedMin = minQuantity + adjustment;

    if (quantity < predictedMin) {
      result.add({
        'name': nameMap[itemId] ?? itemId, //이름이 없으면 doc.id로 대체
        'quantity': quantity,
        'predictedMin': predictedMin,
      });
    }
  }

  return result;
}
