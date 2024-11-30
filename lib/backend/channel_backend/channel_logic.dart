import 'package:cloud_firestore/cloud_firestore.dart';

class ChannelLogic {
  final FirebaseFirestore firestore;

  ChannelLogic({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> createChannel({
    required String name,
    required List<String> members,
  }) async {
    try {
      final channelCollection = firestore.collection('channels');

      // Log the data to be added
      print('Creating channel with data: name=$name, members=$members');

      final channelData = {
        'name': name,
        'members': members,
      };

      final channelDocRef = await channelCollection.add(channelData);

      // Log the generated document ID
      print('Channel created with ID: ${channelDocRef.id}');

      // Initialize the messages subcollection with a welcome message
      await channelDocRef.collection('messages').add({
        'content': 'Welcome to the channel!',
        'createdBy': 'system',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Confirm subcollection addition
      print('Welcome message added to channel: ${channelDocRef.id}');
    } catch (e) {
      print('Error creating channel: $e');
      rethrow;
    }
  }

  // Method to update a channel
  Future<void> updateChannel({
    required String channelId,
    String? name,
    String? description,
    List<String>? members,
  }) async {
    try {
      final channelDocRef = firestore.collection('channels').doc(channelId);

      final Map<String, dynamic> updates = {};
      if (name != null) updates['name'] = name;
      if (members != null) updates['members'] = members;

      await channelDocRef.update(updates);
    } catch (e) {
      print('Error updating channel: $e');
      rethrow;
    }
  }
}
