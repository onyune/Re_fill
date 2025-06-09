import 'package:flutter/material.dart';
import 'package:refill/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StocksScreen extends StatefulWidget {
  const StocksScreen({super.key});

  @override
  State<StocksScreen> createState() => _StocksScreenState();
}

class _StocksScreenState extends State<StocksScreen> {
  List<Map<String, dynamic>> stockItems = [];
  List<Map<String, dynamic>> filteredStockItems = [];
  String role = 'staff'; // 기본값: staff
  String _searchKeyword = '';
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadStockData();
  }

  void _filterStockItems() {
    setState(() {
      filteredStockItems = stockItems
          .map((item) => {...item})
          .where((item) => item['name']
          .toString()
          .toLowerCase()
          .contains(_searchKeyword.toLowerCase()))

          .toList();
    });
  }

  Future<void> _loadStockData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final storeId = userDoc['storeId'];
    role = userDoc['role'] ?? 'staff';

    final templateSnap = await FirebaseFirestore.instance.collection('orderTemplates').get();

    final stockSnap = await FirebaseFirestore.instance
        .collection('stocks')
        .doc(storeId)
        .collection('items')
        .get();

    Map<String, dynamic> stockMap = {
      for (var doc in stockSnap.docs) doc.id: doc.data()
    };

    final combined = templateSnap.docs.map((doc) {
      final name = doc.id;
      final template = doc.data();
      final stock = stockMap[name];
      final currentQty = stock?['quantity'] ?? 0;

      return {
        'name': name,
        'unit': template['unit'] ?? '',
        'defaultQuantity': template['defaultQuantity'] ?? 1,
        'stock': currentQty,
        'min': stock?['minQuantity'] ?? 0,
        'count': currentQty, // 현재 재고 수량으로 초기화
      };
    }).toList();

    setState(() {
      stockItems = combined;
      _filterStockItems();
    });
  }

  Future<void> _saveStockChanges() async {
    for (var i = 0; i < stockItems.length; i++) {
      final itemName = stockItems[i]['name'];
      final updated = filteredStockItems.firstWhere(
            (e) => e['name'] == itemName,
        orElse: () => {},
      );
      if (updated.isNotEmpty) {
        stockItems[i]['count'] = updated['count'];
      }
    }

    final changedItems =
    stockItems.where((item) => item['stock'] != item['count']).toList();

    if (changedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("변경된 재고가 없습니다.")),
      );
      return;
    }

    final summary = changedItems
        .map((item) => '${item['name']} : ${item['stock']} → ${item['count']}')
        .join('\n');

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("재고 수정 확인"),
        content: Text("이대로 재고를 수정할까요?\n\n$summary"),
        actions: [
          TextButton(
            child: const Text("취소"),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: const Text("확인"),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final storeId = userDoc['storeId'];

    final batch = FirebaseFirestore.instance.batch();

    for (var item in changedItems) {
      final count = item['count'];
      final itemName = item['name'];

      batch.update(
        FirebaseFirestore.instance
            .collection('stocks')
            .doc(storeId)
            .collection('items')
            .doc(itemName),
        {'quantity': count},
      );
    }

    try {
      await batch.commit();
      await _loadStockData(); // 🔁 수정 후 UI 갱신

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("재고가 수정되었습니다.")),
      );
    } catch (e) {
      print('🔥 재고 수정 실패: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❗ 권한이 없어 재고를 수정할 수 없습니다."),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          '재고 관리',
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
              child: Row(
                children: [
                  Icon(Icons.search, color: AppColors.primary),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        _searchKeyword = value;
                        _filterStockItems();
                      },
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '검색',
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 📦 재고 항목 리스트
            Expanded(
              child: ListView.separated(
                itemCount: filteredStockItems.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final item = filteredStockItems[index];
                  final isShort = item['stock'] < item['min'];

                  final stockText = (role == 'owner')
                      ? '현재재고 ${item['stock']} / 최소 ${item['min']}'
                      : '현재재고 ${item['stock']}';

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
                            stockText,
                            style: TextStyle(
                              color: isShort ? AppColors.error : AppColors.black,
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

            // ✅ 저장 버튼
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                onPressed: _saveStockChanges,
                child: const Text('재고 수정', style: TextStyle(fontSize: 16, color: AppColors.background)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
