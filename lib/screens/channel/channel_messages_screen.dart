import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChannelMessagesScreen extends StatefulWidget {
  final String channelId;
  final String channelName;

  const ChannelMessagesScreen({Key? key, required this.channelId, required this.channelName}) : super(key: key);

  @override
  _ChannelMessagesScreenState createState() => _ChannelMessagesScreenState();
}

class _ChannelMessagesScreenState extends State<ChannelMessagesScreen> {
  final TextEditingController _messageController = TextEditingController();

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    await FirebaseFirestore.instance
        .collection('channels')
        .doc(widget.channelId)
        .collection('messages')
        .add({
      'content': _messageController.text.trim(),
      'createdBy': 'current_user_id', 
      'createdAt': Timestamp.now(),
    });

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.channelName),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('channels')
                  .doc(widget.channelId)
                  .collection('messages')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return ListTile(
                      title: Text(message['content']),
                      subtitle: Text('By: ${message['createdBy']}'),
                      trailing: Text(message['createdAt'].toDate().toString()),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      labelText: 'Type a message',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}