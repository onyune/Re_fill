import 'package:flutter/material.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  bool isAuto = false;

  final Color mainBlue = Color(0xFF2563EB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '발주',
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 검색창
              TextField(
                decoration: InputDecoration(
                  hintText: '검색',
                  prefixIcon: Icon(Icons.search, color: mainBlue),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: mainBlue, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: mainBlue),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 자동/수동 발주 토글
              Center(
                child: ToggleButtons(
                  isSelected: [!isAuto, isAuto],
                  onPressed: (index) {
                    setState(() {
                      isAuto = index == 1;
                    });
                  },
                  borderRadius: BorderRadius.circular(10),
                  selectedColor: Colors.white,
                  fillColor: mainBlue,
                  color: mainBlue,
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 60),
                      child: Text('수동 발주'),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 60),
                      child: Text('자동 발주'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 발주 내용
              Expanded(
                child: isAuto
                    ? const Center(child: Text('자동 발주 화면'))
                    : const Center(child: Text('수동 발주 화면')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
