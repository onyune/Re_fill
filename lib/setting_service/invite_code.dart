// 설정 화면 > 초대 코드 생성/표시 (점주 전용)

import 'package:flutter/material.dart';
import 'package:refill/colors.dart';

class InviteCodeSection extends StatelessWidget {
  final bool isInviteCodeGenerated;
  final String inviteCode;
  final VoidCallback onGenerateInviteCode;

  const InviteCodeSection({
    super.key,
    required this.isInviteCodeGenerated,
    required this.inviteCode,
    required this.onGenerateInviteCode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('팀 초대',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (!isInviteCodeGenerated)
          ElevatedButton(
            onPressed: onGenerateInviteCode,
            style:
            ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('초대코드 생성',
                style: TextStyle(color: Colors.white)),
          ),
        if (inviteCode.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text('초대코드: $inviteCode'),
        ],
        const SizedBox(height: 24),
      ],
    );
  }
}
