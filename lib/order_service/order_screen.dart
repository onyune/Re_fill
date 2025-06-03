import 'package:flutter/material.dart';
import 'package:refill/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'stocks_screen.dart';

class OrderScreen extends StatefulWidget {
  final Map<String, int>? prefilledCounts;
  const OrderScreen({super.key, this.prefilledCounts});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  bool isAuto = false;
  int selectedCategory = 0;
  final List<String> categories = ['시럽', '원두/우유', '파우더', '디저트', '티', '기타'];

  List<Map<String, dynamic>> items = [];
  List<Map<String, dynamic>> filteredItems = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadOrderData();
    _searchController.addListener(_filterItemsByCategory);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadOrderData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid).get();
    final storeId = userDoc['storeId'];

    final stockSnap = await FirebaseFirestore.instance
        .collection('stocks')
        .doc(storeId)
        .collection('items')
        .get();

    final orderTemplateSnap = await FirebaseFirestore.instance
        .collection('orderTemplates')
        .get();

    final stockMap = { for (var doc in stockSnap.docs) doc.id: doc.data() };

    final combined = orderTemplateSnap.docs.map((doc) {
      final name = doc.id;
      final template = doc.data();
      final stock = stockMap[name];
      int count = 0;

      if (widget.prefilledCounts != null && widget.prefilledCounts!.containsKey(name)) {
        count = widget.prefilledCounts![name]!;
      } else {
        // 항상 최신 stock 기준으로 초기화
        count = 0;
      }

      return {
        'name': name,
        'unit': template['unit'] ?? '',
        'defaultQuantity': template['defaultQuantity'] ?? 1,
        'stock': stock?['quantity'] ?? 0,
        'min': stock?['minQuantity'] ?? 0,
        'count': count,
        'category': template['category'] ?? '기타',
      };
    }).toList();

    setState(() {
      items = combined;
      _filterItemsByCategory();
    });
  }

  void _updateCount(String name, int count) {
    setState(() {
      final itemIndex = items.indexWhere((e) => e['name'] == name);
      if (itemIndex != -1) items[itemIndex]['count'] = count;

      final filteredIndex = filteredItems.indexWhere((e) => e['name'] == name);
      if (filteredIndex != -1) filteredItems[filteredIndex]['count'] = count;

      filteredItems = List<Map<String, dynamic>>.from(filteredItems); // 강제 rebuild
    });
  }

  void _filterItemsByCategory() {
    final selected = categories[selectedCategory];
    final keyword = _searchController.text.trim();
    setState(() {
      filteredItems = items.where((item) {
        final matchCategory = item['category'] == selected;
        final matchSearch = item['name'].toString().contains(keyword);
        return matchCategory && matchSearch;
      }).map((e) => Map<String, dynamic>.from(e)).toList();
    });

    print('🔥 전체 품목 개수: ${items.length}');
    print('🔍 필터링된 품목 개수: ${filteredItems.length}');

  }

  Future<void> _confirmAndPlaceOrder() async {
    final selectedItems = items.where((item) => item['count'] > 0).toList();

    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("발주할 품목이 없습니다.")),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("발주 확인"),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("선택한 품목들로 발주를 진행할까요?\n"),
                ...selectedItems.map((item) => Text(
                  '• ${item['name']} (${item['count']}개)',
                  style: const TextStyle(fontSize: 14),
                )),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("취소")),
            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("확인")),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _placeOrder();
    }
  }

  Future<void> _placeOrder() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid).get();
    final storeId = userDoc['storeId'];
    final batch = FirebaseFirestore.instance.batch();

    for (var item in items) {
      final count = item['count'];
      final itemName = item['name'];
      final currentQty = item['stock'];
      if (count <= 0) continue;

      final newQty = currentQty + count;
      final docRef = FirebaseFirestore.instance
          .collection('stocks')
          .doc(storeId)
          .collection('items')
          .doc(itemName);

      batch.set(docRef, {
        'quantity': newQty,
      }, SetOptions(merge: true));
    }

    try {
      await batch.commit();

      await _loadOrderData();

      setState(() {
        for (final item in items) {
          item['count'] = 0;           // UI에서도 0으로
        }
        _filterItemsByCategory();      // 필터링도 갱신
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("발주가 완료되었습니다.")),
        );

        if (widget.prefilledCounts != null) {
          Navigator.of(context).pop('ordered');
        }
      }


    } catch (e) {
      print("발주 중 오류 발생: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("발주 실패. 다시 시도해주세요.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          '발주',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const StocksScreen()),
                );

                if (result == 'updated') {
                  _loadOrderData();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text('재고', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: '검색',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Table(
              border: TableBorder.all(color: AppColors.primary),
              children: [
                TableRow(children: List.generate(3, (i) => _buildCategoryCell(i))),
                TableRow(children: List.generate(3, (i) => _buildCategoryCell(i + 3))),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: filteredItems.isEmpty
                  ? const Center(child: Text("등록된 품목이 없습니다."))
                  : ListView.separated(
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
                          Text(item['name'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(
                            '현재재고 ${item['stock']} / 최소 ${item['min']}',
                            style: TextStyle(color: isShort ? Colors.red : Colors.black54),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, color: AppColors.primary),
                            onPressed: () {
                              final newCount = (item['count'] - 1).clamp(0, 99);
                              _updateCount(item['name'], newCount);
                            },
                          ),
                          Text('${item['count']}', style: const TextStyle(fontSize: 16)),
                          IconButton(
                            icon: const Icon(Icons.add, color: AppColors.primary),
                            onPressed: () {
                              final newCount = item['count'] + 1;
                              _updateCount(item['name'], newCount);
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
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                onPressed: _confirmAndPlaceOrder,
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
      onTap: () {
        setState(() {
          selectedCategory = index;
        });
        _filterItemsByCategory();
      },
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
