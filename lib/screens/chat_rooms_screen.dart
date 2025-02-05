import 'package:flutter/material.dart';
import '../models/joined_chat_room.dart';
import 'chat_room_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/ad_service.dart';
import 'login_screen.dart';

class ChatRoomsScreen extends StatefulWidget {
  const ChatRoomsScreen({super.key});

  @override
  State<ChatRoomsScreen> createState() => _ChatRoomsScreenState();
}

class _ChatRoomsScreenState extends State<ChatRoomsScreen> {
  List<JoinedChatRoom> _joinedRooms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadJoinedRooms();
  }

  Future<void> _loadJoinedRooms() async {
    setState(() => _isLoading = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('joined_rooms')
          .orderBy('joinedAt', descending: true)
          .get();

      setState(() {
        _joinedRooms = snapshot.docs.map((doc) {
          final data = doc.data();
          return JoinedChatRoom(
            country: data['country'],
            city: data['city'],
            joinedAt: (data['joinedAt'] as Timestamp).toDate(),
          );
        }).toList();
        _isLoading = false;
      });
    }
  }

  static Future<void> joinChatRoom(String country, String city) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final roomId = '${country}_$city'
        .replaceAll(' ', '_')
        .replaceAll('.', '')
        .toLowerCase();

    final roomRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('joined_rooms')
        .doc(roomId);

    final roomDoc = await roomRef.get();
    if (!roomDoc.exists) {
      await roomRef.set({
        'country': country,
        'city': city,
        'joinedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> _removeRoom(int index) async {
    final room = _joinedRooms[index];
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      _joinedRooms.removeAt(index);
    });

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('joined_rooms')
          .doc('${room.country}_${room.city}')
          .delete();
    } catch (e) {
      // 삭제 실패 시 목록 복구
      setState(() {
        _joinedRooms.insert(index, room);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('채팅방 나가기에 실패했습니다')),
        );
      }
    }
  }

  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('로그아웃 중 오류가 발생했습니다'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '참여중인 채팅방',
          style: TextStyle(color: Color(0xFF4c75e4)),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: Color(0xFF4c75e4),
            ),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _joinedRooms.isEmpty
              ? const Center(
                  child: Text(
                    '참여중인 채팅방이 없습니다\n채팅방에 참여해보세요!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: _joinedRooms.length,
                  itemBuilder: (context, index) {
                    final room = _joinedRooms[index];
                    return Dismissible(
                      key: Key('${room.country}-${room.city}'),
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16.0),
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) => _removeRoom(index),
                      child: ListTile(
                        leading: const Icon(
                          Icons.chat_bubble_outline,
                          color: Color(0xFF4c75e4),
                        ),
                        title: Text(room.city),
                        subtitle: Text(room.country),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          color: Color(0xFF4c75e4),
                        ),
                        onTap: () async {
                          await AdService.showInterstitialAd(); // 광고 표시
                          if (mounted) {
                            final chatRoomId = '${room.country}_${room.city}'
                                .replaceAll(' ', '_')
                                .replaceAll('.', '')
                                .toLowerCase();

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatRoomScreen(
                                  country: room.country,
                                  city: room.city,
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
