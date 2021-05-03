import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class Database {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  Future<void> createNotification(Timestamp whenToNofify) async {
    bool retVal;
    String fcmToken = await _fcm.getToken();
    try {
      await _firestore.collection("notifications").doc(fcmToken).set({
        'token': fcmToken,
        'whenToNotify': whenToNofify,
        'notificationSent': false,

      });
    } catch (e) {
      print(e);
    }
    return retVal;
  }
}
