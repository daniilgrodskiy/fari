import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp({
  credential: admin.credential.applicationDefault(),
  databaseURL: "https://fari-16768.firebaseio.com",
});

const db = admin.firestore();
const fcm = admin.messaging();

// export const sendReminderToDevice = functions.firestore
//   .document("orders/{orderId}")
//   .onCreate(async (snapshot) => {
//     const order = snapshot.data();

//     const querySnapshot = await db
//       .collection("users")
//       .doc(order.seller)
//       .collection("tokens")
//       .get();

//     const tokens = querySnapshot.docs.map((snap) => snap.id);

//     const payload: admin.messaging.MessagingPayload = {
//       notification: {
//         title: "New Order!",
//         body: `you sold a ${order.product} for ${order.total}`,
//         icon: "your-icon-url",
//         click_action: "FLUTTER_NOTIFICATION_CLICK",
//       },
//     };

//     return fcm.sendToDevice(tokens, payload);
//   });

interface Workers {
  [key: string]: (options: any) => Promise<any>;
}

const workers: Workers = {
  helloWorld: () => db.collection("logs").add({ hello: "world" }),
  sendReminder: ({ token, taskId, taskName }) => {
    const payload: admin.messaging.MessagingPayload = {
      notification: {
        title: "⭐️ Your Fari task is due! ⭐️",
        body: `'${taskName}' is due. Click here to complete it. 🥳`,
        click_action: "FLUTTER_NOTIFICATION_CLICK",
      },
      data: {
        taskId,
      },
    };
    return fcm.sendToDevice(token, payload);
  },
};

export const sendReminderToDevices = functions.pubsub
  .schedule("* * * * *")
  .onRun(async (context) => {
    const now = admin.firestore.Timestamp.now();

    const query = db
      .collection("reminders")
      .where("performAt", "<=", now)
      .where("status", "==", "scheduled");

    const reminders = await query.get();

    // Jobs to execute concurrently
    const jobs: Promise<any>[] = [];

    // Loop over documents and push job
    reminders.forEach((snapshot) => {
      const { worker, options } = snapshot.data();

      // Run the function found in the 'workers' array above via 'workers[worker](options)' and then delete the reminder if it worked
      const job = workers[worker](options)
        .then(() => snapshot.ref.update({ status: "complete" }))
        .catch((err) => snapshot.ref.update({ status: "error" }));

      jobs.push(job);
    });

    return await Promise.all(jobs);
  });
