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
  String? storeName;
  bool isLoading = true;
  static const mainBlue = AppColors.primary;

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
      body: SafeArea(
        child: SingleChildScrollView(
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

              // 재고 부족 현황 보러가기 버튼
              InkWell(
                onTap: () {
                  print("전체 버튼 클릭됨");
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFEFEF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Text(
                            '재고부족 현황 보러가기',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 8),
                          Text('⚠️', style: TextStyle(fontSize: 16)),
                        ],
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  ),
                ),
              ),

              // 날씨 박스
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                decoration: BoxDecoration(
                  border: Border.all(color: mainBlue),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const WeatherBox(),
              ),
              const SizedBox(height: 24),

              // 캘린더
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

              // 재고 예측 추천
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
                          foregroundColor: Colors.white,
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

              // 재고 부족 현황
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
    );
  }
}
