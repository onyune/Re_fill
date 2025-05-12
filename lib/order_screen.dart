import 'package:flutter/material.dart';


class OrderScreen extends StatelessWidget {
  const OrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const mainBlue = Color(0xFF2563EB);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상단 제목
              const Text(
                '발주',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: mainBlue,
                ),
              ),
              const SizedBox(height: 20), // 제목과 검색창 사이 여유

              // 검색창
              TextField(
                decoration: InputDecoration(
                  hintText: '검색',
                  prefixIcon: const Icon(Icons.search, color: mainBlue),
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

              const SizedBox(height: 24), // 아래 본문 영역 여유

              // 여기에 향후 발주 리스트나 기능 넣기
              // 예시: 발주 추천 리스트 등
            ],
          ),
        ),

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  bool isAuto = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('발주'),
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          ToggleButtons(
            isSelected: [!isAuto, isAuto],
            onPressed: (index) {
              setState(() {
                isAuto = index == 1;
              });
            },
            borderRadius: BorderRadius.circular(10),
            selectedColor: Colors.white,
            fillColor: const Color(0xFF2563EB),
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
          const SizedBox(height: 20),
          Expanded(
            child: isAuto
                ? const Center(child: Text('자동 발주 화면'))
                : const Center(child: Text('수동 발주 화면')),
          ),
        ],

      ),
    );
  }
}
