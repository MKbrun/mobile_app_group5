// channels.dart
import 'package:flutter/material.dart';

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

  // channel list
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Channels')),
      body: ListView.builder(
        itemCount: channels.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(
              channels[index],
              style: const TextStyle(fontSize: 25),
            ),
            onTap: () => navigateToChannelDetail(channels[index]),
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
          '$channelName!',
          style: const TextStyle(fontSize: 25),
        ),
      ),
    );
  }
}
