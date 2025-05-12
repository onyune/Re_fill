import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '설정',
          style: TextStyle(
            color: Color(0xFF2563EB), // mainBlue 직접 넣기
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.transparent, // 파란색 띠 제거
        elevation: 0, // 그림자 제거
        centerTitle: false, // 왼쪽 정렬
        iconTheme: const IconThemeData(color: Color(0xFF2563EB)), // 아이콘도 파란색
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueAccent.shade100),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    '안녕하세요!\n관리자 ○○○ 님',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: Center(
                          child: Text(
                            '멤버 목록',
                            style: TextStyle(color: Colors.black54),
                          ),
                        ),
                      ),
                      VerticalDivider(thickness: 1, width: 1),
                      Expanded(
                        child: Center(
                          child: Text(
                            '팀 관리',
                            style: TextStyle(color: Colors.black54),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text('계정 설정', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SwitchListTile(
              title: Text('재고 부족 알림 설정'),
              value: true,
              onChanged: (value) {},
              activeColor: Color(0xFF2563EB),
            ),
            SwitchListTile(
              title: Text('다크 모드'),
              value: false,
              onChanged: (value) {},
              activeColor: Color(0xFF2563EB),
            ),
            const SizedBox(height: 24),
            const Text('공지사항', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            const Text('문의', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
