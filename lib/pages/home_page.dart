import 'dart:io';
import 'package:chat_app_firebase/pages/chat_page.dart';
import 'package:chat_app_firebase/services/auth/auth_service.dart';
import 'package:chat_app_firebase/components/my_drawer.dart';
import 'package:chat_app_firebase/services/chat/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<StatefulWidget> createState() {
    return _HomePage();
  }
}

class _HomePage extends State<HomePage> {
  final ChatService chatService = ChatService();
  final AuthService authService = AuthService();

  Future<File?> _loadProfileImage(String email) async {
    final Directory dir = await getApplicationDocumentsDirectory();
    String safeFileName = email.replaceAll('@', '_').replaceAll('.', '_');
    final String path = '${dir.path}/profile_image_$safeFileName.png';

    final File file = File(path);
    if (await file.exists()) {
      return file;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF075E54),
        centerTitle: false,
        elevation: 0,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(left: 1.0),
          child: Text(
            'Chats',
            style: TextStyle(fontSize: 28, color: Colors.white),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: MyDrawer(),
      body: _buildUserList(),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder(
      stream: chatService.getUserStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("error");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Loading....");
        }
        return ListView(
          children: snapshot.data!
              .map<Widget>((userData) => _buildUserListItem(userData, context))
              .toList(),
        );
      },
    );
  }

  Widget _buildUserListItem(
    Map<String, dynamic> userData,
    BuildContext context,
  ) {
    final currentUser = authService.getCurrentUser();
    final currentUserEmail = currentUser?.email;
    final currentUserId = currentUser?.uid;

    if (userData["email"] == currentUserEmail) return const SizedBox();

    final recieverId = userData["uuid"];

    return FutureBuilder<File?>(
      future: _loadProfileImage(userData["email"]),
      builder: (context, snapshot) {
        ImageProvider imageProvider;

        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData &&
            snapshot.data != null &&
            snapshot.data!.existsSync()) {
          imageProvider = FileImage(snapshot.data!);
        } else {
          imageProvider = const AssetImage('assets/images/avatar.png');
        }

        return StreamBuilder<QuerySnapshot>(
          stream: chatService.getMessages(recieverId, currentUserId!),
          builder: (context, messageSnapshot) {
            String lastMessage = "Tap to chat";
            String time = "";
            int unreadCount = 0;

            if (messageSnapshot.hasData &&
                messageSnapshot.data!.docs.isNotEmpty) {
              final docs = messageSnapshot.data!.docs;

              docs.sort((a, b) {
                final aTime =
                    (a.data() as Map<String, dynamic>)['timestamp']
                        as Timestamp;
                final bTime =
                    (b.data() as Map<String, dynamic>)['timestamp']
                        as Timestamp;
                return bTime.compareTo(aTime);
              });

              final latestData = docs.first.data() as Map<String, dynamic>;
              lastMessage = latestData["message"] ?? "";
              Timestamp timestamp = latestData["timestamp"];
              time = DateFormat.jm().format(timestamp.toDate());

              unreadCount = docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return data["senderId"] == recieverId; // not current user
              }).length;
            }

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                leading: CircleAvatar(
                  radius: 25,
                  backgroundImage: imageProvider,
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        userData["email"][0].toUpperCase() +
                            userData["email"].split('@')[0].substring(1),
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    Text(
                      time,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color.fromARGB(255, 135, 135, 135),
                      ),
                    ),
                  ],
                ),
                subtitle: Row(
                  children: [
                    Expanded(
                      child: Text(
                        lastMessage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    if (unreadCount > 0)
                      // Optional unread message badge
                      Container(
                        margin: const EdgeInsets.only(left: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          unreadCount.toString(),
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                  ],
                ),
                onTap: () {
                  setState(() {
                    unreadCount = 0;
                  });
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatPage(
                        recieverMail: userData["email"],
                        recieverId: userData["uuid"],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
