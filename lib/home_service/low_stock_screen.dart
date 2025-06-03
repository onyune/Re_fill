import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:refill/colors.dart';
import 'package:refill/order_service/order_screen.dart';

class LowStockScreen extends StatefulWidget {
  const LowStockScreen({super.key});

  @override
  State<LowStockScreen> createState() => _LowStockScreenState();
}

class _LowStockScreenState extends State<LowStockScreen> {
  List<Map<String, dynamic>> items = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final storeId = userDoc['storeId'];

    final stockSnap = await FirebaseFirestore.instance
        .collection('stocks')
        .doc(storeId)
        .collection('items')
        .get();

    List<Map<String, dynamic>> result = [];

    for (final doc in stockSnap.docs) {
      final data = doc.data();
      final name = data['name'] ?? doc.id;
      final quantity = data['quantity'] ?? 0;
      final minQuantity = data['minQuantity'] ?? 0;

      if (quantity < minQuantity) {
        result.add({
          'name': name,
          'quantity': quantity,
          'minQuantity': minQuantity,
        });
      }
    }

    setState(() {
      items = result;
      isLoading = false;
    });
  }

  void _navigateToOrderWithCounts() {
    final Map<String, int> counts = {
      for (final item in items)
        item['name']: (item['minQuantity'] - item['quantity']).clamp(1, 99),
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrderScreen(prefilledCounts: counts),
      ),
    ).then((_) {
      // OrderScreen에서 돌아왔을 때 재고 다시 불러오기
      loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary, // 메인 파란색 배경
        title: const Text(
          '재고 부족 현황',
          style: TextStyle(
            color: Colors.white,             //  흰색 글씨
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,               //  뒤로가기 아이콘도 흰색
        ),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
          ? const Center(child: Text("현재 부족한 재고가 없습니다."))
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (_, i) {
                final item = items[i];
                return ListTile(
                  title: Text(item['name']),
                  subtitle: Text("현재 수량: ${item['quantity']} / 최소 수량: ${item['minQuantity']}"),
                  trailing: const Icon(Icons.warning, color: Colors.red),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: _navigateToOrderWithCounts,
              child: const Text('발주 목록에 추가하기', style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

