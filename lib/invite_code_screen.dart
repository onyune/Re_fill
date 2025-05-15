import 'package:flutter/material.dart';

class InviteCodeScreen extends StatelessWidget {
  const InviteCodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final inviteCodeController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('초대 코드 입력'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: inviteCodeController,
              decoration: const InputDecoration(labelText: '초대 코드 입력'),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // 코드 검증 로직
              },
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF2563EB)),
              child: const Text('확인'),
            ),
          ],
        ),
      ),
    );
  }
}
