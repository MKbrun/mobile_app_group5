import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_app_group5/screens/chat_screen.dart';
import 'package:mobile_app_group5/themes/app_theme.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<StatefulWidget> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  Stream<List<Map<String, dynamic>>> _getContactsWithLastMessage() async* {
    if (currentUserId == null) {
      yield [];
      return;
    }

    final privateChatsStream =
        FirebaseFirestore.instance.collection('private_chats').snapshots();

    await for (var chatsSnapshot in privateChatsStream) {
      final List<Map<String, dynamic>> contacts = [];

      final contactsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where(FieldPath.documentId, isNotEqualTo: currentUserId)
          .get();

      for (var contactDoc in contactsSnapshot.docs) {
        final contactId = contactDoc.id;
        final contactData = contactDoc.data();

        final chatId = currentUserId!.compareTo(contactId) < 0
            ? '${currentUserId}_$contactId'
            : '${contactId}_$currentUserId';

        final chatDocs = chatsSnapshot.docs.where((doc) => doc.id == chatId);
        final chatDoc = chatDocs.isNotEmpty ? chatDocs.first : null;

        final lastMessage =
            chatDoc?.data()['lastMessage'] as Map<String, dynamic>?;
        final lastMessageTimestamp = lastMessage?['timestamp'] as Timestamp?;

        contacts.add({
          'userId': contactId,
          'username': contactData['username'] ?? 'Unknown',
          'image_url': contactData['image_url'],
          'lastMessage': lastMessage,
          'timestamp': lastMessageTimestamp?.toDate() ?? DateTime(1970),
        });
      }

      contacts.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));

      final filteredContacts = contacts.where((contact) {
        if (_searchQuery.isNotEmpty) {
          return contact['username']
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
        } else {
          return contact['lastMessage'] != null;
        }
      }).toList();

      yield filteredContacts;
    }
  }

  void navigateToChat(String userId, String userName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          userName: userName,
          userId: userId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Contacts',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.blueColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search Contacts...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _getContactsWithLastMessage(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No contacts found.'));
                }

                final contacts = snapshot.data!;

                return ListView.builder(
                  itemCount: contacts.length,
                  itemBuilder: (context, index) {
                    final contact = contacts[index];
                    final userId = contact['userId'];
                    final username = contact['username'];
                    final imageUrl = contact['image_url'];
                    final lastMessage = contact['lastMessage'];

                    final backgroundColor =
                        index % 2 == 0 ? const Color.fromARGB(255, 250, 250, 250) : Colors.white;

                    return Container(
                      color: backgroundColor,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage:
                              imageUrl != null ? NetworkImage(imageUrl) : null,
                          onBackgroundImageError: imageUrl != null
                              ? (exception, stackTrace) {
                                  print('Error loading image: $exception');
                                }
                              : null,
                        ),
                        title: Text(
                          username,
                          style: const TextStyle(fontSize: 20),
                        ),
                        subtitle:
                            lastMessage != null && lastMessage['text'] != null
                                ? Text(
                                    lastMessage['text'],
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: Colors.grey),
                                  )
                                : const Text(
                                    'No messages yet.',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                        onTap: () {
                          if (userId != null && username != null) {
                            navigateToChat(userId, username);
                          } else {
                            print('User ID or Username is null');
                          }
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
