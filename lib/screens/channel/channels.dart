import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app_group5/backend/channel_backend/channel_logic.dart';
import 'package:mobile_app_group5/backend/user_logic.dart';
import 'package:mobile_app_group5/screens/channel/channel_info_screen_admin.dart';
import 'package:mobile_app_group5/screens/channel/channel_info_screen_user.dart';
import 'package:mobile_app_group5/screens/channel/channel_messages_screen.dart';
import 'package:mobile_app_group5/themes/app_theme.dart';

class ChannelScreen extends StatefulWidget {
  const ChannelScreen({super.key});

  @override
  State<ChannelScreen> createState() => _ChannelScreenState();
}

class _ChannelScreenState extends State<ChannelScreen> {
  final ChannelLogic channelLogic = ChannelLogic();
  final UserService userLogic = UserService();
  List<Map<String, dynamic>> channels = [];
  String? userRole;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    try {
      final role = await userLogic.getUserRole();
      setState(() {
        userRole = role;
      });
      fetchChannels();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load user role: $e')),
      );
    }
  }

  void fetchChannels() async {
    try {
      final userEmail = await userLogic.getUserEmail();
      final userRole = await userLogic.getUserRole();

      QuerySnapshot<Map<String, dynamic>> snapshot;

      if (userRole == 'admin') {
        snapshot = await channelLogic.firestore.collection('channels').get();
      } else {
        snapshot = await channelLogic.firestore
            .collection('channels')
            .where('members', arrayContains: userEmail)
            .get();
      }

      setState(() {
        channels = snapshot.docs.map((doc) {
          return {
            'channelId': doc.id,
            'channelName': doc['name'],
            'members': List<String>.from(doc['members'] ?? []),
          };
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch channels: $e')),
        );
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> createChannelDialog() async {
    final nameController = TextEditingController();
    final membersController = TextEditingController();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Create Channel'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Channel Name'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final members = membersController.text
                    .split(',')
                    .map((e) => e.trim())
                    .where((e) => e.isNotEmpty)
                    .toList();

                if (name.isNotEmpty) {
                  try {
                    await channelLogic.createChannel(
                        name: name, members: members);
                    fetchChannels(); // Refresh the channel list
                    Navigator.of(dialogContext).pop();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to create channel')),
                    );
                  }
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  void navigateToChannelInfo(Map<String, dynamic> channel) {
    if (userRole == 'admin') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChannelInfoScreenAdmin(
            channelId: channel['channelId'],
            channelName: channel['channelName'],
            members: channel['members'],
            onUpdateChannelName: (updatedName) {
              setState(() {
                final index = channels
                    .indexWhere((c) => c['channelId'] == channel['channelId']);
                if (index != -1) {
                  channels[index]['channelName'] = updatedName;
                }
              });
            },
            onUpdateMembersList: (updatedMembers) {
              setState(() {
                final index = channels
                    .indexWhere((c) => c['channelId'] == channel['channelId']);
                if (index != -1) {
                  channels[index]['members'] = updatedMembers;
                }
              });
            },
            onDeleteChannel: () {
              setState(() {
                channels
                    .removeWhere((c) => c['channelId'] == channel['channelId']);
              });
            },
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChannelInfoScreen(
            channelId: channel['channelId'],
            channelName: channel['channelName'],
            members: channel['members'],
          ),
        ),
      );
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text(
        'Channels',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 22,
          color: Colors.white, // White text for contrast
        ),
      ),
      centerTitle: true,
      backgroundColor: AppTheme.blueColor, // Main theme for AppBar
      elevation: 0,
    ),
    body: isLoading
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: ListView.builder(
              itemCount: channels.length,
              itemBuilder: (context, index) {
                final channel = channels[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.blueColor.withOpacity(0.8), // Slightly darker shade
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    title: Text(
                      channel['channelName'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // White text for readability
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.info_outline,
                        color: Colors.white,
                      ),
                      onPressed: () => navigateToChannelInfo(channel),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChannelMessagesScreen(
                            channelId: channel['channelId'],
                            channelName: channel['channelName'],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
    floatingActionButton: userRole == 'admin'
        ? FloatingActionButton.extended(
            onPressed: createChannelDialog,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('Create'),
            backgroundColor: AppTheme.lightGreenColor, // Light green for differentiation
          )
        : null,
  );
}
}
