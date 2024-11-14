// contacts_screen.dart
import 'package:flutter/material.dart';
import 'package:mobile_app_group5/screens/chat_screen.dart';
import 'package:mobile_app_group5/widgets/bottom_nav_bar.dart';
import 'package:mobile_app_group5/screens/channels.dart';
import 'package:mobile_app_group5/screens/calendar_screen.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ContactsScreenState();
  }
}

class _ContactsScreenState extends State<ContactsScreen> {
  int _currentIndex = 0;
  List<String> contacts = ['User 1', 'User 2', 'User 3', 'User 4'];

  void _onNavBarTap(int index) {
    setState(() {
      _currentIndex = index;
    });

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

  void navigateToChat(String user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(userName: user),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Contacts')),
      body: ListView.builder(
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(
              contacts[index],
              style: TextStyle(fontSize: 25),
            ),
            onTap: () => navigateToChat(contacts[index]),
          );
        },
      ),
      bottomNavigationBar: BottomNavBar(
        onTap: _onNavBarTap,
        currentIndex: _currentIndex,
      ),
    );
  }
}