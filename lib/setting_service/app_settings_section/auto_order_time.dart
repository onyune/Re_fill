import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:refill/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class AutoOrderTime extends StatefulWidget {
  const AutoOrderTime({super.key});

  @override
  State<AutoOrderTime> createState() => _AutoOrderTimeState();
}

class _AutoOrderTimeState extends State<AutoOrderTime> {
  int selectedHour = 12;
  int selectedMinute = 0;
  String selectedPeriod = 'AM';
  String savedTime = '';

  final List<String> periods = ['AM', 'PM'];
  final List<int> hours = List.generate(12, (index) => index + 1);
  final List<int> minutes = List.generate(60, (index) => index);

  @override
  void initState() {
    super.initState();
    _loadSavedTime();
  }

  Future<void> _loadSavedTime() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      savedTime = prefs.getString('auto_order_time') ?? '';
    });
  }

  Future<void> _saveTime() async {
    final prefs = await SharedPreferences.getInstance();
    final time = '$selectedPeriod ${selectedHour.toString().padLeft(2, '0')}:${selectedMinute.toString().padLeft(2, '0')}';
    await prefs.setString('auto_order_time', time);
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final storeId = userDoc['storeId'];

      await FirebaseFirestore.instance.collection('stores').doc(storeId).update({
        'autoOrderTime': time,
      });
    }
    setState(() {
      savedTime = time;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('자동 발주 시간이 저장되었습니다.')),
    );
  }

  Widget _buildPicker(List list, int selected, Function(int) onSelected) {
    return CupertinoPicker(
      scrollController: FixedExtentScrollController(initialItem: list.indexOf(selected)),
      itemExtent: 40,
      diameterRatio: 1.2,
      onSelectedItemChanged: (index) => onSelected(list[index]),
      children: list.map((item) => Center(child: Text('$item', style: const TextStyle(fontSize: 20, color: AppColors.primary)))).toList(),
    );
  }

  Widget _buildPeriodPicker() {
    return CupertinoPicker(
      scrollController: FixedExtentScrollController(initialItem: periods.indexOf(selectedPeriod)),
      itemExtent: 40,
      diameterRatio: 1.2,
      onSelectedItemChanged: (index) => setState(() => selectedPeriod = periods[index]),
      children: periods.map((p) => Center(child: Text(p, style: const TextStyle(fontSize: 20, color: AppColors.primary)))).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소', style: TextStyle(color: AppColors.primary)),
        ),
        centerTitle: true,
        title: const Text('알람 설정', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: _saveTime,
            child: const Text('저장', style: TextStyle(color: AppColors.primary)),
          )
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Center(
              child: SizedBox(
                height: 180,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 80, child: _buildPeriodPicker()),
                    SizedBox(width: 80, child: _buildPicker(hours, selectedHour, (v) => setState(() => selectedHour = v))),
                    SizedBox(width: 80, child: _buildPicker(minutes, selectedMinute, (v) => setState(() => selectedMinute = v))),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 32),
            child: Text(
              savedTime.isEmpty ? '저장된 알람 시간 없음' : '저장된 알람 시간: $savedTime',
              style: const TextStyle(color: AppColors.primary, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

