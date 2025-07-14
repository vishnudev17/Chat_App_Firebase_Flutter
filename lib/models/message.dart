import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderId;
  final String senderMail;
  final String recieverId;
  final String message;
  final Timestamp timestamp;

  Message({
    required this.senderId,
    required this.senderMail,
    required this.recieverId,
    required this.message,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderMail': senderMail,
      'reciverId': recieverId,
      'message': message,
      'timestamp': timestamp,
    };
  }
}
