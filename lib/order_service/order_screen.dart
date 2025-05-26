import 'package:flutter/material.dart';
import 'package:refill/colors.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  bool isAuto = false;
  final List<Map<String, dynamic>> items = [];

  void _addItem(String name) {
    setState(() {
      items.add({'name': name, 'stock': 0, 'count': 1});
    });
  }

  void _showAddItemDialog() {
    final TextEditingController _controller = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: true,
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

  void _placeOrder() {
    debugPrint('장바구니: $items');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '발주',
          style: TextStyle(
            color: Color(0xFF2563EB),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Color(0xFF2563EB)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            // 검색창
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

            // 자동 발주 스위치
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

            // 항목 리스트
            Expanded(
              child: ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item['name'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text('현재재고 ${item['stock']}'),
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

            // 리스트 추가 버튼
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

            // 발주 버튼
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
