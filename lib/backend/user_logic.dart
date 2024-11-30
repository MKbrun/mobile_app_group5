import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  UserService({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : auth = auth ?? FirebaseAuth.instance,
        firestore = firestore ?? FirebaseFirestore.instance;

  // Get the currently logged-in user's ID
  Future<String> getUserId() async {
    final currentUser = auth.currentUser;
    if (currentUser == null) {
      throw Exception('No user is currently logged in');
    }
    return currentUser.uid;
  }

  // Get the currently logged-in user's role
  Future<String> getUserRole() async {
    final currentUser = auth.currentUser;
    if (currentUser == null) {
      throw Exception('No user is currently logged in');
    }

    try {
      final doc = await firestore.collection('users').doc(currentUser.uid).get();
      if (doc.exists && doc.data() != null) {
        return doc.data()!['role'] ?? 'user'; // Default to 'user' if role is missing
      } else {
        throw Exception('User data not found in Firestore');
      }
    } catch (e) {
      throw Exception('Failed to fetch user role: $e');
    }
  }

  // Get the currently logged-in user's email
  Future<String> getUserEmail() async {
    final currentUser = auth.currentUser;
    if (currentUser == null) {
      throw Exception('No user is currently logged in');
    }
    return currentUser.email ?? '';
  }
}
