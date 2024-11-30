import 'package:flutter/material.dart';
import 'package:mobile_app_group5/backend/channel_backend/channel_logic.dart';

class ChannelInfoScreen extends StatefulWidget {
  final String channelId;
  final String channelName;
  final List<String> members;
  final ValueChanged<String> onUpdateChannelName;
  final ValueChanged<List<String>> onUpdateMembersList; // New callback for members

  const ChannelInfoScreen({
    super.key,
    required this.channelId,
    required this.channelName,
    required this.members,
    required this.onUpdateChannelName,
    required this.onUpdateMembersList, // Pass the callback here
  });

  @override
  State<ChannelInfoScreen> createState() => _ChannelInfoScreenState();
}

class _ChannelInfoScreenState extends State<ChannelInfoScreen> {
  late TextEditingController _channelNameController;
  late TextEditingController _emailController;
  late List<String> members;
  final ChannelLogic channelLogic = ChannelLogic();

  @override
  void initState() {
    super.initState();
    _channelNameController = TextEditingController(text: widget.channelName);
    _emailController = TextEditingController();
    members = List<String>.from(widget.members);
  }

  @override
  void dispose() {
    _channelNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void saveUpdatedDetails() async {
    final updatedName = _channelNameController.text.trim();

    try {
      // Save updated channel name and members
      await channelLogic.updateChannel(
        channelId: widget.channelId,
        name: updatedName,
        members: members,
      );
      widget.onUpdateChannelName(updatedName); // Update the channel name in the parent screen
      widget.onUpdateMembersList(members); // Update the members list in the parent screen
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Channel updated successfully')),
      );
      Navigator.of(context).pop(); // Close the screen
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update channel')),
      );
    }
  }

  void addMember() async {
    final email = _emailController.text.trim();
    if (email.isNotEmpty && !members.contains(email)) {
      setState(() {
        members.add(email);
      });

      try {
        await channelLogic.updateChannel(
          channelId: widget.channelId,
          members: members,
        );
        widget.onUpdateMembersList(members); // Notify parent screen about member update
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$email added successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add member')),
        );
      }
      _emailController.clear();
    }
  }

  void removeMember(String email) async {
    if (members.contains(email)) {
      setState(() {
        members.remove(email);
      });

      try {
        await channelLogic.updateChannel(
          channelId: widget.channelId,
          members: members,
        );
        widget.onUpdateMembersList(members); // Notify parent screen about member update
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

  @override
  Widget build(BuildContext context) {
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _channelNameController,
              decoration: const InputDecoration(labelText: 'Channel Name'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Add Member (Email)'),
              onSubmitted: (_) => addMember(),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: members
                    .map((email) => ListTile(
                          title: Text(email),
                          trailing: IconButton(
                            icon: const Icon(Icons.remove_circle),
                            onPressed: () => removeMember(email),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
