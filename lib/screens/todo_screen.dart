import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todolist/screens/loginScreen.dart';
import 'package:todolist/util/todo.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';

class TodoScreen extends StatefulWidget {
  static const String id = "TodoScreen";
  @override
  _TodoScreenState createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  List todos;
  String input = "";
  String uuid;
  bool _loading;
  final format = DateFormat("dd-MM-yyyy HH:mm");

  final _auth = FirebaseAuth.instance;
  User loggedInUser;
  SharedPreferences prefs;

  void getUser() async {
    prefs = await SharedPreferences.getInstance();
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
        setState(() {
          uuid = user.uid;
        });
        print(uuid);
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _loading = true;
    });
    getUser();
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Container(
        color: Colors.white,
        child: Expanded(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(),
                CircularProgressIndicator(
                  backgroundColor: Colors.purpleAccent,
                )
              ]),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.logout),
              onPressed: () {
                _auth.signOut();
                prefs.remove("userId");
                Navigator.pushNamedAndRemoveUntil(
                    context, LoginScreen.id, (route) => false);
              })
        ],
        backgroundColor: Colors.purple,
        title: Text("Virtual Assistant"),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple,
        onPressed: () {
          Todo _todo = Todo(uuid: uuid);
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  title: Text("Add Todolist"),
                  content: Column(
                    children: [
                      TextField(
                        onChanged: (String value) {
                          input = value;
                        },
                      ),
                      Text('Basic date & time field (${format.pattern})'),
                      DateTimeField(
                        format: format,
                        onShowPicker: (context, currentValue) async {
                          final date = await showDatePicker(
                              context: context,
                              firstDate: DateTime(1900),
                              initialDate: currentValue ?? DateTime.now(),
                              lastDate: DateTime(2100));
                          if (date != null) {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(
                                  currentValue ?? DateTime.now()),
                            );
                            return DateTimeField.combine(date, time);
                          } else {
                            return currentValue;
                          }
                        },
                      ),
                    ],
                  ),
                  actions: <Widget>[
                    FlatButton(
                        onPressed: () {
                          _todo.createTodos(input);
                          Navigator.of(context).pop();
                          setState(() {});
                        },
                        child: Text("Add"))
                  ],
                );
              });
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("MyTodolist")
              .where("uuid", isEqualTo: uuid)
              .snapshots(),
          builder: (context, snapshots) {
            if (!snapshots.hasData) {
              return Expanded(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(),
                  CircularProgressIndicator(),
                ],
              ));
            }

            return ListView.builder(
                shrinkWrap: true,
                itemCount: snapshots.data.docChanges.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot documentSnapshot =
                      snapshots.data.docs[index];
                  return Card(
                    key: Key(documentSnapshot.id),
                    elevation: 4,
                    margin: EdgeInsets.all(8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    child: ListTile(
                      title: Text(documentSnapshot["todoTitle"]),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          Todo.deleteTodos(documentSnapshot);
                          setState(() {});
                        },
                      ),
                    ),
                  );
                });
          }),
    );
  }
}
