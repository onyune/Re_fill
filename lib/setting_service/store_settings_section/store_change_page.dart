import 'package:flutter/material.dart';
import 'package:refill/colors.dart';

class StoreChangePage extends StatelessWidget {
  const StoreChangePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('매장 변경',
        style: TextStyle(color: AppColors.primary,
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),),
      ),
      body: ListView(
        children: const [
          ListTile(
            title: Text('00커피 00점'), //그냥 예시로 넣어둠
            trailing: Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}
