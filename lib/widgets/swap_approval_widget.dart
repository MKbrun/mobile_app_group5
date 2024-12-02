import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SwapApprovalScreen extends StatefulWidget {
  const SwapApprovalScreen({Key? key}) : super(key: key);

  @override
  _SwapApprovalScreenState createState() => _SwapApprovalScreenState();
}

class _SwapApprovalScreenState extends State<SwapApprovalScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final User? currentUser = FirebaseAuth.instance.currentUser;
  List<Map<String, dynamic>> pendingRequests = [];

  @override
  void initState() {
    super.initState();
    _fetchPendingRequests();
  }

  void _fetchPendingRequests() async {
    if (currentUser == null) return;

    try {
      QuerySnapshot snapshot = await firestore
          .collection('shifts')
          .where('tradeTargetUserId', isEqualTo: currentUser!.uid)
          .where('isTradeApproved', isEqualTo: false)
          .get();

      List<Map<String, dynamic>> requests = snapshot.docs.map((doc) {
        return {
          "id": doc.id,
          "tradeRequestedBy": doc['tradeRequestedBy'],
          "startTime": (doc['startTime'] as Timestamp).toDate(),
          "endTime": (doc['endTime'] as Timestamp).toDate(),
        };
      }).toList();

      setState(() {
        pendingRequests = requests;
      });
    } catch (e) {
      print('Error fetching pending requests: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching pending requests: $e')),
      );
    }
  }

  void _approveSwap(String shiftId) async {
    try {
      await firestore.collection('shifts').doc(shiftId).update({
        "isTradeApproved": true,
        // Swap the assigned user with the requester
        "assignedUserId": currentUser?.uid,
      });

      // Find the requester's shift and swap assigned user
      DocumentSnapshot shiftSnapshot =
          await firestore.collection('shifts').doc(shiftId).get();
      String tradeRequestedBy = shiftSnapshot['tradeRequestedBy'];
      await firestore
          .collection('shifts')
          .where('assignedUserId', isEqualTo: tradeRequestedBy)
          .get()
          .then((snapshot) {
        snapshot.docs.forEach((doc) async {
          await doc.reference.update({
            "assignedUserId": currentUser?.uid,
          });
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Shift swap approved')),
      );
      _fetchPendingRequests(); // Refresh the pending requests
    } catch (e) {
      print('Error approving swap: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error approving swap: $e')),
      );
    }
  }

  void _rejectSwap(String shiftId) async {
    try {
      await firestore.collection('shifts').doc(shiftId).update({
        "tradeRequestedBy": "",
        "tradeTargetUserId": "",
        "isTradeApproved": false,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Shift swap rejected')),
      );
      _fetchPendingRequests(); // Refresh the pending requests
    } catch (e) {
      print('Error rejecting swap: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error rejecting swap: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Swap Requests'),
      ),
      body: ListView.builder(
        itemCount: pendingRequests.length,
        itemBuilder: (context, index) {
          final request = pendingRequests[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              title: Text(
                "Requested by: ${request['tradeRequestedBy']}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                "Shift: ${request['startTime'].hour}:${request['startTime'].minute.toString().padLeft(2, '0')} - ${request['endTime'].hour}:${request['endTime'].minute.toString().padLeft(2, '0')}",
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.check, color: Colors.green),
                    onPressed: () => _approveSwap(request['id']),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.red),
                    onPressed: () => _rejectSwap(request['id']),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
