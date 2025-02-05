import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  static Future<void> joinChatRoom(String country, String city) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final chatRoomId = '${country}_$city'.replaceAll(' ', '_').toLowerCase();

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('joined_rooms')
        .doc(chatRoomId)
        .set({
      'country': country,
      'city': city,
      'joinedAt': FieldValue.serverTimestamp(),
    });
  }
}
