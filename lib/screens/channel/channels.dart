import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_app_group5/backend/channel_backend/channel_logic.dart';
import 'channel_info_screen_admin.dart';

class ChannelScreen extends StatefulWidget {
  const ChannelScreen({super.key});

  @override
  State<ChannelScreen> createState() => _ChannelScreenState();
}

class _ChannelScreenState extends State<ChannelScreen> {
  final ChannelLogic channelLogic = ChannelLogic();
  List<Map<String, dynamic>> channels = [];

  @override
  void initState() {
    super.initState();
    fetchChannels();
  }

  void fetchChannels() async {
    final channelCollection =
        FirebaseFirestore.instance.collection('channels');
    final snapshot = await channelCollection.get();

    setState(() {
      channels = snapshot.docs
          .map((doc) => {'id': doc.id, 'name': doc['name']})
          .toList();
    });
  }

  void navigateToChannelDetail(String channelName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChannelDetailScreen(channelName: channelName),
      ),
    );
  }

  void navigateToChannelInfo(String channel) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChannelInfoScreen(
          channelName: channel,
          onUpdateChannelName: (updatedName) {
            setState(() {
              final index = channels.indexWhere((c) => c['name'] == channel);
              if (index != -1) {
                channels[index]['name'] = updatedName;
              }
            });
          },
        ),
      ),
    );
  }

Future<void> _showCreateChannelDialog() async {
  final TextEditingController channelNameController =
      TextEditingController();
  final TextEditingController channelDescriptionController =
      TextEditingController();
  final TextEditingController memberController = TextEditingController();
  List<String> members = [];

  await showDialog(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setState) {
        return AlertDialog(
          title: const Text('Create Channel'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: channelNameController,
                  decoration: const InputDecoration(
                    labelText: 'Channel Name',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: channelDescriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: memberController,
                        decoration: const InputDecoration(
                          labelText: 'Add Member (User ID)',
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        final member = memberController.text.trim();
                        if (member.isNotEmpty) {
                          setState(() {
                            members.add(member);
                            memberController.clear();
                          });
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 5,
                  children: members
                      .map((member) => Chip(
                            label: Text(member),
                            onDeleted: () {
                              setState(() {
                                members.remove(member);
                              });
                            },
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final channelName = channelNameController.text.trim();
                final channelDescription =
                    channelDescriptionController.text.trim();

                if (channelName.isNotEmpty) {
                  // Close the dialog before async operation
                  Navigator.of(dialogContext).pop();

                  try {
                    await channelLogic.createChannel(
                      name: channelName,
                      description: channelDescription,
                      members: members,
                    );

                    if (mounted) {
                      fetchChannels(); // Refresh the list after creating the channel
                    }
                  } catch (e) {
                    print('Error creating channel: $e');
                  }
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Channels')),
      body: ListView.builder(
        itemCount: channels.length,
        itemBuilder: (context, index) {
          final channel = channels[index];
          return ListTile(
            title: Text(
              channel['name'],
              style: const TextStyle(fontSize: 20),
            ),
            onTap: () => navigateToChannelDetail(channel['name']),
            trailing: IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () => navigateToChannelInfo(channel['name']),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateChannelDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ChannelDetailScreen extends StatelessWidget {
  final String channelName;

  const ChannelDetailScreen({super.key, required this.channelName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(channelName)),
      body: Center(
        child: Text(
          'Welcome to $channelName!',
          style: const TextStyle(fontSize: 25),
        ),
      ),
    );
  }
}
