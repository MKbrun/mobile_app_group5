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
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  Stream<List<Map<String, dynamic>>> _getContactsWithLastMessage() async* {
    final contactsStream = FirebaseFirestore.instance
        .collection('users')
        .where(FieldPath.documentId, isNotEqualTo: currentUserId)
        .snapshots();

    await for (var contactsSnapshot in contactsStream) {
      final List<Map<String, dynamic>> contacts = [];
      for (var contactDoc in contactsSnapshot.docs) {
        final contactId = contactDoc.id;
        final contactData = contactDoc.data();

        final chatId = currentUserId.compareTo(contactId) < 0
            ? '${currentUserId}_$contactId'
            : '${contactId}_$currentUserId';

        final chatDoc = await FirebaseFirestore.instance
            .collection('private_chats')
            .doc(chatId)
            .get();

        final lastMessage = chatDoc.exists
            ? chatDoc['lastMessage'] as Map<String, dynamic>?
            : null;

        contacts.add({
          'userId': contactId,
          'username': contactData['username'],
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
                  backgroundImage: imageUrl != null
                      ? NetworkImage(imageUrl)
                      : null, 
                  child: imageUrl == null ? Text(username[0]) : null, 
                ),
                title: Text(
                  username,
                  style: const TextStyle(fontSize: 20),
                ),
                subtitle: lastMessage != null
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
                onTap: () => navigateToChat(userId, username),
              );
            },
          );
        },
      ),
    );
  }
}
