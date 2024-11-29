import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ChatScreen extends StatefulWidget {
  final String userName;
  final String userId;

  const ChatScreen({super.key, required this.userName, required this.userId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final _currentUser = FirebaseAuth.instance.currentUser!;
  final List<types.Message> _messages = [];
  String chatId = '';

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  void _initializeChat() {

    chatId = _currentUser.uid.compareTo(widget.userId) < 0
        ? '${_currentUser.uid}_${widget.userId}'
        : '${widget.userId}_${_currentUser.uid}';

    
    FirebaseFirestore.instance
        .collection('private_chat_messages')
        .where('chatId', isEqualTo: chatId)
        .orderBy('timestamp')
        .snapshots()
        .listen((snapshot) {
      final messages = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;

        if (data['type'] == 'text') {
          return types.TextMessage(
            author: types.User(id: data['senderId']),
            createdAt: (data['timestamp'] as Timestamp).millisecondsSinceEpoch,
            id: doc.id,
            text: data['text'],
          );
        } else if (data['type'] == 'image') {
          return types.ImageMessage(
            author: types.User(id: data['senderId']),
            createdAt: (data['timestamp'] as Timestamp).millisecondsSinceEpoch,
            id: doc.id,
            name: data['name'],
            size: data['size'],
            uri: data['uri'],
          );
        } else {
          return null;
        }
      }).whereType<types.Message>().toList();

      setState(() {
        _messages.clear();
        _messages.addAll(messages.reversed);
      });
    });
  }

  Widget _buildImageMessage(types.ImageMessage message, {required int messageWidth}) {
    return Image.network(
      message.uri,
      width: messageWidth.toDouble(),
      errorBuilder: (context, error, stackTrace) {
        return Icon(Icons.broken_image, size: messageWidth.toDouble());
      },
    );
  }

  Future<void> _sendMessage(String text) async {
    if (text.isEmpty) return;

    final message = {
      'chatId': chatId,
      'senderId': _currentUser.uid,
      'text': text,
      'type': 'text',
      'timestamp': FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance.collection('private_chat_messages').add(message);

    
    await FirebaseFirestore.instance.collection('private_chats').doc(chatId).set({
      'UserIds': [_currentUser.uid, widget.userId],
      'lastMessage': {
        'senderId': _currentUser.uid,
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
      },
    }, SetOptions(merge: true));
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final file = File(image.path);
      final fileSize = file.lengthSync();

      final message = {
        'chatId': chatId,
        'senderId': _currentUser.uid,
        'type': 'image',
        'name': image.name,
        'size': fileSize,
        'uri': image.path,
        'timestamp': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('private_chat_messages').add(message);

      
      await FirebaseFirestore.instance.collection('private_chats').doc(chatId).set({
        'UserIds': [_currentUser.uid, widget.userId],
        'lastMessage': {
          'senderId': _currentUser.uid,
          'text': '[Image]',
          'timestamp': FieldValue.serverTimestamp(),
        },
      }, SetOptions(merge: true));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat with ${widget.userName}')),
      body: Column(
        children: [
          Expanded(
            child: Chat(
              messages: _messages,
              onSendPressed: (types.PartialText message) {
                _sendMessage(message.text);
              },
              user: types.User(id: _currentUser.uid),
              imageMessageBuilder: _buildImageMessage,
              customBottomWidget: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.photo),
                      onPressed: _pickImage,
                    ),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: 'Type a message',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () {
                        _sendMessage(_controller.text);
                        _controller.clear();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
