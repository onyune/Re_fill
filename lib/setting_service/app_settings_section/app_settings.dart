// 설정 화면 > 알림 및 재고 최소 수량 설정

import 'package:flutter/material.dart';
import 'package:refill/colors.dart';
import 'auto_order_time.dart';
import 'min_stock.dart';

class AppSettingsSection extends StatelessWidget {
  final bool lowStockNotification;
  final ValueChanged<bool> onToggleLowStock;
  final String role;

  const AppSettingsSection({
    super.key,
    required this.lowStockNotification,
    required this.onToggleLowStock,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('앱 설정',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('재고 부족 알림 설정'),
          value: lowStockNotification,
          onChanged: onToggleLowStock,
          activeColor: AppColors.primary,
        ),
        if (role != 'staff')
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('재고 최소 수량 설정'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MinStockListPage()),
            ),
          ),
          ListTile( //추가한거
            contentPadding: EdgeInsets.zero,
            title: const Text('자동 발주 시간 설정'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AutoOrderTime()),
            ),
          ),
        Divider(thickness: 0.8, color: Colors.grey.shade300),
        const SizedBox(height: 24),
      ],
    );
  }
}
