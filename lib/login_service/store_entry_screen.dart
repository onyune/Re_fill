import 'package:flutter/material.dart';

import 'store_create_screen.dart';
import 'invite_code_screen.dart';
import 'package:refill/colors.dart';


class StoreEntryScreen extends StatelessWidget {
  const StoreEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Re:fill',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '자동 발주,\n똑똑한 재고 관리의 시작',
                style: TextStyle(
                    fontSize: 25,
                    height: 1.4,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 32),

              //새루운운 매장 생성
             GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primary),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/store_create.png',
                        height: 100,
                      ),
                      const SizedBox(height: 12),
                     ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const StoreCreateScreen()),
                          );
                        },
                        style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(AppColors.primary),
                          foregroundColor: WidgetStatePropertyAll(AppColors.background),
                          textStyle: WidgetStatePropertyAll(TextStyle(fontSize: 16)),
                        ),
                        child: Text('+새로운 매장 생성'),
                      )
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 초대 코드 입력
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primary),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/invite_code.png',
                        height: 100,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const InviteCodeScreen()),
                          );
                        },
                        style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(AppColors.primary),
                          foregroundColor: WidgetStatePropertyAll(AppColors.background),
                          textStyle: WidgetStatePropertyAll(TextStyle(fontSize: 16)),
                        ),
                        child: Text('+초대 코드 입력'),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
