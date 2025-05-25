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
  final Color mainBlue = AppColors.primary;

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

            // 수동/자동 발주 전환 버튼
            Center(
              child: ToggleButtons(
                isSelected: [!isAuto, isAuto],
                onPressed: (index) {
                  setState(() {
                    isAuto = index == 1;
                  });
                },
                borderRadius: BorderRadius.circular(10),
                selectedColor: AppColors.background,
                fillColor: AppColors.primary,
                color: AppColors.primary,
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 60),
                    child: Text('수동 발주'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 60),
                    child: Text('자동 발주'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

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
