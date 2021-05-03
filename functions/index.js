const functions = require("firebase-functions");
const admin = require('firebase-admin');
admin.initializeApp();
const database = admin.firestore();

// exports.timerUpdate = functions.pubsub.schedule('* * * * *').onRun((context) => {
//     database.doc("MyTodolist/05Qq9K7OVRETjrqK2eUH").update({"time":admin.firestore.Timestamp.now()})
//     return console.log('Successful time update');
//   });

  exports.sendNotification = functions.pubsub.schedule('* * * * *').onRun(async(context) => {
    //check whether notification should be sent
    //send if yes
    const query = await database.collection("notifications").where(
      "whenToNotify", '<=', admin.firestore.TimeStamp.now()).where(
      "notificationSent", '==', false).get();

    query.forEach(async snapshot => {
      sendNotification(snapshot.data().token);
      await database.doc('notifications'.snapshot.data().token).update({
        "notificationSent": true,
      });
    });

    function sendNotification(androidNotificationToken){
      let title = "Virtual Assistant";
      let body = "COmplete your tasks";

      const message = {
        notification : {title: title, body: body},
        token: androidNotificationToken,
        data: {click_action: 'FLUTTER_NOTIFICATION_CLICK'}
      };

      admin.message().send(message).then(response =>{
        return console.log("Successfully sent Message");
      }).catch(error =>{
        return console.log("Error sending Message");
      });
    }

    return console.log('End of Function');
  });