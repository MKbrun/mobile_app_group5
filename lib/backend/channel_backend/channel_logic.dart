import 'package:cloud_firestore/cloud_firestore.dart';

class ChannelLogic {
  final FirebaseFirestore firestore;

  ChannelLogic({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  // Fetch all users from Firestore
  Future<List<Map<String, dynamic>>> fetchAllUsers() async {
    try {
      final snapshot = await firestore.collection('users').get();

      final excludedDocumentId = 'adminList';

      return snapshot.docs.where((doc) => doc.id != excludedDocumentId).map((doc) {
        return {
          'id': doc.id,
          'email': doc['email'],
          'image_url': doc['image_url'],
          'username': doc['username'],
        };
      }).toList();
    } catch (e) {
      print('Error fetching users: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchChannels({
    required String userId,
    required String role,
  }) async {
    try {
      final channelCollection = firestore.collection('channels');

      QuerySnapshot<Map<String, dynamic>> snapshot;
      if (role == 'admin') {
        // Admins can see all channels
        snapshot = await channelCollection.get();
      } else {
        // Users only see channels they are members of
        snapshot = await channelCollection.where('members', arrayContains: userId).get();
      }

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] ?? '',
          'members': List<String>.from(data['members'] ?? []),
        };
      }).toList();
    } catch (e) {
      print('Error fetching channels: $e');
      rethrow;
    }
  }

  // Create a channel
  Future<void> createChannel({
    required String name,
    required List<String> members,
  }) async {
    try {
      final channelCollection = firestore.collection('channels');
      final channelData = {
        'name': name,
        'members': members,
      };

      final channelDocRef = await channelCollection.add(channelData);
      await channelDocRef.collection('messages').add({
        'content': 'Welcome to the channel!',
        'createdBy': 'system',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error creating channel: $e');
      rethrow;
    }
  }

  // Update a channel
  Future<void> updateChannel({
    required String channelId,
    String? name,
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
