import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class Database {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseAuth _auth =FirebaseAuth.instance;
  Future<void> createNotification(Timestamp whenToNofify) async {
    bool retVal;
    String _uuid ="";
    String fcmToken = await _fcm.getToken();
    final user = await _auth.currentUser;
    if (user != null) {
          _uuid = user.uid;
    }
    try {
      await _firestore.collection("notifications").doc().set({
        'token': fcmToken,
        'whenToNotify': whenToNofify,
        'notificationSent': false,
        'uuid':_uuid 
      });
    } catch (e) {
      print(e);
    }
    return retVal;
  }
}
