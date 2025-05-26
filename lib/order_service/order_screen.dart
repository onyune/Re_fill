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
  int selectedCategory = 1;
  final List<String> categories = ['시럽', '원두/우유', '파우더', '디저트', '컵', '기타'];
  List<Map<String, dynamic>> items = [];
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadOrderData();
  }

  Future<void> _loadOrderData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final storeId = userDoc['storeId'];

    final orderTemplateSnap = await FirebaseFirestore.instance.collection('orderTemplates').get();
    final stockSnap = await FirebaseFirestore.instance
        .collection('stocks')
        .doc(storeId)
        .collection('items')
        .get();

    Map<String, dynamic> stockMap = {
      for (var doc in stockSnap.docs) doc.id: doc.data()
    };

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
        'count': 0,
        'category': template['category'] ?? '기타',
      };
    }).toList();

    setState(() {
      items = combined;
    });
  }

  Future<void> _placeOrder() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final storeId = userDoc['storeId'];

    final batch = FirebaseFirestore.instance.batch();

    for (var item in items) {
      final count = item['count'];
      final itemName = item['name'];

      if (count <= 0) continue;

      final docRef = FirebaseFirestore.instance
          .collection('stocks')
          .doc(storeId)
          .collection('items')
          .doc(itemName);

      final docSnap = await docRef.get();
      final currentQty = (docSnap.data()?['quantity'] ?? 0) as int;
      final newQty = currentQty + count;

      batch.update(docRef, {'quantity': newQty});
    }

    await batch.commit();
    await _loadOrderData();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("발주가 완료되었습니다.")),
    );
  }

  void _showAddItemDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('새 품목 추가'),
          content: TextField(
            controller: _controller,
            decoration: const InputDecoration(hintText: '품목명을 입력하세요'),
            autofocus: true,
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () {
                final name = _controller.text.trim();
                if (name.isNotEmpty) {
                  _addItem(name);
                  Navigator.pop(context);
                }
              },
              child: const Text('추가', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _addItem(String name) {
    setState(() {
      items.add({
        'name': name,
        'stock': 0,
        'min': 0,
        'count': 1,
        'category': categories[selectedCategory],
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = items
        .where((item) => item['category'] == categories[selectedCategory])
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 20,
        automaticallyImplyLeading: false,
        title: const Text(
          '발주',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton(
              onPressed: () {
                // 재고 페이지 이동
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text('재고', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            // 🔍 검색창
            Container(
              margin: const EdgeInsets.only(bottom: 16),
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

            // 카테고리
            Table(
              border: TableBorder.all(color: AppColors.primary),
              children: [
                TableRow(
                  children: List.generate(3, (i) => _buildCategoryCell(i)),
                ),
                TableRow(
                  children: List.generate(3, (i) => _buildCategoryCell(i + 3)),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 📦 발주 항목 리스트
            Expanded(
              child: ListView.separated(
                itemCount: filteredItems.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final item = filteredItems[index];
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

            // 리스트 추가
            GestureDetector(
              onTap: _showAddItemDialog,
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '+ 리스트 추가',
                  style: TextStyle(color: AppColors.primary, fontSize: 16),
                ),
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

  Widget _buildCategoryCell(int index) {
    final isSelected = selectedCategory == index;
    return GestureDetector(
      onTap: () => setState(() => selectedCategory = index),
      child: Container(
        height: 48,
        alignment: Alignment.center,
        color: isSelected ? AppColors.primary : Colors.white,
        child: Text(
          categories[index],
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
