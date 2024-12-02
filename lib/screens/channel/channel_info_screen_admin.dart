import 'package:flutter/material.dart';
import 'package:mobile_app_group5/backend/channel_backend/channel_logic.dart';
import 'package:mobile_app_group5/themes/app_theme.dart';

class ChannelInfoScreenAdmin extends StatefulWidget {
  final String channelId;
  final String channelName;
  final List<String> members;
  final ValueChanged<String> onUpdateChannelName;
  final ValueChanged<List<String>> onUpdateMembersList;
  final VoidCallback onDeleteChannel;

  const ChannelInfoScreenAdmin({
    super.key,
    required this.channelId,
    required this.channelName,
    required this.members,
    required this.onUpdateChannelName,
    required this.onUpdateMembersList,
    required this.onDeleteChannel,
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

  Future<void> deleteChannel() async {
  final confirmation = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Delete Channel'),
      content: const Text('Are you sure you want to delete this channel?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );

  if (confirmation == true) {
    try {
      await channelLogic.deleteChannel(widget.channelId);

      widget.onDeleteChannel(); // Notify parent about deletion

      Navigator.of(context).pop(); // Exit info screen
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Channel deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete channel: $e')),
      );
    }
  }
}

 @override
Widget build(BuildContext context) {
  final sortedUsers = getSortedUsers();

  return Scaffold(
    appBar: AppBar(
      title: Text(
        'Edit: ${widget.channelName}',
        style: const TextStyle(
          color: Colors.white, // White text for contrast
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      backgroundColor: AppTheme.blueColor,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.save, color: Colors.white),
          onPressed: saveUpdatedDetails,
        ),
      ],
    ),
    body: Column(
      children: [
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: TextField(
            controller: _channelNameController,
            decoration: InputDecoration(
              labelText: 'Channel Name',
              labelStyle: const TextStyle(color: AppTheme.blueColor),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: AppTheme.blueColor),
                borderRadius: BorderRadius.circular(10),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: AppTheme.blueColor),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ElevatedButton(
            onPressed: deleteChannel,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.withOpacity(0.8),
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete Channel'),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: sortedUsers.length,
            itemBuilder: (context, index) {
              final user = sortedUsers[index];
              if (user.containsKey('separator')) {
                return const Divider(
                  thickness: 2,
                  color: AppTheme.blueColor,
                );
              }
              final isMember = members.contains(user['email']);
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.blueColor.withOpacity(0.9), // Darker background
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(user['image_url']),
                  ),
                  title: Text(
                    user['email'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    user['username'],
                    style: const TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      isMember ? Icons.remove_circle : Icons.add_circle,
                      color: isMember ? Colors.red.withOpacity(0.8) : AppTheme.lightGreenColor,
                    ),
                    onPressed: () => isMember
                        ? removeMember(user['email'])
                        : addMember(user['email']),
                  ),
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
