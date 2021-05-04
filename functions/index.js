const functions = require("firebase-functions");
const admin = require('firebase-admin');


var serviceAccount = require("./mytodolist-dfbc3-firebase-adminsdk-h6yhf-5306ea4234.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://mytodolist-dfbc3-default-rtdb.firebaseio.com"
});
const database = admin.firestore();

  exports.sendNotifications = functions.pubsub.schedule('* * * * *').onRun(async(context) => {
    //check whether notification should be sent
    //send if yes
    functions.logger.info("Start ....");
    const query = await database.collection("notifications")
    .where("whenToNotify", '<=', admin.firestore.TimeStamp.now())
    .where("notificationSent", '==', false).get();

    functions.logger.info(query)

    query.forEach(async snapshot => {
      sendNotifications(snapshot.data().token);
      await database.doc('notifications/' + snapshot.data().token).update({
        "notificationSent": true,
      });
    });

    function sendNotifications(androidNotificationToken){
      let title = "Virtual Assistant";
      let body = "Complete your tasks";

      const message = {
        notification : {title: title, body: body},
        token: androidNotificationToken,
        data: {click_action: 'FLUTTER_NOTIFICATION_CLICK'}
      };

      admin.messaging().send(message).then(response =>{
        return console.log("Successfully sent Message");
      }).catch(error =>{
        return console.log("Error sending Message");
      });
    }

    return console.log('End of Function');
  });