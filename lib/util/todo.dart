import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class Todo{
  String uuid;
  String todo;


  Todo({@required this.uuid,this.todo});


  createTodos(String todo)async{
    CollectionReference documentReference = 
      FirebaseFirestore.instance.collection("MyTodolist");

    //Map
    Map<String, String> todos = {
      "todoTitle": todo,
      "uuid":uuid,
      "time":DateTime.now().toIso8601String(),
    };

    await documentReference.add(todos);

  }

  static deleteTodos(DocumentSnapshot item)async {
    print(item.metadata);
    DocumentReference documentReference = 
      FirebaseFirestore.instance.collection("MyTodolist").doc(item.id);

    await documentReference.delete();
  }
}
