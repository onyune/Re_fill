import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  List<StockItem> stockItems = [];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final storeId = userDoc['storeId'];

    final templates = await FirebaseFirestore.instance.collection('orderTemplates').get();
    final stocks = await FirebaseFirestore.instance
        .collection('stocks')
        .doc(storeId)
        .collection('items')
        .get();

    final stockMap = {
      for (var doc in stocks.docs) doc.id: doc.data()
    };

    final List<StockItem> loadedItems = templates.docs.map((doc) {
      final name = doc.id;
      final minQty = stockMap[name]?['minQuantity'] ?? 0;
      return StockItem(name: name, minQuantity: minQty);
    }).toList();

    setState(() {
      stockItems = loadedItems;
    });
  }

  Future<void> _updateMinQuantity(String name, int newMin) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final storeId = userDoc['storeId'];

    final docRef = FirebaseFirestore.instance
        .collection('stocks')
        .doc(storeId)
        .collection('items')
        .doc(name);

    await docRef.set({'minQuantity': newMin}, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '최소 재고 설정',
          style: TextStyle(
            color: Color(0xFF2563EB),
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
            title: Text(
              item.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove, color: Color(0xFF2563EB)),
                  onPressed: () {
                    setState(() {
                      if (item.minQuantity > 0) item.minQuantity--;
                    });
                    _updateMinQuantity(item.name, item.minQuantity);
                  },
                ),
                Text('${item.minQuantity}', style: const TextStyle(fontSize: 16)),
                IconButton(
                  icon: const Icon(Icons.add, color: Color(0xFF2563EB)),
                  onPressed: () {
                    setState(() {
                      item.minQuantity++;
                    });
                    _updateMinQuantity(item.name, item.minQuantity);
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
