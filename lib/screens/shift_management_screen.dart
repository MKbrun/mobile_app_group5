// Updated ShiftManagementScreen to Integrate Firestore Backend for Shifts

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_app_group5/widgets/date_picker_widget.dart';
import 'package:mobile_app_group5/widgets/shift_list_widget.dart';
import 'package:mobile_app_group5/widgets/add_shift_dialog.dart';

class ShiftManagementScreen extends StatefulWidget {
  final DateTime selectedDate;

  const ShiftManagementScreen({super.key, required this.selectedDate});

  @override
  _ShiftManagementScreenState createState() => _ShiftManagementScreenState();
}

class _ShiftManagementScreenState extends State<ShiftManagementScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final User? currentUser = FirebaseAuth.instance.currentUser;

  late DateTime _selectedDate;
  bool _isAdmin = false;
  List<Map<String, dynamic>> shifts = [];

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
    _checkAdminStatus();
    _fetchShifts();
  }

  void _checkAdminStatus() async {
    DocumentSnapshot userSnapshot =
        await firestore.collection('users').doc(currentUser?.uid).get();
    if (userSnapshot.exists) {
      setState(() {
        _isAdmin = userSnapshot['role'] == 'admin';
      });
    }
  }

  void _fetchShifts() async {
    try {
      DateTime startOfDay =
          DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
      DateTime endOfDay = startOfDay.add(const Duration(days: 1));

      QuerySnapshot usersSnapshot = await firestore.collection('users').get();
      Map<String, String> userIdToUsername = {};

      for (var userDoc in usersSnapshot.docs) {
        Map<String, dynamic>? userData =
            userDoc.data() as Map<String, dynamic>?;

        if (userData != null && userData.containsKey('username')) {
          userIdToUsername[userDoc.id] = userData['username'];
        } else {
          // Handle users without a username field
          userIdToUsername[userDoc.id] = "Unknown";
        }
      }

      QuerySnapshot shiftsSnapshot = await firestore
          .collection('shifts')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThan: Timestamp.fromDate(endOfDay))
          .get();

      List<Map<String, dynamic>> fetchedShifts = [];

      for (var doc in shiftsSnapshot.docs) {
        String? assignedUserId = doc['assignedUserId'] as String?;

        String assignedUsername =
            "Unassigned"; // Default value if no user is assigned

        // If there's an assigned user, use the user map to get their username
        if (assignedUserId != null && assignedUserId.isNotEmpty) {
          assignedUsername = userIdToUsername[assignedUserId] ?? "Unknown";
        }

        // Add the shift data to the list
        fetchedShifts.add({
          "id": doc.id,
          "date": (doc['date'] != null)
              ? (doc['date'] as Timestamp).toDate()
              : null,
          "startTime": (doc['startTime'] != null)
              ? (doc['startTime'] as Timestamp).toDate()
              : null,
          "endTime": (doc['endTime'] != null)
              ? (doc['endTime'] as Timestamp).toDate()
              : null,
          "assignedUserId": assignedUserId ?? '',
          "assignedUsername":
              assignedUsername, // Add the username to shift data
          "createdBy": doc['createdBy'] ?? '',
          "available": assignedUserId == null || assignedUserId.isEmpty,
          "title": doc['title'] ?? "No Title",
        });
      }

      setState(() {
        shifts = fetchedShifts;
      });
    } catch (e) {
      print('Error fetching shifts: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching shifts: $e')),
      );
    }
  }

  void _addShift(Map<String, dynamic> newShift) async {
    try {
      DateTime shiftDate =
          _selectedDate; // Use the selected date from DatePicker
      DocumentReference docRef = await firestore.collection('shifts').add({
        "date": Timestamp.fromDate(DateTime(
          shiftDate.year,
          shiftDate.month,
          shiftDate.day,
        )), // Set the date field to the selected date without time
        "startTime": newShift["startTime"],
        "endTime": newShift["endTime"],
        "assignedUserId": newShift["assignedUserId"],
        "createdBy": currentUser?.uid,
        "isTradeApproved": false,
        "tradeRequestedBy": "",
        "tradeTargetUserId": "",
        "title": newShift["title"],
      });

      await firestore.collection('shifts').doc(docRef.id).update({
        "shiftId": docRef.id,
      });
      _fetchShifts(); // Refresh the shifts to show the newly added shift
    } catch (e) {
      print('Error adding shift: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding shift: $e')),
      );
    }
  }

  void _takeShift(int index) async {
    String shiftId = shifts[index]["id"];
    try {
      await firestore.collection('shifts').doc(shiftId).update({
        "assignedUserId": currentUser?.uid,
      });
      _fetchShifts();
    } catch (e) {
      print('Error taking shift: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error taking shift: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Shift Management"),
      ),
      body: Column(
        children: [
          DatePickerWidget(
            selectedDate: _selectedDate,
            onDatePicked: (date) {
              setState(() {
                _selectedDate = date;
              });
              _fetchShifts();
            },
          ),
          if (_isAdmin)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () async {
                  Map<String, dynamic>? newShift = await showDialog(
                    context: context,
                    builder: (context) => AddShiftDialog(),
                  );
                  if (newShift != null) {
                    _addShift(newShift);
                  }
                },
                child: const Text("Add New Shift"),
              ),
            ),
          Expanded(
            child: ShiftListWidget(
              shifts: shifts,
              onTakeShift: (index) {
                if (shifts[index]["available"]) {
                  _takeShift(index);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
