import 'package:flutter/material.dart';

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
