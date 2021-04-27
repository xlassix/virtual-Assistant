import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:todolist/screens/landing.dart';
import 'package:todolist/screens/loginScreen.dart';
import 'package:todolist/screens/registrationScreen.dart';
import 'package:todolist/screens/todo_screen.dart';

Future<void> main()async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.purple,
        accentColor: Colors.grey),
      home: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Landing(),
      routes: {
        LoginScreen.id: (context) => LoginScreen(),
        TodoScreen.id: (context) =>  TodoScreen(),
        RegistrationScreen.id: (context) => RegistrationScreen()
      }
      
    );
  }
}