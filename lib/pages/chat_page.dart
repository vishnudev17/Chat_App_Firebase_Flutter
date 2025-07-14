import 'dart:io';
import 'package:chat_app_firebase/components/chat_bubble.dart';
import 'package:chat_app_firebase/components/my_text_fields.dart';
import 'package:chat_app_firebase/pages/home_page.dart';
import 'package:chat_app_firebase/pages/profileimage_preview.dart';
import 'package:chat_app_firebase/services/auth/auth_service.dart';
import 'package:chat_app_firebase/services/chat/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({
    super.key,
    required this.recieverMail,
    required this.recieverId,
  });

  final String recieverMail;
  final String recieverId;

  @override
  State<StatefulWidget> createState() {
    return _ChatPage();
  }
}

class _ChatPage extends State<ChatPage> {
  File? image;

  final TextEditingController _messageEditingController =
      TextEditingController();
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  void sendMessage() async {
    if (_messageEditingController.text.isNotEmpty) {
      await _chatService.sendMessage(
        widget.recieverId,
        _messageEditingController.text,
      );
      _messageEditingController.clear();
    }
  }

  @override
  void initState() {
    super.initState();
    loadImage();
  }

  void loadImage() async {
    final email = widget.recieverMail;

    final dir = await getApplicationDocumentsDirectory();
    final safeFileName = email.replaceAll('@', '_').replaceAll('.', '_');
    final path = '${dir.path}/profile_image_$safeFileName.png';
    final file = File(path);

    if (await file.exists()) {
      setState(() {
        image = file;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileImagePreview(image: image),
                  ),
                );
              },
              child: CircleAvatar(
                radius: 18,
                backgroundImage: image != null
                    ? FileImage(image!)
                    : AssetImage('assets/images/avatar.png') as ImageProvider,
                key: UniqueKey(),
              ),
            ),
            SizedBox(width: 15),
            Expanded(
              child: Text(
                widget.recieverMail[0].toUpperCase() +
                    widget.recieverMail.split('@')[0].substring(1),
                style: TextStyle(color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: Color(0xFF075E54),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          _buildUserInput(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    String senderId = _authService.getCurrentUser()!.uid;
    return StreamBuilder(
      stream: _chatService.getMessages(widget.recieverId, senderId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text("Error");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading...");
        }

        return ListView(
          children: snapshot.data!.docs
              .map((doc) => _buildMessageItem(doc))
              .toList(),
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    bool isCurrentUser = data["senderId"] == _authService.getCurrentUser()!.uid;
    var alignment = isCurrentUser
        ? Alignment.centerRight
        : Alignment.centerLeft;

    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: isCurrentUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          ChatBubble(
            isCurrentUser: isCurrentUser,
            message: data["message"],
            timestamp: data["timestamp"],
          ),
        ],
      ),
    );
  }

  Widget _buildUserInput() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 50.0),
      child: Row(
        children: [
          Expanded(
            child: MyTextFields(
              hintText: "Type a message!",
              obscureText: false,
              controller: _messageEditingController,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            margin: EdgeInsets.only(right: 25),
            child: IconButton(
              onPressed: sendMessage,
              icon: Icon(Icons.arrow_upward),
            ),
          ),
        ],
      ),
    );
  }
}
