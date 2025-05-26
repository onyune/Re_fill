// 홈 화면 > 캘린더 위젯

import 'package:flutter/material.dart';
import 'package:refill/colors.dart';
import 'package:table_calendar/table_calendar.dart';

class HolidayCalendar extends StatefulWidget {
  const HolidayCalendar({super.key});

  @override
  State<HolidayCalendar> createState() => _HolidayCalendarState();
}

class _HolidayCalendarState extends State<HolidayCalendar> {
  final Map<DateTime, List<String>> holidayEvents = {
    DateTime.utc(2025, 5, 5): ['어린이날'],
    DateTime.utc(2025, 5, 15): ['석가탄신일'],
    DateTime.utc(2025, 6, 6): ['현충일'],
  };

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final mainBlue = AppColors.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                color: mainBlue.withAlpha((0.8 * 255).round()),
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
      ],
    );
  }
}
