import 'package:flutter/material.dart';
import 'package:refill/colors.dart';

import 'create_store_screen.dart';
import 'invite_code_screen.dart';

class FirstScreen extends StatelessWidget {
  const FirstScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),

            // 🔷 타이틀
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Re:fill',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '자동 발주,\n똑똑한 재고 관리의 시작',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 🔷 카드들
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // 📦 매장 생성 카드
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CreateStoreScreen(),
                            ),
                          );
                        },
                        child: Container(
                          width: 320,
                          height: 220,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.primary),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.asset(
                                  'assets/images/create_store.png',
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => const CreateStoreScreen()),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      elevation: 4,
                                      shadowColor: AppColors.black,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                      minimumSize: const Size(220, 45),
                                    ),
                                    child: const Text(
                                      '+ 새로운 매장 생성',
                                      style: TextStyle(
                                        color: AppColors.background,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // 📦 초대 코드 카드
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const InviteCodeScreen(),
                            ),
                          );
                        },
                        child: Container(
                          width: 320,
                          height: 220,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.primary),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // ✅ 이미지 둥글게 ClipRRect
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.asset(
                                  'assets/images/invite_code.png',
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),
                              // ✅ 버튼 오버레이
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const InviteCodeScreen(),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      elevation: 4,
                                      shadowColor: AppColors.black,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 10),
                                      minimumSize: const Size(220, 45),
                                    ),
                                    child: const Text(
                                      '+ 초대 코드 입력',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
