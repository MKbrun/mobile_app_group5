import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_app_group5/widgets/date_picker_widget.dart';
import 'package:mobile_app_group5/widgets/shift_list_widget.dart';
import 'package:mobile_app_group5/widgets/add_shift_dialog.dart';
import 'package:mobile_app_group5/widgets/swap_shift_dialog.dart';
import 'package:mobile_app_group5/widgets/swap_approval_dialog.dart';

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

        String assignedUsername = "Unassigned";

        if (assignedUserId != null && assignedUserId.isNotEmpty) {
          assignedUsername = userIdToUsername[assignedUserId] ?? "Unknown";
        }

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
          "assignedUsername": assignedUsername,
          "createdBy": doc['createdBy'] ?? '',
          "available": assignedUserId == null || assignedUserId.isEmpty,
          "title": doc['title'] ?? "No Title",
          "tradeRequestedBy": doc['tradeRequestedBy'] ?? '',
          "tradeTargetUserId": doc['tradeTargetUserId'] ?? '',
          "isTradeApproved": doc['isTradeApproved'] ?? false,
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
      DateTime shiftDate = _selectedDate;
      DocumentReference docRef = await firestore.collection('shifts').add({
        "date": Timestamp.fromDate(DateTime(
          shiftDate.year,
          shiftDate.month,
          shiftDate.day,
        )),
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

  void _swapShift(int index) async {
    Map<String, dynamic> selectedShift = shifts[index];

    List<Map<String, dynamic>> userShifts = shifts.where((shift) {
      return shift['assignedUserId'] == currentUser?.uid;
    }).toList();

    if (userShifts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You have no shifts available for swapping')),
      );
      return;
    }

    Map<String, dynamic>? swapShift = await showDialog(
      context: context,
      builder: (context) => SwapShiftDialog(userShifts: userShifts),
    );

    if (swapShift != null) {
      try {
        await firestore.collection('shifts').doc(selectedShift['id']).update({
          "tradeRequestedBy": currentUser?.uid,
          "tradeTargetUserId": selectedShift['assignedUserId'],
          "isTradeApproved": false,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Swap request has been sent')),
        );
      } catch (e) {
        print('Error initiating swap: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error initiating swap: $e')),
        );
      }
    }
  }

  void _approveOrRejectSwap(int index) async {
    Map<String, dynamic> selectedShift = shifts[index];

    bool? approve = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Swap Request"),
        content: const Text("Do you want to approve this shift swap?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text("Reject"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text("Approve"),
          ),
        ],
      ),
    );

    if (approve == true) {
      try {
        // Update both shifts
        String requestedById = selectedShift['tradeRequestedBy'];
        String targetUserId = selectedShift['assignedUserId'];

        // Swap assigned users
        await firestore.collection('shifts').doc(selectedShift['id']).update({
          "assignedUserId": requestedById,
          "tradeRequestedBy": "",
          "tradeTargetUserId": "",
          "isTradeApproved": true,
        });

        // Find the requesting user's shift and update it as well
        String requestedShiftId = shifts.firstWhere((shift) =>
            shift['assignedUserId'] == requestedById &&
            shift['tradeTargetUserId'] == targetUserId)['id'];
        await firestore.collection('shifts').doc(requestedShiftId).update({
          "assignedUserId": targetUserId,
          "tradeRequestedBy": "",
          "tradeTargetUserId": "",
          "isTradeApproved": true,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Shift swap approved successfully')),
        );

        // Refresh the shifts list
        _fetchShifts();
      } catch (e) {
        print('Error approving swap: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error approving swap: $e')),
        );
      }
    } else if (approve == false) {
      // Reject the swap request
      try {
        await firestore.collection('shifts').doc(selectedShift['id']).update({
          "tradeRequestedBy": "",
          "tradeTargetUserId": "",
          "isTradeApproved": false,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Shift swap request rejected')),
        );

        // Refresh the shifts list
        _fetchShifts();
      } catch (e) {
        print('Error rejecting swap: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error rejecting swap: $e')),
        );
      }
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
              onSwapShift: (index) {
                _swapShift(index);
              },
              onApproveSwap: (index) {
                _approveOrRejectSwap(index);
              },
            ),
          ),
        ],
      ),
    );
  }
}
