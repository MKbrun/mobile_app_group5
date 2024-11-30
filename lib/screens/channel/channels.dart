import 'package:flutter/material.dart';
import 'package:mobile_app_group5/backend/channel_backend/channel_logic.dart';
import 'package:mobile_app_group5/screens/channel/channel_info_screen_admin.dart';

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
    final channelCollection = channelLogic.firestore.collection('channels');
    final snapshot = await channelCollection.get();

    setState(() {
      channels = snapshot.docs.map((doc) {
        return {
          'channelId': doc.id,
          'channelName': doc['name'],
          'members': List<String>.from(doc['members'] ?? []),
        };
      }).toList();
    });
  }

  void navigateToChannelInfo(Map<String, dynamic> channel) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChannelInfoScreen(
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
              channel['channelName'],
              style: const TextStyle(fontSize: 20),
            ),
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
