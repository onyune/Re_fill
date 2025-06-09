import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> autoOrderExecution(String storeId) async {
  final now = DateTime.now();
  final doc = await FirebaseFirestore.instance
      .collection('recommendations')
      .doc(storeId)
      .get();

  final data = doc.data();
  final List<dynamic> items = data?['items'] ?? [];

  final List<Map<String, dynamic>> orderItems = [];

  for (var item in items) {
    final recommendedExtra = item['recommendedExtra'] ?? 0;
    if (recommendedExtra > 0) {
      orderItems.add({
        'name': item['name'],
        'count': recommendedExtra,
      });

      // 재고 증가 처리
      final stockRef = FirebaseFirestore.instance
          .collection('stocks')
          .doc(storeId)
          .collection('items')
          .doc(item['name']); // 또는 고유 ID가 있다면 그걸 써도 됨

      await stockRef.update({
        'quantity': FieldValue.increment(recommendedExtra),
      });
    }
  }

  if (orderItems.isNotEmpty) {
    await FirebaseFirestore.instance.collection('orders').add({
      'storeId': storeId,
      'createdAt': now,
      'items': orderItems,
      'autoOrdered': true,
    });

    print("✅ 자동 발주 완료: ${orderItems.length}개 항목");
  } else {
    print("ℹ️ 자동 발주할 항목이 없습니다.");
  }
}
