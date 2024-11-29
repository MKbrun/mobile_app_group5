import 'package:cloud_firestore/cloud_firestore.dart';

class AdminChecker {
  late final FirebaseFirestore firestore;

  // Constructor to allow dependency injection
  AdminChecker({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  // Fetch the admin list
  Future<List<String>> getAdminList() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await firestore.collection('users').doc('adminList').get();

      // Use the data() method to retrieve the map
      Map<String, dynamic>? data = snapshot.data();
      if (data == null || !data.containsKey('admins')) {
        return [];
      }

      return List<String>.from(data['admins']);
    } catch (e) {
      print('Error fetching admin list: $e');
      return [];
    }
  }

  // Check if a user is an admin
  Future<bool> isAdmin(String userId) async {
    try {
      List<String> adminList = await getAdminList();
      return adminList.contains(userId);
    } catch (e) {
      print('Error checking admin status: $e');
      return false;
    }
  }
}
