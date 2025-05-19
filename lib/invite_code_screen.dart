import 'package:flutter/material.dart';
import 'home_screen.dart';

class InviteCodeScreen extends StatelessWidget {
  const InviteCodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final inviteCodeController = TextEditingController();
    return Scaffold(
      backgroundColor: const Color(0xFFFBF7FF),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Re:fill',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2563EB),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '초대 코드 입력',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2563EB),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              '초대 코드 입력',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF2563EB),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: inviteCodeController,
              decoration: InputDecoration(
                hintText: '초대 코드를 입력하세요.',
                hintStyle: const TextStyle(color:  Colors.grey),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFF2563EB)),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // 홈 화면으로 이동
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '지점 등록하기',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}