import 'package:flutter/material.dart';
import 'package:mobile_app_group5/backend/channel_backend/channel_logic.dart';

class ChannelInfoScreenAdmin extends StatefulWidget {
  final String channelId;
  final String channelName;
  final List<String> members;
  final ValueChanged<String> onUpdateChannelName;
  final ValueChanged<List<String>> onUpdateMembersList;

  const ChannelInfoScreenAdmin({
    super.key,
    required this.channelId,
    required this.channelName,
    required this.members,
    required this.onUpdateChannelName,
    required this.onUpdateMembersList,
  });

  @override
  State<ChannelInfoScreenAdmin> createState() => _ChannelInfoScreenAdminState();
}

class _ChannelInfoScreenAdminState extends State<ChannelInfoScreenAdmin> {
  late TextEditingController _channelNameController;
  late List<String> members;
  List<Map<String, dynamic>> users = [];
  final ChannelLogic channelLogic = ChannelLogic();

  @override
  void initState() {
    super.initState();
    _channelNameController = TextEditingController(text: widget.channelName);
    members = List<String>.from(widget.members);
    fetchUsers(); // Fetch users from backend
  }

  @override
  void dispose() {
    _channelNameController.dispose();
    super.dispose();
  }

  Future<void> fetchUsers() async {
  try {
    final fetchedUsers = await channelLogic.fetchAllUsers();
    setState(() {
      users = fetchedUsers.where((user) => user['id'] != 'adminList').toList();
    });
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch users')),
      );
    }
  }
}

  Future<void> saveUpdatedDetails() async {
    final updatedName = _channelNameController.text.trim();

    try {
      await channelLogic.updateChannel(
        channelId: widget.channelId,
        name: updatedName,
        members: members,
      );
      widget.onUpdateChannelName(updatedName);
      widget.onUpdateMembersList(members);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Channel updated successfully')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update channel')),
      );
    }
  }

  Future<void> addMember(String email) async {
    if (!members.contains(email)) {
      setState(() {
        members.add(email);
      });

      try {
        await channelLogic.updateChannel(
          channelId: widget.channelId,
          members: members,
        );
        widget.onUpdateMembersList(members);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$email added successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add member')),
        );
      }
    }
  }

  Future<void> removeMember(String email) async {
    if (members.contains(email)) {
      setState(() {
        members.remove(email);
      });

      try {
        await channelLogic.updateChannel(
          channelId: widget.channelId,
          members: members,
        );
        widget.onUpdateMembersList(members);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$email removed successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to remove member')),
        );
      }
    }
  }

  List<Map<String, dynamic>> getSortedUsers() {
    // Group and sort users: members at the top, others below
    final channelMembers = users.where((user) => members.contains(user['email'])).toList();
    final nonMembers = users.where((user) => !members.contains(user['email'])).toList();
    return [...channelMembers, {'separator': true}, ...nonMembers];
  }

  @override
  Widget build(BuildContext context) {
    final sortedUsers = getSortedUsers();

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit: ${widget.channelName}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: saveUpdatedDetails,
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          TextField(
            controller: _channelNameController,
            decoration: const InputDecoration(labelText: 'Channel Name'),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: sortedUsers.length,
              itemBuilder: (context, index) {
                final user = sortedUsers[index];
                if (user.containsKey('separator')) {
                  return const Divider(thickness: 2);
                }
                final isMember = members.contains(user['email']);
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(user['image_url']),
                  ),
                  title: Text(user['email']),
                  subtitle: Text(user['username']),
                  trailing: IconButton(
                    icon: Icon(isMember ? Icons.remove_circle : Icons.add_circle),
                    onPressed: () => isMember
                        ? removeMember(user['email'])
                        : addMember(user['email']),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
