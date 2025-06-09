import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> autoOrderExecution(String storeId) async {
  final now = DateTime.now();
  final todayStart = DateTime(now.year, now.month, now.day);

  // ✅ 자동 발주 비활성화 여부 확인
  final storeDoc = await FirebaseFirestore.instance.collection('stores').doc(storeId).get();
  final storeData = storeDoc.data();
  if (storeData == null || storeData['autoOrderEnabled'] != true) {
    print("🚫 자동 발주 비활성화 상태입니다. 실행 중단.");
    return;
  }

  // 중복 자동 발주 방지: 오늘 이미 실행된 자동 발주가 있는지 확인
  final alreadyOrdered = await FirebaseFirestore.instance
      .collection('orders')
      .where('storeId', isEqualTo: storeId)
      .where('autoOrdered', isEqualTo: true)
      .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
      .get();

  if (alreadyOrdered.docs.isNotEmpty) {
    print("⚠️ 이미 오늘 자동 발주가 실행됨. 중복 방지");
    return;
  }

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
          .doc(item['name']);

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
