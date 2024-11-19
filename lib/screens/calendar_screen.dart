// calendar_screen.dart
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:mobile_app_group5/screens/shift_management_screen.dart'; // Import the new screen

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  void _onDateSelected(BuildContext context, DateTime date) {
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
            _onDateSelected(context, selectedDay);
          },
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
          ),
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color:
                  Theme.of(context).colorScheme.secondary, // Using theme color
              shape: BoxShape.circle,
            ),
            todayTextStyle: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
