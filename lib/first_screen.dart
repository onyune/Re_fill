import 'package:flutter/material.dart';

class FirstScreen extends StatelessWidget {
  const FirstScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              const Text(
                'Re:fill',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
              ),
              const SizedBox(height: 8),
              const Text('자동 발주, 똑똑한 재고 관리의 시작', style: TextStyle(fontSize: 18)),
              const Spacer(),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // 매장 생성 화면으로 이동
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2563EB),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  child: const Text('＋ 새로운 매장 생성', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}
