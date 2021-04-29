import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';


class Todo {
  String uuid;
  String todo;
  DateTime date;

  Todo({@required this.uuid, this.todo, this.date});

  createTodos(String todo, DateTime date) async {
    CollectionReference documentReference =
        FirebaseFirestore.instance.collection("MyTodolist");

    //Map
    Map<String, dynamic> todos = {
      "todoTitle": todo,
      "uuid": uuid,
      "time": date,
    };

    await documentReference.add(todos);
  }

  static deleteTodos(DocumentSnapshot item) async {
    print(item.metadata);
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection("MyTodolist").doc(item.id);

    await documentReference.delete();
  }
}
