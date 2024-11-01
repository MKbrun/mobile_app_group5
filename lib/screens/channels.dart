import 'package:flutter/material.dart';
import 'package:mobile_app_group5/widgets/bottom_nav_bar.dart';

class ChannelScreen extends StatefulWidget {
  const ChannelScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ChannelScreenState();
  }
}

class _ChannelScreenState extends State<ChannelScreen> {
  int _currentIndex = 1;
  List<String> channels = [];

  void _onNavBarTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

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
      appBar: AppBar(
        title: Text('Channels'),
      ),
      body: ListView.builder(
        itemCount: channels.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(
              channels[index],
            style: TextStyle(fontSize: 25)),
            onTap: () => navigateToChannelDetail(channels[index]),
          );
        },
      ),
      bottomNavigationBar: BottomNavBar(
        onTap: _onNavBarTap,
        currentIndex: _currentIndex,
      ),
    );
  }
}

// selected channel
class ChannelDetailScreen extends StatelessWidget {
  final String channelName;

  const ChannelDetailScreen({super.key, required this.channelName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(channelName),
      ),
      body: Center(
        child: Text(
          '$channelName!',
          style: TextStyle(fontSize: 25),
        ),
      ),
    );
  }
}