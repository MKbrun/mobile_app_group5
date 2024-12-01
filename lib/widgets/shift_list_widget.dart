import 'package:flutter/material.dart';
import 'shift_card_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ShiftListWidget extends StatelessWidget {
  final List<Map<String, dynamic>> shifts;
  final Function(int) onTakeShift;

  // Fetch the current user's ID
  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

  ShiftListWidget({
    Key? key,
    required this.shifts,
    required this.onTakeShift,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: shifts.length,
      itemBuilder: (context, index) {
        return ShiftCardWidget(
          shift: shifts[index],
          onTakeShift: () => onTakeShift(index),
          currentUserId:
              currentUserId, // Pass the required currentUserId argument here
        );
      },
    );
  }
}
