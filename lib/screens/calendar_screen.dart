// Updated CalendarScreen to Show Shifts for Each Day

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_app_group5/screens/shift_management_screen.dart';
import 'package:mobile_app_group5/themes/app_theme.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  Map<DateTime, List<Map<String, dynamic>>> _shiftEvents = {};

  @override
  void initState() {
    super.initState();
    _fetchShifts();
  }

  void _fetchShifts() async {
    try {
      QuerySnapshot snapshot = await firestore.collection('shifts').get();
      Map<DateTime, List<Map<String, dynamic>>> shiftMap = {};
      for (var doc in snapshot.docs) {
        if (doc['date'] != null) {
          DateTime shiftDate = (doc['date'] as Timestamp).toDate();
          DateTime dateOnly =
              DateTime(shiftDate.year, shiftDate.month, shiftDate.day);
          if (shiftMap[dateOnly] == null) {
            shiftMap[dateOnly] = [];
          }
          shiftMap[dateOnly]!.add({
            "startTime": (doc['startTime'] != null)
                ? (doc['startTime'] as Timestamp).toDate()
                : null,
            "endTime": (doc['endTime'] != null)
                ? (doc['endTime'] as Timestamp).toDate()
                : null,
            "assignedUserId": doc['assignedUserId'],
            "title": doc['title'] ?? "No Title",
          });
        }
      }
      setState(() {
        _shiftEvents = shiftMap;
      });
    } catch (e) {
      print('Error fetching shifts: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching shifts: $e')),
      );
    }
  }

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
      appBar: AppBar(
        title: const Text(
          'Calendar',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.blueColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TableCalendar(
          focusedDay: DateTime.now(),
          firstDay: DateTime.utc(2020, 01, 01),
          lastDay: DateTime.utc(2025, 12, 31),
          calendarFormat: CalendarFormat.month,
          eventLoader: (date) => _shiftEvents[date] ?? [],
          onDaySelected: (selectedDay, focusedDay) {
            _onDateSelected(context, selectedDay);
          },
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
          ),
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              shape: BoxShape.circle,
            ),
            todayTextStyle: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
