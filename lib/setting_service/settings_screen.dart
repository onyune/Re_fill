import 'package:flutter/material.dart';
import 'package:refill/setting_service/min_stock.dart'; //재고 최소 수량 설정
import 'package:refill/setting_service/store_change_page.dart'; //매장 변경
import 'package:refill/setting_service/team_manage_page.dart'; // 팀원 관리


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool lowStockNotification = true;
  bool darkMode = false;
  bool isAutoOrderEnabled = true;

  final Color mainBlue = const Color(0xFF2563EB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '설정',
          style: TextStyle(
            color: Color(0xFF2563EB),
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Color(0xFF2563EB)),
      ),
      backgroundColor: const Color(0xFFFBF7FF),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 사용자 카드
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: mainBlue.withAlpha((0.5 * 255).toInt())),


                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person, size: 40, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          '안녕하세요!',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '관리자 ○○○ 님',
                          style: TextStyle(fontSize: 16, color: Color(0xFF2563EB)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 재고 설정
            const Text('재고 설정', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SwitchListTile(
              contentPadding: EdgeInsets.zero, //좌우여백없애는거
              title: const Text('자동 발주'),
              value: isAutoOrderEnabled,
              onChanged: (value) {
                setState(() {
                  isAutoOrderEnabled = value;
                });
              },
              activeColor: mainBlue,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('재고 부족 알림 설정'),
              value: lowStockNotification,
              onChanged: (value) {
                setState(() => lowStockNotification = value);
              },
              activeColor: mainBlue,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('재고 최소 수량 설정'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MinStockListPage()),
                );},
            ),
            Divider(thickness: 0.8, color: Colors.grey.shade300),

            const SizedBox(height: 24),


            // 매장 설정
            const Text('매장 설정', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('매장 변경'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const StoreChangePage()),
                );
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('팀원 관리'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TeamManagePage()),
                );
              },
            ),
            Divider(thickness: 0.8, color: Colors.grey.shade300),


            const SizedBox(height: 24),

            // 개인/보안
            const Text('개인/보안', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('비밀번호 변경'),
              onTap: () {},
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('계정 탈퇴'),
              onTap: () {},
            ),
            Divider(thickness: 0.8, color: Colors.grey.shade300),

            const SizedBox(height: 24),

            // 로그아웃
            Center(
              child: TextButton(
                onPressed: () {
                  // 로그아웃 처리
                },
                child: const Text(
                  '로그아웃',
                  style: TextStyle(
                    color: Colors.grey,
                    decoration: TextDecoration.underline,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
