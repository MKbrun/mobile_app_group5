import 'package:flutter/material.dart';

class SwapApprovalDialog extends StatelessWidget {
  final String requestedByUsername;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const SwapApprovalDialog({
    Key? key,
    required this.requestedByUsername,
    required this.onApprove,
    required this.onReject,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Swap Request"),
      content: Text(
          "$requestedByUsername has requested to swap this shift with you."),
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
