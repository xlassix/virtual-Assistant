const functions = require("firebase-functions");
const admin = require('firebase-admin');
admin.initializeApp();
const database = admin.firestore();

exports.timerUpdate = functions.pubsub.schedule('* * * * *').onRun((context) => {
    database.doc("MyTodolist/05Qq9K7OVRETjrqK2eUH").update({"time":admin.firestore.Timestamp.now()})
    return console.log('Successful time update');
  });

  exports.sendNotification = functions.pubsub.schedule('* * * * *').onRun((context) => {
    //check whether notification should be sent
    //send if yes
    return console.log('End of Function');
  });