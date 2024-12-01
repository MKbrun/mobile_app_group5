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
      QuerySnapshot snapshot = await firestore
          .collection('shifts')
          .where('date',
              isEqualTo: Timestamp.fromDate(DateTime(
                  _selectedDate.year, _selectedDate.month, _selectedDate.day)))
          .get();

      setState(() {
        shifts = snapshot.docs
            .map((doc) => {
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
                  "assignedUserId": doc['assignedUserId'],
                  "createdBy": doc['createdBy'],
                  "available": doc['assignedUserId'] == null ||
                      doc['assignedUserId'].isEmpty,
                  "title": doc['title'] ?? "No Title"
                })
            .toList();
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
      DocumentReference docRef = await firestore.collection('shifts').add({
        "date": newShift["date"],
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
      _fetchShifts();
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
