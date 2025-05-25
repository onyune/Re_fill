import 'package:flutter/material.dart';
import 'package:refill/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  bool isAuto = false;
  List<Map<String, dynamic>> items = [];

  @override
  void initState() {
    super.initState();
    _loadOrderData();
  }

  Future<void> _loadOrderData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    // 🔹 storeId 가져오기
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final storeId = userDoc['storeId'];

    // 🔹 orderTemplates(공통 발주 목록) 가져오기
    final orderTemplateSnap = await FirebaseFirestore.instance.collection('orderTemplates').get();

    // 🔹 매장의 stocks 데이터 가져오기
    final stockSnap = await FirebaseFirestore.instance
        .collection('stocks')
        .doc(storeId)
        .collection('items')
        .get();

    // 🔹 stock 데이터를 Map으로 정리
    Map<String, dynamic> stockMap = {
      for (var doc in stockSnap.docs) doc.id: doc.data()
    };

    // 🔹 두 개를 조합
    final combined = orderTemplateSnap.docs.map((doc) {
      final name = doc.id;
      final template = doc.data();
      final stock = stockMap[name];

      return {
        'name': name,
        'unit': template['unit'] ?? '',
        'defaultQuantity': template['defaultQuantity'] ?? 1,
        'stock': stock?['quantity'] ?? 0,
        'min': stock?['minQuantity'] ?? 0,
        'count': 1,
      };
    }).toList();

    setState(() {
      items = combined;
    });
  }

  Future<void> _placeOrder() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final userDoc =
    await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final storeId = userDoc['storeId'];

    final batch = FirebaseFirestore.instance.batch();

    for (var item in items) {
      final count = item['count'];
      final itemName = item['name'];

      // 수량 0은 패스
      if (count <= 0) continue;

      final docRef = FirebaseFirestore.instance
          .collection('stocks')
          .doc(storeId)
          .collection('items')
          .doc(itemName);

      // 기존 수량 읽어서 업데이트
      final docSnap = await docRef.get();
      final currentQty = (docSnap.data()?['quantity'] ?? 0) as int;
      final newQty = currentQty + count;

      batch.update(docRef, {'quantity': newQty});
    }

    await batch.commit();

    // 완료 후 다시 불러오기
    await _loadOrderData();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("발주가 완료되었습니다.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          '발주',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            // 🔍 검색창
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Icon(Icons.search, color: AppColors.primary),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '검색',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 🔁 자동 발주 스위치
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('자동 발주', style: TextStyle(fontSize: 16)),
                Switch(
                  value: isAuto,
                  activeColor: AppColors.primary,
                  onChanged: (value) {
                    setState(() => isAuto = value);
                  },
                ),
              ],
            ),

            if (isAuto)
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '✅ 자동 발주 기능이 활성화되어 있습니다.',
                    style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500),
                  ),
                ),
              ),

            const SizedBox(height: 10),

            // 📦 발주 항목 리스트
            Expanded(
              child: ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final item = items[index];
                  final isShort = item['stock'] < item['min'];
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['name'],
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '현재재고 ${item['stock']} / 최소 ${item['min']}',
                            style: TextStyle(
                              color: isShort ? Colors.red : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, color: AppColors.primary),
                            onPressed: () {
                              setState(() {
                                if (item['count'] > 0) item['count']--;
                              });
                            },
                          ),
                          Text('${item['count']}', style: const TextStyle(fontSize: 16)),
                          IconButton(
                            icon: const Icon(Icons.add, color: AppColors.primary),
                            onPressed: () {
                              setState(() {
                                item['count']++;
                              });
                            },
                          ),
                        ],
                      )
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // ✅ 발주 버튼
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                onPressed: _placeOrder,
                child: const Text('발주하기', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
