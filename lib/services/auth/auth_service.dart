import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    password,
  ) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      firestore.collection("Users").doc(userCredential.user!.uid).set({
        'uuid': userCredential.user!.uid,
        'email': email,
      });
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  Future<UserCredential> registerWithEmailPassword(
    String email,
    password,
  ) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      firestore.collection("Users").doc(userCredential.user!.uid).set({
        'uuid': userCredential.user!.uid,
        'email': email,
      });
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  Future<void> signOut() async {
    return await _auth.signOut();
  }

  pickImage(ImageSource source, String userEmail) async {
    final ImagePicker _imagePicker = ImagePicker();
    XFile? _file = await _imagePicker.pickImage(source: source);
    if (_file != null) {
      Uint8List imageBytes = await _file.readAsBytes();
      final Directory dir = await getApplicationDocumentsDirectory();
      String safeFileName = userEmail.replaceAll('@', '_').replaceAll('.', '_');
      final String path = '${dir.path}/profile_image_$safeFileName.png';

      final File file = File(path);
      await file.writeAsBytes(imageBytes);
      print("Image saved at: $path");
      return file;
    }
    print("Image Not Selected");
    return null;
  }
}
