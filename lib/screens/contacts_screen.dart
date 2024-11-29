import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_app_group5/screens/chat_screen.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ContactsScreenState();
  }
}

class _ContactsScreenState extends State<ContactsScreen> {
  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

  Stream<List<Map<String, dynamic>>> _getContactsWithLastMessage() async* {
    final String? userId = currentUserId;
    if (userId == null) {
      yield [];
      return;
    }

    final contactsStream = FirebaseFirestore.instance
        .collection('users')
        .where(FieldPath.documentId, isNotEqualTo: userId)
        .snapshots();

    final privateChatsStream = FirebaseFirestore.instance
      .collection('private_chats')
      .snapshots();

    await for (var chatsSnapshot in privateChatsStream) {
    final List<Map<String, dynamic>> contacts = [];
    final contactsSnapshot = await contactsStream.first;
    for (var contactDoc in contactsSnapshot.docs) {
      final contactId = contactDoc.id;
      final contactData = contactDoc.data();

        final chatId = userId.compareTo(contactId) < 0
            ? '${userId}_$contactId'
            : '${contactId}_$userId';

        final chatDoc = await FirebaseFirestore.instance
            .collection('private_chats')
            .doc(chatId)
            .get();

        final lastMessage = chatDoc.exists
            ? chatDoc['lastMessage'] as Map<String, dynamic>?
            : null;

        contacts.add({
          'userId': contactId,
          'username': contactData['username'] ?? 'Unknown',
          'image_url': contactData['image_url'],
          'lastMessage': lastMessage,
        });
      }
      yield contacts;
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
      appBar: AppBar(title: const Text('Contacts')),
      body: StreamBuilder<List<Map<String, dynamic>>>(
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

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage:
                      imageUrl != null ? NetworkImage(imageUrl) : null,
                  onBackgroundImageError: imageUrl != null
                      ? (exception, stackTrace) {
                          print('Error loading image: $exception');
                        }
                      : null,
                  child: imageUrl == null &&
                          username != null &&
                          username.isNotEmpty
                      ? Text(username[0])
                      : null,
                ),
                title: Text(
                  username ?? 'Unknown',
                  style: const TextStyle(fontSize: 20),
                ),
                subtitle: lastMessage != null && lastMessage['text'] != null
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
                    // Handle the case where userId or username is null
                    print('User ID or Username is null');
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
