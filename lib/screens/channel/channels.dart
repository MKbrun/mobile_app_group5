import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app_group5/backend/channel_backend/channel_logic.dart';
import 'package:mobile_app_group5/backend/user_logic.dart';
import 'package:mobile_app_group5/screens/channel/channel_info_screen_admin.dart';
import 'package:mobile_app_group5/screens/channel/channel_info_screen_user.dart';
import 'package:mobile_app_group5/screens/channel/channel_messages_screen.dart';

class ChannelScreen extends StatefulWidget {
  const ChannelScreen({super.key});

  @override
  State<ChannelScreen> createState() => _ChannelScreenState();
}

class _ChannelScreenState extends State<ChannelScreen> {
  final ChannelLogic channelLogic = ChannelLogic();
  final UserService userLogic = UserService(); // To fetch the user role
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
      // Fetch the logged-in user's role
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
        // Admin: Fetch all channels
        snapshot = await channelLogic.firestore.collection('channels').get();
      } else {
        // User: Fetch channels where the user is a member
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
        isLoading = false; // Ensure loading is complete
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch channels: $e')),
        );
        setState(() {
          isLoading = false; // Ensure loading is complete even on error
        });
      }
    }
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
                final index = channels.indexWhere((c) => c['channelId'] == channel['channelId']);
                if (index != -1) {
                  channels[index]['channelName'] = updatedName;
                }
              });
            },
            onUpdateMembersList: (updatedMembers) {
              setState(() {
                final index = channels.indexWhere((c) => c['channelId'] == channel['channelId']);
                if (index != -1) {
                  channels[index]['members'] = updatedMembers;
                }
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
        title: const Text('Channels'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: channels.length,
              itemBuilder: (context, index) {
                final channel = channels[index];
                return ListTile(
                  title: Text(
                    channel['channelName'],
                    style: const TextStyle(fontSize: 20),
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
                  trailing: IconButton(
                    icon: const Icon(Icons.info_outline),
                    onPressed: () => navigateToChannelInfo(channel),
                  ),
                );
              },
            ),
    );
  }
}
