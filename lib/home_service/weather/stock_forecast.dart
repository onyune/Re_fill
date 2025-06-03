import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore의 /recommendations/{storeId} 에 저장된 예측 데이터를 불러오는 함수
Future<List<Map<String, dynamic>>> getPredictedStockRecommendations({
  required String storeId,
}) async {
  final doc = await FirebaseFirestore.instance
      .collection('recommendations')
      .doc(storeId)
      .get(const GetOptions(source: Source.server)); // 서버에서 강제로 가져오기

  final data = doc.data();
  if (data == null || !data.containsKey('items')) return [];

  final List<dynamic> rawItems = data['items'];

  return rawItems.map((item) {
    return {
      'name': item['name'],
      'quantity': item['quantity'],
      'minQuantity': item['minQuantity'],
      'predictedNeed': item['predictedNeed'],
      'recommendedExtra': item['recommendedExtra'],
    };
  }).toList();
}

