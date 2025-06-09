import 'package:flutter/material.dart';
import 'package:refill/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:refill/home_service/weather_box.dart';
import 'package:table_calendar/table_calendar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
<<<<<<< HEAD

=======
  String? storeName;
  bool isLoading = true;
  static const mainBlue = AppColors.primary;
>>>>>>> a5d1e7aa1258e5ba88c3c0b5f70a804c14a9bca3

  final Map<DateTime, List<String>> holidayEvents = {
    DateTime.utc(2025, 5, 5): ['어린이날'],
    DateTime.utc(2025, 5, 15): ['석가탄신일'],
    DateTime.utc(2025, 6, 6): ['현충일'],
  };

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _loadStoreName();
  }

  Future<void> _loadStoreName() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final storeId = userDoc.data()?['storeId'];

      if (storeId == null) {
        setState(() {
          storeName = '매장에 가입되지 않았습니다';
          isLoading = false;
        });
        return;
      }

      final storeDoc = await FirebaseFirestore.instance.collection('stores').doc(storeId).get();
      if (storeDoc.exists) {
        setState(() {
          storeName = storeDoc.data()?['storeName'] ?? '이름 없는 매장';
          isLoading = false;
        });
      } else {
        setState(() {
          storeName = '매장 정보를 찾을 수 없습니다';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        storeName = '매장 정보를 불러오는 중 오류';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
<<<<<<< HEAD
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
=======
      appBar: AppBar(
        title: const Text("홈"),
        backgroundColor: mainBlue,
        foregroundColor: AppColors.background,
      ),
      body: SafeArea(
>>>>>>> a5d1e7aa1258e5ba88c3c0b5f70a804c14a9bca3
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isLoading ? '불러오는 중...' : (storeName ?? '매장명 없음'),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: mainBlue,
                  ),
                ),
                const SizedBox(height: 16),
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
                const SizedBox(height: 24),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.primary),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const WeatherBox(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: mainBlue),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.show_chart, size: 28, color: mainBlue),
                              SizedBox(height: 4),
                              Text('재고 부족', style: TextStyle(fontWeight: FontWeight.bold, color: mainBlue)),
                              Text('남은 수량 100', style: TextStyle(color: mainBlue)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: mainBlue),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TableCalendar(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    eventLoader: (day) {
                      return holidayEvents[DateTime.utc(day.year, day.month, day.day)] ?? [];
                    },
                    calendarStyle: CalendarStyle(
                      markerDecoration: const BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                      todayDecoration: BoxDecoration(
                        color: mainBlue.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: mainBlue,
                        shape: BoxShape.circle,
                      ),
                    ),
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                    ),
                  ),
                ),
                if (_selectedDay != null &&
                    holidayEvents[DateTime.utc(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day)] != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      '📌 ${holidayEvents[DateTime.utc(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day)]!.join(', ')}',
                      style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.w500),
                    ),
                  ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: mainBlue),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('재고 예측 추천',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: mainBlue)),
                      const SizedBox(height: 8),
                      const Text('오늘 아이스류 소비 증가 예상!', style: TextStyle(color: mainBlue)),
                      const SizedBox(height: 4),
                      const Text('• 아이스 아메리카노', style: TextStyle(color: mainBlue)),
                      const Text('• 얼음컵 등', style: TextStyle(color: mainBlue)),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.add_shopping_cart),
                          label: const Text('발주에 추가'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: mainBlue,
                            foregroundColor: AppColors.background,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: mainBlue),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('재고 부족 현황',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: mainBlue)),
                      SizedBox(height: 8),
                      Text('• 아이스티 파우더: 1개 남음', style: TextStyle(color: mainBlue)),
                      Text('• 초코 파우더: 1개 남음', style: TextStyle(color: mainBlue)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
