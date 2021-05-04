import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todolist/screens/loginScreen.dart';
import 'package:todolist/util/notification.dart';
import 'package:todolist/util/todo.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:math';

class TodoScreen extends StatefulWidget {
  static const String id = "TodoScreen";
  @override
  _TodoScreenState createState() => _TodoScreenState();
}

enum TodoType { once, recurring }

String readTimestamp(int timestamp) {
  var now = DateTime.now();
  var format = DateFormat('HH:mm a');
  var date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
  var diff = now.difference(date);
  var time = '';

  if (diff.inSeconds <= 0 ||
      diff.inSeconds > 0 && diff.inMinutes == 0 ||
      diff.inMinutes > 0 && diff.inHours == 0 ||
      diff.inHours > 0 && diff.inDays == 0) {
    time = format.format(date);
  } else if (diff.inDays > 0 && diff.inDays < 7) {
    if (diff.inDays == 1) {
      time = diff.inDays.toString() + ' DAY AGO';
    } else {
      time = diff.inDays.toString() + ' DAYS AGO';
    }
  } else {
    if (diff.inDays == 7) {
      time = (diff.inDays / 7).floor().toString() + ' WEEK AGO';
    } else {
      time = (diff.inDays / 7).floor().toString() + ' WEEKS AGO';
    }
  }

  return time;
}

const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails('repeating channel id', 'repeating channel name',
        'repeating description');

const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

class _TodoScreenState extends State<TodoScreen> {
  List todos;
  String input = "";
  String uuid;
  DateTime _todoDateValue;
  bool _loading;
  final format = DateFormat("dd-MM-yyyy HH:mm");
  final _auth = FirebaseAuth.instance;
  User loggedInUser;
  SharedPreferences prefs;
  TodoType value = TodoType.once;
  List<Map> _expired = [];

  void notification(List _list) async {
    print(_list.length);
    for (var i = 0; i < _list.length; i++) {
      var x = _list[i];
      await flutterLocalNotificationsPlugin.show(
          i,
          "Virtual Assistant",
          "Task :${x['title']} was due ${x['time']} minutes ago ",
          platformChannelSpecifics,
          payload: 'data');
    }
    _list = [];
  }

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
                Row(key: Key("empty row")),
                CircularProgressIndicator(
                    backgroundColor: Colors.purpleAccent,
                    key: Key("empty progress")),
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
                  content: SizedBox(
                    height: 150,
                    child: Column(
                      children: [
                        TextField(
                          maxLength: 200,
                          onChanged: (String value) {
                            input = value;
                          },
                        ),
                        Row(
                          children:
                              //TODO: implement Radio Button
                              [],
                        ),
                        DateTimeField(
                          decoration: const InputDecoration(
                            icon: Icon(Icons.calendar_today),
                            hintText: 'Due Date *',
                            labelText: 'Due Date',
                          ),
                          format: format,
                          onShowPicker: (context, currentValue) async {
                            final date = await showDatePicker(
                                context: context,
                                firstDate: DateTime.now(),
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
                          onChanged: (DateTime value) {
                            setState(() {
                              _todoDateValue = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    FlatButton(
                        onPressed: () {
                          //TODO : add time to CreateTodo method
                          //print(_todoDateValue);
                          _todo.createTodos(input, _todoDateValue);

                          setState(() {});
                          Navigator.of(context).pop();
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
                  Row(key: Key("empty row")),
                  CircularProgressIndicator(key: Key("empty progress")),
                ],
              ));
            }
            for (var item in snapshots.data.docs) {
              var diff = item["time"].toDate().difference(DateTime.now());
              if (diff.isNegative) {
                _expired.add(
                    {"time": diff.abs().inMinutes, "title": item["todoTitle"]});
              }
              print(item);
            }

            notification(_expired);
            Future.delayed(Duration(seconds: 2), () {
              _expired = [];
            });

            return ListView.builder(
                shrinkWrap: true,
                itemCount: snapshots.data.docChanges.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot documentSnapshot =
                      snapshots.data.docs[index];

                  DateTime temp = (documentSnapshot["time"].toDate());
                  return Card(
                    key: Key(documentSnapshot.id),
                    elevation: 4,
                    margin: EdgeInsets.all(8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    child: ListTile(
                      key: Key("tile: " + documentSnapshot.id),
                      title: Text(documentSnapshot["todoTitle"]),
                      subtitle:
                          Text(DateFormat.yMMMMEEEEd().add_jm().format(temp)),
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
