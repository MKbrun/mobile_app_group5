import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_app_group5/widgets/date_picker_widget.dart';
import 'package:mobile_app_group5/widgets/shift_card_widget.dart';
import 'package:mobile_app_group5/widgets/shift_list_widget.dart';
import 'package:mobile_app_group5/widgets/add_shift_dialog.dart';
import 'package:mobile_app_group5/widgets/swap_approval_dialog.dart';
import 'package:mobile_app_group5/widgets/swap_shift_dialog.dart';
import 'package:mobile_app_group5/themes/app_theme.dart';
import 'package:collection/collection.dart';

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

    // Get all shifts that are assigned to the current user
    List<Map<String, dynamic>> userShifts = shifts.where((shift) {
      return shift['assignedUserId'] == currentUser?.uid;
    }).toList();

    // Check if the user has shifts available for swapping
    if (userShifts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You have no shifts available for swapping')),
      );
      return;
    }

    // Show dialog for selecting the shift to swap
    Map<String, dynamic>? swapShift = await showDialog(
      context: context,
      builder: (context) => SwapShiftDialog(userShifts: userShifts),
    );

    // Proceed if a shift is selected
    if (swapShift != null) {
      try {
        // Extract IDs
        String offeredShiftId =
            swapShift['id']; // The shift the user is offering
        String requestedShiftId =
            selectedShift['id']; // The shift the user wants
        String? requestedById = currentUser?.uid;
        String? targetUserId = selectedShift['assignedUserId'];

        // Log the values for debugging purposes
        print('Initiating swap request:');
        print('Offered Shift ID: $offeredShiftId');
        print('Requested Shift ID: $requestedShiftId');
        print('Requested By User ID: $requestedById');
        print('Target User ID: $targetUserId');

        // Check if all values are valid
        if (offeredShiftId.isEmpty || requestedShiftId.isEmpty) {
          throw Exception(
              "Shift IDs are missing. Cannot proceed with the swap request.");
        }
        if (requestedById == null || targetUserId == null) {
          throw Exception(
              "User IDs are missing. Cannot proceed with the swap request.");
        }

        // Update the requested shift document in Firestore
        await firestore.collection('shifts').doc(requestedShiftId).update({
          "tradeRequestedBy": requestedById,
          "tradeTargetUserId": targetUserId,
          "isTradeApproved": false,
          "tradeShifts": [
            offeredShiftId,
            requestedShiftId
          ], // Store both shift IDs in an array
        });

        // Fetch the updated document to verify
        DocumentSnapshot<Map<String, dynamic>> updatedShiftSnapshot =
            await firestore.collection('shifts').doc(requestedShiftId).get();

        if (updatedShiftSnapshot.exists) {
          Map<String, dynamic>? updatedData = updatedShiftSnapshot.data();
          print(
              'Updated document data after swap request initiation: $updatedData');

          // Verify if tradeShifts were properly saved
          if (updatedData == null ||
              updatedData['tradeShifts'] == null ||
              updatedData['tradeShifts'].contains("") ||
              updatedData['tradeShifts'].length != 2) {
            throw Exception(
                "tradeShifts were not updated properly in Firestore.");
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Swap request has been sent')),
            );
          }
        } else {
          throw Exception(
              "Failed to fetch the updated shift document after swap request.");
        }
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

    // Fetch the latest version of the selected shift document
    DocumentReference requestedShiftRef =
        firestore.collection('shifts').doc(selectedShift['id']);
    DocumentSnapshot<Object?> requestedShiftSnapshot =
        await requestedShiftRef.get();

    if (!requestedShiftSnapshot.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Error: Selected shift could not be found. Please try again.')),
      );
      return;
    }

    // Get the latest data from Firestore
    Map<String, dynamic>? selectedShiftData =
        requestedShiftSnapshot.data() as Map<String, dynamic>?;

    if (selectedShiftData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: No data found for the selected shift.')),
      );
      return;
    }

    // Extract the necessary fields
    String? requestedById = selectedShiftData['tradeRequestedBy'];
    String? targetUserId = selectedShiftData['assignedUserId'];
    List<dynamic>? tradeShifts = selectedShiftData['tradeShifts'];

    // Check if there is a pending trade request
    if (requestedById == null ||
        targetUserId == null ||
        tradeShifts == null ||
        tradeShifts.length != 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Error: Required field is missing or null. Cannot proceed with the swap.')),
      );
      return;
    }

    String offeredShiftId = tradeShifts[0];
    String requestedShiftId = tradeShifts[1];

    // Fetch the shift offered by the other user
    DocumentReference offeredShiftRef =
        firestore.collection('shifts').doc(offeredShiftId);
    DocumentSnapshot<Object?> offeredShiftSnapshot =
        await offeredShiftRef.get();

    if (!offeredShiftSnapshot.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Error: Offered shift could not be found. Please try again.')),
      );
      return;
    }

    // Get the username of the requesting user
    DocumentSnapshot userSnapshot =
        await firestore.collection('users').doc(requestedById).get();
    String requestedByUsername = userSnapshot.exists
        ? (userSnapshot['username'] ?? 'Unknown User')
        : 'Unknown User';

    // Extract details to show in the dialog
    String offeredShiftDetails = offeredShiftSnapshot.data() != null
        ? "Start: ${offeredShiftSnapshot['startTime'].toDate()}, End: ${offeredShiftSnapshot['endTime'].toDate()}"
        : "Unknown shift details";

    // Show the swap approval dialog to the user
    bool? approve = await showDialog<bool>(
      context: context,
      builder: (context) => SwapApprovalDialog(
        requestedByUsername: requestedByUsername,
        shiftDetails: offeredShiftDetails,
        onApprove: () {
          Navigator.of(context).pop(true);
        },
        onReject: () {
          Navigator.of(context).pop(false);
        },
      ),
    );

    // If approved, proceed with the swap
    if (approve == true) {
      try {
        WriteBatch batch = firestore.batch();

        // Update the offered shift (assign to the target user)
        batch.update(offeredShiftRef, {
          "assignedUserId": targetUserId,
          "tradeRequestedBy": "",
          "tradeTargetUserId": "",
          "isTradeApproved": true,
          "tradeShifts": FieldValue.delete(), // Clear trade information
        });

        // Update the requested shift (assign to the requesting user)
        batch.update(requestedShiftRef, {
          "assignedUserId": requestedById,
          "tradeRequestedBy": "",
          "tradeTargetUserId": "",
          "isTradeApproved": true,
          "tradeShifts": FieldValue.delete(), // Clear trade information
        });

        // Commit the batch to ensure both shifts are swapped simultaneously
        await batch.commit();

        print("Successfully swapped shifts:");
        print("Shift ${offeredShiftRef.id} assigned to user: $targetUserId");
        print("Shift ${requestedShiftRef.id} assigned to user: $requestedById");

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Shift swap approved successfully')),
        );

        // Refresh the shifts list to reflect the change in the UI immediately
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
        await requestedShiftRef.update({
          "tradeRequestedBy": "",
          "tradeTargetUserId": "",
          "isTradeApproved": false,
          "tradeShifts": FieldValue.delete(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Shift swap request rejected')),
        );

        // Refresh the shifts list to reflect the change in the UI immediately
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
