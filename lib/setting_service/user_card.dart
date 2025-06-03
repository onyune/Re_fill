// 설정 화면 > 사용자 이름 & 역할 표시 카드

import 'package:flutter/material.dart';
import 'package:refill/colors.dart';

class UserCard extends StatelessWidget {
  final String userName;
  final String role;

  const UserCard({
    super.key,
    required this.userName,
    required this.role,
  });

  String _getRoleLabel(String role) {
    switch (role) {
      case 'owner':
        return '점주';
      case 'manager':
        return '매니저';
      default:
        return '직원';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primary.withAlpha(128)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.background,
            child: Icon(Icons.person, size: 40, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('안녕하세요!',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary)),
                const SizedBox(height: 8),
                Text(
                  '${_getRoleLabel(role)} $userName 님',
                  style: const TextStyle(fontSize: 16, color: AppColors.primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
