// calendar_screen.dart
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:mobile_app_group5/widgets/bottom_nav_bar.dart';
import 'package:mobile_app_group5/screens/chat_screen.dart';
import 'package:mobile_app_group5/screens/channels.dart';
import 'package:mobile_app_group5/screens/shift_management_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  int _currentIndex = 2; // Track current tab index

  void _onNavBarTap(int index) {
    setState(() {
      _currentIndex = index;
    });

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ChatScreen()),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ChannelScreen()),
      );
    }
  }

  void _onDateSelected(DateTime date) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShiftManagementScreen(selectedDate: date),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TableCalendar(
          focusedDay: DateTime.now(),
          firstDay: DateTime.utc(2020, 01, 01),
          lastDay: DateTime.utc(2025, 12, 31),
          currentDay: DateTime.now(),
          calendarFormat: CalendarFormat.month,
          onDaySelected: (selectedDay, focusedDay) {
            _onDateSelected(selectedDay);
          },
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
          ),
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            todayTextStyle: TextStyle(color: Colors.white),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        onTap: _onNavBarTap,
        currentIndex: _currentIndex,
      ),
    );
  }
}
