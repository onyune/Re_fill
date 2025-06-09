import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:refill/colors.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  String? storeId;

  @override
  void initState() {
    super.initState();
    _loadStoreId();
  }

  Future<void> _loadStoreId() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    print('🔑 UID: $uid');
    if (uid == null) return;

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    print('📄 userDoc.exists: ${userDoc.exists}');
    print('📦 storeId field: ${userDoc.data()?['storeId']}');

    setState(() {
      storeId = userDoc['storeId'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('발주 이력'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
      ),
      backgroundColor: AppColors.background,
      body: storeId == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('storeId', isEqualTo: storeId)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('에러 발생: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data!.docs;

          if (orders.isEmpty) {
            return const Center(child: Text('발주 내역이 없습니다.'));
          }

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index].data() as Map<String, dynamic>;
              final createdAtRaw = order['createdAt'];
              final createdAt = createdAtRaw is Timestamp
                  ? createdAtRaw.toDate()
                  : DateTime.now();

              final items = List<Map<String, dynamic>>.from(order['items']);
              final auto = order['autoOrdered'] == true;

              return ExpansionTile(
                title: Text(
                  '${createdAt.month}/${createdAt.day} ${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(auto ? '자동 발주' : '수동 발주'),
                children: items.map((item) {
                  return ListTile(
                    title: Text(item['name']),
                    trailing: Text('${item['count']}개'),
                  );
                }).toList(),
              );
            },
          );
        },
      ),
    );
  }
}
