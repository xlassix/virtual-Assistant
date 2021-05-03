import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:todolist/screens/todo_screen.dart';

class Notification extends StatefulWidget {
  Notification({Key key}) : super(key: key);

  @override
  NotificationState createState() => NotificationState();
}

class NotificationState extends State<Notification> {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  @override
  void initState() {
    super.initState();

    // _fcm.configure(
    //   onMessage: (Map<String, dynamic> message) async {
    //     //this callback happens when you are in the app and notification is received
    //     print("onMessage: $message");
    //   },
    //   onLaunch: (Map<String, dynamic> message) async {
    //     //this callback happens when you launch app after a notification received
    //     print("onLaunch: $message");
    //   },
    //   onResume: (Map<String, dynamic> message) async {
    //     //this callbakc happens when you open the app after a notification received AND
    //     //app was running in the background
    //     print("onResume: $message");
    //   },
    // );
    //
  }

  @override
  Widget build(BuildContext context) {
    return TodoScreen();
  }
}
