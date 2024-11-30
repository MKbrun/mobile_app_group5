import 'package:flutter/material.dart';
import 'package:mobile_app_group5/backend/channel_backend/channel_logic.dart';
import 'package:mobile_app_group5/themes/app_theme.dart';

class ChannelInfoScreen extends StatefulWidget {
  final String channelId;
  final String channelName;
  final List<String> members;

  const ChannelInfoScreen({
    super.key,
    required this.channelId,
    required this.channelName,
    required this.members,
  });

  @override
  State<ChannelInfoScreen> createState() => _ChannelInfoScreenState();
}

class _ChannelInfoScreenState extends State<ChannelInfoScreen> {
  final ChannelLogic channelLogic = ChannelLogic();
  List<Map<String, dynamic>> users = [];

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      final fetchedUsers = await channelLogic.fetchAllUsers();
      setState(() {
        users = fetchedUsers.where((user) => widget.members.contains(user['email'])).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch members')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.channelName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.blueColor,
        elevation: 0,
      ),
      body: users.isEmpty
          ? const Center(
              child: Text(
                'No members found',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.blueColor,
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: AppTheme.blueColor.withOpacity(0.8), // Main theme color
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(user['image_url']),
                      ),
                      title: Text(
                        user['email'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      subtitle: Text(
                        user['username'],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
