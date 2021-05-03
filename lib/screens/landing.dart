import 'package:flutter/material.dart';
import 'package:todolist/screens/todo_screen.dart';
import 'package:todolist/screens/loginScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Landing extends StatefulWidget {
  final String id = "landing";
  @override
  _LandingState createState() => _LandingState();
}

class _LandingState extends State<Landing> {
  String time;

  void getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await Future.delayed(Duration(seconds: 1), () {});
    if (prefs.getString("userId") == null) {
      Navigator.pushReplacementNamed(context, LoginScreen.id);
    } else {
      Navigator.pushNamedAndRemoveUntil(
          context, TodoScreen.id, (route) => false);
    }
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
          child: Column(
        children: [
          Image.asset('images/logo.png'),
          Text(
            "Virtual Assistant",
            style: TextStyle(color: Colors.purple, fontSize: 30.0),
          ),
          SizedBox(
            height: 20.0,
          ),
          CircularProgressIndicator(
            backgroundColor: Colors.purple,
          )
        ],
        mainAxisAlignment: MainAxisAlignment.center,
      )),
    );
  }
}
