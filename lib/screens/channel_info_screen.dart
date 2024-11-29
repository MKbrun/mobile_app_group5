import 'package:flutter/material.dart';

class ChannelInfoScreen extends StatefulWidget {
  final String channelName;
  final ValueChanged<String> onUpdateChannelName;

  const ChannelInfoScreen({
    super.key,
    required this.channelName,
    required this.onUpdateChannelName,
  });

  @override
  State<ChannelInfoScreen> createState() => _ChannelInfoScreenState();
}

class _ChannelInfoScreenState extends State<ChannelInfoScreen> {
  late TextEditingController _channelNameController;
  late TextEditingController _emailController;

  // Dummy user data
  List<Map<String, String>> users = [
    {'name': 'A', 'email': 'a@example.com'},
    {'name': 'B', 'email': 'b@example.com'},
    {'name': 'C', 'email': 'c@example.com'},
    {'name': 'D', 'email': 'd@example.com'},
    {'name': 'E', 'email': 'e@example.com'},
  ];

  final double _inputHeight = 50.0; 
  final double _buttonHeight = 40.0;
  final double _buttonWidth = 80.0;
  final double _maxWidth = 600.0;

  final InputDecoration _textFieldDecoration = const InputDecoration(
    border: OutlineInputBorder(),
    hintStyle: TextStyle(fontSize: 16),
    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
  );

  @override
  void initState() {
    super.initState();
    _channelNameController = TextEditingController(text: widget.channelName);
    _emailController = TextEditingController();

    sortUsers();
  }

  @override
  void dispose() {
    _channelNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void saveUpdatedName() {
    widget.onUpdateChannelName(_channelNameController.text);
    Navigator.of(context).pop();
  }

  void addUserByEmail() {
    final String email = _emailController.text.trim();
    if (email.isNotEmpty) {
      setState(() {
        users.add({'name': email.split('@')[0], 'email': email}); 
        sortUsers();
      });
      _emailController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$email added to ${widget.channelName}.')),
      );
    }
  }

  void sortUsers() {
    users.sort((a, b) => a['name']!.compareTo(b['name']!));
  }

  void removeUser(int index) {
    setState(() {
      users.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Info: ${widget.channelName}'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: _maxWidth),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: SizedBox(
                        height: _inputHeight,
                        child: TextField(
                          controller: _channelNameController,
                          decoration: _textFieldDecoration.copyWith(
                            hintText: 'Edit Channel Name',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      height: _buttonHeight,
                      width: _buttonWidth,
                      child: ElevatedButton(
                        onPressed: saveUpdatedName,
                        child: const Text('Save'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Details about ${widget.channelName}.',
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: SizedBox(
                        height: _inputHeight,
                        child: TextField(
                          controller: _emailController,
                          decoration: _textFieldDecoration.copyWith(
                            hintText: 'Add User by Email',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      height: _buttonHeight,
                      width: _buttonWidth,
                      child: ElevatedButton(
                        onPressed: addUserByEmail,
                        child: const Text('Add'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Users in Channel:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return Dismissible(
                        key: Key(user['email']!),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) {
                          removeUser(index);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${user['name']} removed')),
                          );
                        },
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        child: ListTile(
                          title: Text(user['name']!),
                          subtitle: Text(user['email']!),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
