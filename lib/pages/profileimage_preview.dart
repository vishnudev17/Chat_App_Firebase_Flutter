import 'package:flutter/material.dart';
import 'dart:io';

class ProfileImagePreview extends StatelessWidget {
  const ProfileImagePreview({super.key, this.image});

  final File? image;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primary,
        body: Center(
          child: CircleAvatar(
            radius: MediaQuery.of(context).size.width / 2.5,
            backgroundImage: image != null
                ? FileImage(image!)
                : AssetImage('assets/images/avatar.png') as ImageProvider,
          ),
        ),
      ),
    );
  }
}
