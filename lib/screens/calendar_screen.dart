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

  DateTime _selectedDate = DateTime.now();

  // Navigate to ShiftManagementScreen when a date is selected
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDate = selectedDay;
    });

    // Navigate to ShiftManagementScreen for the selected day
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShiftManagementScreen(selectedDate: selectedDay),
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
              onDaySelected: (selectedDay, focusedDay) {
                _onDaySelected(selectedDay, focusedDay);
              },
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: AppTheme.blueColor,
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
            child: StreamBuilder<QuerySnapshot>(
              stream: firestore
                  .collection('shifts')
                  .where('assignedUserId', isEqualTo: currentUser!.uid)
                  .snapshots(), // Fetch all shifts for the current user
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                      child:
                          Text('No shifts available for the selected month.'));
                }

                // Filter shifts locally for the selected month
                List<Map<String, dynamic>> shifts = snapshot.data!.docs
                    .map((doc) {
                      DateTime shiftDate = (doc['date'] as Timestamp).toDate();
                      if (shiftDate.year == _selectedDate.year &&
                          shiftDate.month == _selectedDate.month) {
                        String assignedUserId = doc['assignedUserId'] ?? '';
                        return {
                          "id": doc.id,
                          "date": shiftDate,
                          "startTime": (doc['startTime'] != null)
                              ? (doc['startTime'] as Timestamp).toDate()
                              : null,
                          "endTime": (doc['endTime'] != null)
                              ? (doc['endTime'] as Timestamp).toDate()
                              : null,
                          "assignedUserId": assignedUserId,
                          "title": doc['title'] ?? "No Title",
                        };
                      }
                      return null;
                    })
                    .where((shift) => shift != null)
                    .toList()
                    .cast<Map<String, dynamic>>();

                if (shifts.isEmpty) {
                  return const Center(
                      child:
                          Text('No shifts available for the selected month.'));
                }

                return ListView.builder(
                  itemCount: shifts.length,
                  itemBuilder: (context, index) {
                    final shift = shifts[index];
                    return GestureDetector(
                      onTap: () => _onShiftTapped(shift),
                      child: SmallShiftCardWidget(
                        shift: shift,
                        currentUserId: currentUser!.uid,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
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
}
