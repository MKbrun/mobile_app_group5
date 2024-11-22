import 'package:cloud_firestore/cloud_firestore.dart';

class Chat {
  final String id;
  final List<String> userIds;
  final String lastMessageSenderId;
  final String lastMessageText;
  final DateTime lastMessageTimestamp;

  Chat({
    required this.id,
    required this.userIds,
    required this.lastMessageSenderId,
    required this.lastMessageText,
    required this.lastMessageTimestamp,
  });

  factory Chat.fromFirestore(Map<String, dynamic> data, String id) {
    return Chat(
      id: id,
      userIds: List<String>.from(data['UserIds']),
      lastMessageSenderId: data['lastMessage']['senderId'],
      lastMessageText: data['lastMessage']['text'],
      lastMessageTimestamp: (data['lastMessage']['timestamp'] as Timestamp).toDate(),
    );
  }
}
