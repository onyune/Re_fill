import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

Future<void> autoOrderExecution() async {
  try {
    print('🟢 [autoOrderExecution] 실행됨 - ${DateTime.now()}');

    final now = DateTime.now();
    final currentTimeStr = DateFormat('a hh:mm', 'en_US').format(now); // 예: AM 01:30

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      print('❌ uid 없음 → 중단');
      return;
    }

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final storeId = userDoc['storeId'];
    if (storeId == null || storeId.toString().isEmpty) {
      print('❌ storeId 없음 → 중단');
      return;
    }

    final storeDoc = await FirebaseFirestore.instance.collection('stores').doc(storeId).get();
    final autoOrderTime = storeDoc['autoOrderTime'];

    print('🕒 현재 시간: $currentTimeStr / 설정된 발주 시간: $autoOrderTime');

    if (autoOrderTime != currentTimeStr) {
      print('⏱ 현재 시간 $currentTimeStr 은 발주 시간 $autoOrderTime 아님, 패스');
      return;
    }

    print('✅ 발주 시간 도달! 자동 발주 실행');

    final recSnap = await FirebaseFirestore.instance
        .collection('recommendations')
        .doc(storeId)
        .collection('items')
        .get();

    print('📊 예측 결과 ${recSnap.docs.length}개 품목 감지됨');

    final orderItems = <Map<String, dynamic>>[];

    for (final doc in recSnap.docs) {
      final data = doc.data();
      final name = doc.id; // ✅ 문서 ID를 이름으로 사용
      final recommendedExtra = data['recommendedExtra'] ?? 0;

      if (recommendedExtra <= 0) {
        print('⚠️ 건너뜀 (0 이하 추천): $name → $recommendedExtra');
        continue;
      }

      orderItems.add({
        'name': name,
        'count': recommendedExtra,
      });

      final stockRef = FirebaseFirestore.instance
          .collection('stocks')
          .doc(storeId)
          .collection('items')
          .doc(name);

      final stockDoc = await stockRef.get();
      final currentQty = stockDoc.data()?['quantity'] ?? 0;

      await stockRef.update({
        'quantity': currentQty + recommendedExtra,
      });

      print('✅ [$name] 재고 $currentQty → ${currentQty + recommendedExtra}');
    }

    if (orderItems.isNotEmpty) {
      await FirebaseFirestore.instance.collection('orders').add({
        'storeId': storeId,
        'items': orderItems,
        'createdAt': Timestamp.now(),
        'auto': true,
      });

      print('✅ 자동 발주 완료: ${orderItems.length}개 품목');
    } else {
      print('ℹ️ 자동 발주 대상 품목 없음');
    }
  } catch (e) {
    print('⚠ 자동 발주 중 오류 발생: $e');
  }
}
