import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_app_group5/widgets/date_picker_widget.dart';
import 'package:mobile_app_group5/widgets/shift_list_widget.dart';
import 'package:mobile_app_group5/widgets/add_shift_dialog.dart';
import 'package:mobile_app_group5/widgets/swap_approval_dialog.dart';
import 'package:mobile_app_group5/widgets/swap_shift_dialog.dart';
import 'package:mobile_app_group5/themes/app_theme.dart';

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

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
    _checkAdminStatus();
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

  void _addShift(Map<String, dynamic> newShift) async {
    try {
      DateTime startDateTime = newShift["startTime"].toDate();
      DateTime endDateTime = newShift["endTime"].toDate();
      String assignedUserId = newShift["assignedUserId"];

      // If the shift is assigned to a user, check for overlap for that user.
      if (assignedUserId.isNotEmpty) {
        // Fetch existing shifts for that day for the specific user
        QuerySnapshot existingShiftsSnapshot = await firestore
            .collection('shifts')
            .where('assignedUserId', isEqualTo: assignedUserId)
            .where('date', isEqualTo: Timestamp.fromDate(_selectedDate))
            .get();

        bool overlap = existingShiftsSnapshot.docs.any((shiftDoc) {
          DateTime existingStart =
              (shiftDoc['startTime'] as Timestamp).toDate();
          DateTime existingEnd = (shiftDoc['endTime'] as Timestamp).toDate();

          // Check if the new shift overlaps with any of the existing shifts assigned to this user
          return (startDateTime.isBefore(existingEnd) &&
              endDateTime.isAfter(existingStart));
        });

        if (overlap) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Error: Shift times overlap with an existing shift assigned to this user')),
          );
          return;
        }
      }

      // Proceed with adding the shift if no overlap or no user is assigned
      DocumentReference docRef = await firestore.collection('shifts').add({
        "date": Timestamp.fromDate(_selectedDate),
        "startTime": Timestamp.fromDate(startDateTime),
        "endTime": Timestamp.fromDate(endDateTime),
        "assignedUserId": assignedUserId,
        "createdBy": currentUser?.uid,
        "isTradeApproved": false,
        "tradeRequestedBy": "",
        "tradeTargetUserId": "",
        "title": newShift["title"],
      });

      await firestore.collection('shifts').doc(docRef.id).update({
        "shiftId": docRef.id,
      });
    } catch (e) {
      print('Error adding shift: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding shift: $e')),
      );
    }
  }

  void _takeShift(String shiftId) async {
    try {
      await firestore.collection('shifts').doc(shiftId).update({
        "assignedUserId": currentUser?.uid,
      });
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
        title: const Text(
          'Shift Management',
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
          DatePickerWidget(
            selectedDate: _selectedDate,
            onDatePicked: (date) {
              setState(() {
                _selectedDate = date;
              });
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.blueColor,
                ),
                child: const Text("Add New Shift"),
              ),
            ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: firestore
                  .collection('shifts')
                  .where('date',
                      isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime(
                          _selectedDate.year,
                          _selectedDate.month,
                          _selectedDate.day)))
                  .where('date',
                      isLessThan: Timestamp.fromDate(DateTime(
                          _selectedDate.year,
                          _selectedDate.month,
                          _selectedDate.day + 1)))
                  .snapshots(),
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
                          Text('No shifts available for the selected date.'));
                }

                List<Map<String, dynamic>> fetchedShifts =
                    snapshot.data!.docs.map((doc) {
                  String? assignedUserId = doc['assignedUserId'] as String?;
                  String assignedUsername =
                      assignedUserId != null && assignedUserId.isNotEmpty
                          ? "Fetching..."
                          : "Unassigned";

                  return {
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
                    "available":
                        assignedUserId == null || assignedUserId.isEmpty,
                    "title": doc['title'] ?? "No Title",
                    "tradeRequestedBy": doc['tradeRequestedBy'] ?? '',
                    "tradeTargetUserId": doc['tradeTargetUserId'] ?? '',
                    "isTradeApproved": doc['isTradeApproved'] ?? false,
                  };
                }).toList();

                return ShiftListWidget(
                  shifts: fetchedShifts,
                  onTakeShift: (index) {
                    if (fetchedShifts[index]["available"]) {
                      _takeShift(fetchedShifts[index]["id"]);
                    }
                  },
                  onSwapShift: (index) {
                    _swapShift(index, fetchedShifts);
                  },
                  onApproveSwap: (index) {
                    _approveOrRejectSwap(index, fetchedShifts);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _swapShift(int index, List<Map<String, dynamic>> shifts) async {
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

  void _approveOrRejectSwap(
      int index, List<Map<String, dynamic>> shifts) async {
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
      } catch (e) {
        print('Error rejecting swap: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error rejecting swap: $e')),
        );
      }
    }
  }
}
