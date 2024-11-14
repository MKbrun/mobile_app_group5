// chat_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:mobile_app_group5/widgets/bottom_nav_bar.dart';
import 'package:mobile_app_group5/screens/channels.dart';
import 'package:mobile_app_group5/screens/calendar_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<types.Message> _messages = [];
  final _user = types.User(id: 'user-id', firstName: 'Demo User');
  int _currentIndex = 0; // Track current bottom nav index

  void _sendMessage() {
    if (_controller.text.isEmpty) return;

    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: _controller.text,
    );

    setState(() {
      _messages.insert(0, textMessage);
    });

    _controller.clear();
  }

  Future _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final imageMessage = types.ImageMessage(
        author: _user,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: image.name,
        size: File(image.path).lengthSync(),
        uri: image.path,
      );

      setState(() {
        _messages.insert(0, imageMessage);
      });
    }
  }

  void _onNavBarTap(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Handle screen navigation
    if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ChannelScreen()),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const CalendarScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: Column(
        children: [
          Expanded(
            child: Chat(
              messages: _messages,
              onSendPressed: (types.PartialText message) {
                _controller.text = message.text;
                _sendMessage();
              },
              user: _user,
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
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondary, // Use theme color
                            ),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: _sendMessage,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        onTap: _onNavBarTap,
        currentIndex: _currentIndex,
      ),
    );
  }
}
