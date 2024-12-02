import 'package:flutter/material.dart';
import 'package:mobile_app_group5/themes/app_theme.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_app_group5/screens/shift_management_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_app_group5/widgets/small_shift_card_widget.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final User? currentUser = FirebaseAuth.instance.currentUser;
  Map<DateTime, List<Map<String, dynamic>>> _shiftEvents = {};
  DateTime _selectedDate = DateTime.now();
  List<Map<String, dynamic>> _shiftsForSelectedDate = [];

  @override
  void initState() {
    super.initState();
    _fetchShifts();
  }

  // Fetch all shifts for the current user
  void _fetchShifts() async {
    if (currentUser == null) return;

    try {
      QuerySnapshot snapshot = await firestore
          .collection('shifts')
          .where('assignedUserId', isEqualTo: currentUser!.uid)
          .get();

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
            "id": doc.id,
            "date": dateOnly,
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
        _fetchShiftsForMonth(_selectedDate);
      });
    } catch (e) {
      print('Error fetching shifts: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching shifts: $e')),
      );
    }
  }

  // Fetch all shifts for the selected month
  void _fetchShiftsForMonth(DateTime date) {
    DateTime firstDayOfMonth = DateTime(date.year, date.month, 1);
    DateTime lastDayOfMonth = DateTime(date.year, date.month + 1, 0);

    List<Map<String, dynamic>> allShifts = [];
    _shiftEvents.forEach((date, shifts) {
      if (date.isAfter(firstDayOfMonth.subtract(Duration(days: 1))) &&
          date.isBefore(lastDayOfMonth.add(Duration(days: 1)))) {
        allShifts.addAll(shifts);
      }
    });

    setState(() {
      _selectedDate = date;
      _shiftsForSelectedDate = allShifts;
    });
  }

  // Navigate to ShiftManagementScreen when a date is selected
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    _fetchShiftsForMonth(selectedDay);

    // Navigate to ShiftManagementScreen for the selected day
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShiftManagementScreen(selectedDate: selectedDay),
      ),
    );
  }

  // Navigate to ShiftManagementScreen when a shift is tapped
  void _onShiftTapped(Map<String, dynamic> shift) {
    DateTime shiftDate = shift['date'];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShiftManagementScreen(selectedDate: shiftDate),
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TableCalendar(
              focusedDay: _selectedDate,
              firstDay: DateTime.utc(2020, 01, 01),
              lastDay: DateTime.utc(2025, 12, 31),
              calendarFormat: CalendarFormat.month,
              eventLoader: (date) => _shiftEvents[date] ?? [],
              onDaySelected: (selectedDay, focusedDay) {
                _onDaySelected(selectedDay, focusedDay);
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
          const Divider(
            thickness: 2,
            color: AppTheme.blueColor,
          ),
          const SizedBox(height: 20), // Adds some margin below the divider
          Expanded(
            child: ListView.builder(
              itemCount: _shiftsForSelectedDate.length,
              itemBuilder: (context, index) {
                final shift = _shiftsForSelectedDate[index];
                return GestureDetector(
                  onTap: () =>
                      _onShiftTapped(shift), // Updated to call _onShiftTapped
                  child: SmallShiftCardWidget(
                    shift: shift,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
