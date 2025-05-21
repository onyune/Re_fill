import 'package:flutter/material.dart';

class StockItem {
  final String name;
  int minQuantity;

  StockItem({required this.name, required this.minQuantity});
}

class MinStockListPage extends StatefulWidget {
  const MinStockListPage({super.key});

  @override
  State<MinStockListPage> createState() => _MinStockListPageState();
}

class _MinStockListPageState extends State<MinStockListPage> {
  final List<StockItem> stockItems = [
    StockItem(name: '우유', minQuantity: 5) //테스트용으로써봄
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('최소 재고 설정',
          style: TextStyle(color: Color(0xFF2563EB),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
          ),
      ),
      body: ListView.separated(
        itemCount: stockItems.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final item = stockItems[index];
          return ListTile(
            title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove, color: Color(0xFF2563EB)),
                  onPressed: () {
                    setState(() {
                      if (item.minQuantity > 0) item.minQuantity--;
                    });
                  },
                ),
                Text('${item.minQuantity}', style: const TextStyle(fontSize: 16)),
                IconButton(
                  icon: const Icon(Icons.add, color: Color(0xFF2563EB)),
                  onPressed: () {
                    setState(() {
                      item.minQuantity++;
                    });
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
