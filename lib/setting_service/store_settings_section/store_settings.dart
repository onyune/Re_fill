// 설정 화면 > 매장 변경, 팀 관리

import 'package:flutter/material.dart';

import 'team_management_screen.dart';

class StoreSettingsSection extends StatelessWidget {
  final String role;

  const StoreSettingsSection({
    super.key,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('매장 설정',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        if (role == 'owner')
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('팀 관리'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TeamManagementScreen()),
            ),
          ),
        Divider(thickness: 0.8, color: Colors.grey.shade300),
        const SizedBox(height: 24),
      ],
    );
  }
}
