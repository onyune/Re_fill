import 'package:flutter/material.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  bool isAuto = false;
  final Color mainBlue = const Color(0xFF2563EB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('발주'),
        backgroundColor: mainBlue,
        foregroundColor: Colors.white,
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

              // 수동/자동 발주 전환 버튼
              ToggleButtons(
                isSelected: [!isAuto, isAuto],
                onPressed: (index) {
                  setState(() {
                    isAuto = index == 1;
                  });
                },
                borderRadius: BorderRadius.circular(10),
                selectedColor: Colors.white,
                fillColor: mainBlue,
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

              // 화면 내용
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
