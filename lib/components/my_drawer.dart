import 'dart:io';

import 'package:chat_app_firebase/services/auth/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({super.key});
  @override
  State<StatefulWidget> createState() {
    return _MyDrawer();
  }
}

class _MyDrawer extends State<MyDrawer> {
  final AuthService authService = AuthService();
  File? image;

  @override
  void initState() {
    super.initState();
    loadImage();
  }

  String? getUserEmail() {
    User? user = authService.getCurrentUser();
    return user?.email;
  }

  void loadImage() async {
    final email = getUserEmail();
    if (email == null) return;

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

  void selectImage() async {
    final email = getUserEmail();
    if (email == null) return;

    File? img = await authService.pickImage(ImageSource.gallery, email);
    setState(() {
      image = img;
    });
  }

  void logOut() {
    authService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Container(
        color: Colors.grey[100],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(30),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF075E54),
                    Color(0xFF128C7E),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(topRight: Radius.circular(20)),
              ),
              child: Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: selectImage,
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 45,
                            backgroundImage: image != null
                                ? FileImage(image!)
                                : AssetImage('assets/images/avatar.png')
                                      as ImageProvider,
                            key: UniqueKey(),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.camera_alt,
                                size: 20,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Icon(Icons.message, color: Colors.white, size: 60),
                    SizedBox(height: 10),
                    Text(
                      'Welcome!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      getUserEmail() != null && getUserEmail()!.contains('@')
                          ? getUserEmail()!
                                .split('@')[0]
                                .replaceFirstMapped(
                                  RegExp(r'^.'),
                                  (match) => match.group(0)!.toUpperCase(),
                                )
                          : '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Main items
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 10,
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.home, size: 23, color: Colors.black87),
                        SizedBox(width: 20),
                        Text(
                          "H O M E",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 10,
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.settings, size: 23, color: Colors.black87),
                        SizedBox(width: 20),
                        Text(
                          "S E T T I N G S",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),

            // LOGOUT at the bottom
            GestureDetector(
              onTap: logOut,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 20,
                ),
                child: Row(
                  children: const [
                    Icon(Icons.logout, size: 23, color: Colors.black87),
                    SizedBox(width: 20),
                    Text(
                      "L O G O U T",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
