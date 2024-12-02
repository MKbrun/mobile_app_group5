import 'package:flutter/material.dart';

class SwapApprovalDialog extends StatelessWidget {
  final String requestedByUsername;
  final String shiftDetails;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const SwapApprovalDialog({
    Key? key,
    required this.requestedByUsername,
    required this.shiftDetails,
    required this.onApprove,
    required this.onReject,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Swap Request"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("$requestedByUsername has requested to swap shifts."),
          SizedBox(height: 8),
          Text("Shift Details: $shiftDetails"),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onReject,
          child: const Text("Reject"),
        ),
        ElevatedButton(
          onPressed: onApprove,
          child: const Text("Approve"),
        ),
      ],
    );
  }
}
