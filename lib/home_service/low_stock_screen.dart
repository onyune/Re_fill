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
  List<Map<String, dynamic>> filteredItems = [];
  final List<String> categories = ['시럽', '원두/우유', '파우더', '디저트', '티', '기타'];
  int selectedCategory = 0;
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadData();
    _searchController.addListener(_filterItems);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
      final category = data['category'] ?? '기타';

      if (quantity < minQuantity) {
        result.add({
          'name': name,
          'quantity': quantity,
          'minQuantity': minQuantity,
          'category': category,
        });
      }
    }

    setState(() {
      items = result;
      isLoading = false;
      _filterItems();
    });
  }

  void _filterItems() {
    final selected = categories[selectedCategory];
    final keyword = _searchController.text.trim();

    setState(() {
      filteredItems = items.where((item) {
        final matchCategory = item['category'] == selected;
        final matchSearch = item['name'].toString().contains(keyword);
        return matchCategory && matchSearch;
      }).toList();
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
      loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text(
          '재고 부족 현황',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
          ? const Center(child: Text("현재 부족한 재고가 없습니다."))
          : Padding(
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
              child: ListView.separated(
                itemCount: filteredItems.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final item = filteredItems[index];
                  return ListTile(
                    title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      "현재 수량: ${item['quantity']} / 최소 수량: ${item['minQuantity']}",
                      style: const TextStyle(color: Colors.red),
                    ),
                    trailing: const Icon(Icons.warning, color: Colors.red),
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
                onPressed: _navigateToOrderWithCounts,
                child: const Text('발주 목록에 추가하기', style: TextStyle(fontSize: 16, color: Colors.white)),
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
        _filterItems();
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
