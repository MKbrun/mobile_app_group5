import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import 'package:mobile_app_group5/themes/app_theme.dart';

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
      final messages = snapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;

            if (data['type'] == 'text') {
              return types.TextMessage(
                author: types.User(id: data['senderId']),
                createdAt:
                    (data['timestamp'] as Timestamp).millisecondsSinceEpoch,
                id: doc.id,
                text: data['text'],
              );
            } else if (data['type'] == 'image') {
              return types.ImageMessage(
                author: types.User(id: data['senderId']),
                createdAt:
                    (data['timestamp'] as Timestamp).millisecondsSinceEpoch,
                id: doc.id,
                name: data['name'],
                size: data['size'],
                uri: data['uri'],
              );
            } else {
              return null;
            }
          })
          .whereType<types.Message>()
          .toList();

      setState(() {
        _messages.clear();
        _messages.addAll(messages.reversed);
      });
    });
  }

  Widget _buildImageMessage(types.ImageMessage message,
      {required int messageWidth}) {
    final placeholderHeight = messageWidth.toDouble() * 1.5;

    return CachedNetworkImage(
      imageUrl: message.uri,
      width: messageWidth.toDouble(),
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        width: messageWidth.toDouble(),
        height: placeholderHeight * 0.4,
        color: Colors.grey[300],
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      fadeInDuration: const Duration(milliseconds: 300),
      errorWidget: (context, url, error) => Container(
        width: messageWidth.toDouble(),
        height: placeholderHeight * 0.4,
        color: Colors.grey[300],
        child: Icon(Icons.broken_image, size: 40),
      ),
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

    await FirebaseFirestore.instance
        .collection('private_chat_messages')
        .add(message);

    await FirebaseFirestore.instance
        .collection('private_chats')
        .doc(chatId)
        .set({
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

      final placeholderMessage = types.ImageMessage(
        author: types.User(id: _currentUser.uid),
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: DateTime.now().toString(),
        name: image.name,
        size: fileSize,
        uri: '',
        status: types.Status.sending,
      );

      setState(() {
        _messages.insert(0, placeholderMessage);
      });

      try {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('private_message_images')
            .child('$chatId-${DateTime.now().millisecondsSinceEpoch}.jpg');
        await storageRef.putFile(file);

        final imageUrl = await storageRef.getDownloadURL();

        final message = {
          'chatId': chatId,
          'senderId': _currentUser.uid,
          'type': 'image',
          'name': image.name,
          'size': fileSize,
          'uri': imageUrl,
          'timestamp': FieldValue.serverTimestamp(),
        };

        final docRef = await FirebaseFirestore.instance
            .collection('private_chat_messages')
            .add(message);

        setState(() {
          final index =
              _messages.indexWhere((msg) => msg.id == placeholderMessage.id);
          if (index != -1) {
            _messages[index] = types.ImageMessage(
              author: types.User(id: _currentUser.uid),
              createdAt: DateTime.now().millisecondsSinceEpoch,
              id: docRef.id,
              name: image.name,
              size: fileSize,
              uri: imageUrl,
            );
          }
        });
      } catch (error) {
        print("Error uploading image: $error");
        setState(() {
          _messages.removeWhere((msg) => msg.id == placeholderMessage.id);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat with ${widget.userName}'),
                     backgroundColor: AppTheme.blueColor,),
      
      body: Column(
        children: [
          Expanded(
            child: Chat(
              theme: DefaultChatTheme(
                //Background
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,

                // Outgoing Message 
                primaryColor: Theme.of(context).colorScheme.secondary, // Bubble Color
                sentMessageBodyTextStyle: TextStyle(
                  color: AppTheme.White, // Text Color
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),

                // Incoming Message 
                secondaryColor: Theme.of(context).colorScheme.secondary, // Bubble Color
                receivedMessageBodyTextStyle: TextStyle(
                  color: AppTheme.White, // Text Color
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),

                // Input Field 
                inputBackgroundColor: Theme.of(context).colorScheme.surface,
                inputTextColor: Theme.of(context).colorScheme.onSurface,
                inputBorderRadius: BorderRadius.circular(16),
                inputTextStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 16,
                ),
              ),
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
