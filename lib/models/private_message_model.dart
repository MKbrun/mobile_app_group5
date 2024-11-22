import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String chatId;
  final String senderId;
  final List<String> readBy;
  final String text;
  final DateTime timestamp;

  Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.readBy,
    required this.text,
    required this.timestamp,
  });

  factory Message.fromFirestore(Map<String, dynamic> data, String id) {
    return Message(
      id: id,
      chatId: data['chatId'],
      senderId: data['senderId'],
      readBy: List<String>.from(data['readBy']),
      text: data['text'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }
}
