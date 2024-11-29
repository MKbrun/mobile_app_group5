import 'package:flutter/material.dart';
import 'channel_info_screen_admin.dart';

class ChannelScreen extends StatefulWidget {
  const ChannelScreen({super.key});

  @override
  State<ChannelScreen> createState() => _ChannelScreenState();
}

class _ChannelScreenState extends State<ChannelScreen> {
  List<String> channels = [];

  @override
  void initState() {
    super.initState();
    fetchChannels();
  }

  void fetchChannels() {
    setState(() {
      channels = ['Channel 1', 'Channel 2', 'Channel 3', 'Channel 4'];
    });
  }

  void navigateToChannelDetail(String channel) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChannelDetailScreen(channelName: channel),
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
              int index = channels.indexOf(channel);
              if (index != -1) {
                channels[index] = updatedName;
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
          final String channel = channels[index];
          return ListTile(
            title: Text(
              channel,
              style: const TextStyle(fontSize: 20),
            ),
            onTap: () => navigateToChannelDetail(channel),
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