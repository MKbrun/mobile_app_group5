import 'package:flutter/material.dart';
import 'package:mobile_app_group5/backend/channel_backend/channel_logic.dart';

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
        title: Text(widget.channelName),
      ),
      body: users.isEmpty
          ? const Center(child: Text('No members found'))
          : ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(user['image_url']),
                  ),
                  title: Text(user['email']),
                  subtitle: Text(user['username']),
                );
              },
            ),
    );
  }
}
