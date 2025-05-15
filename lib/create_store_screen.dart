import 'package:flutter/material.dart';

class CreateStoreScreen extends StatelessWidget {
  const CreateStoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final storeNameController = TextEditingController();
    final addressController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('새로운 매장 생성'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: storeNameController,
              decoration: const InputDecoration(labelText: '매장 이름'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(labelText: '주소'),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // 매장 생성 처리
              },
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF2563EB)),
              child: const Text('생성'),
            )
          ],
        ),
      ),
    );
  }
}
