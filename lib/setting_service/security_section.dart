// 설정 화면 > 비밀번호 변경, 계정 삭제, 로그아웃

import 'package:flutter/material.dart';
import 'package:refill/colors.dart';

class SecuritySection extends StatelessWidget {
  final bool isGoogleUser;
  final VoidCallback onResetPassword;
  final VoidCallback onDeleteAccount;
  final VoidCallback onLogout;

  const SecuritySection({
    super.key,
    required this.isGoogleUser,
    required this.onResetPassword,
    required this.onDeleteAccount,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('개인/보안',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        if (!isGoogleUser)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('비밀번호 변경'),
            onTap: onResetPassword,
          ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('계정 탈퇴'),
          onTap: onDeleteAccount,
        ),
        const SizedBox(height: 24),
        Center(
          child: TextButton(
            onPressed: onLogout,
            child: const Text(
              '로그아웃',
              style: TextStyle(
                color: AppColors.borderDefault,
                decoration: TextDecoration.underline,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
