import * as admin from "firebase-admin";
import * as functions from "firebase-functions/v1";

admin.initializeApp();
const db = admin.firestore();

exports.onFriendRequestCreated = functions.firestore
  .document("friendships/{requestId}")
  .onCreate(async (snapshot: functions.firestore.QueryDocumentSnapshot, context: functions.EventContext) => {
    const data = snapshot.data();
    if (!data) {
      functions.logger.error("Document data is undefined");
      return;
    }

    const senderRef = data.sender;
    const receiverRef = data.receiver;
    const status = data.status;

    if (!senderRef || !receiverRef || status !== "pending") {
      functions.logger.log("Invalid or already accepted request");
      return;
    }

    try {
      // Extract user IDs from document references
      const receiverId = receiverRef.id;
      const senderId = senderRef.id;

      // Get FCM token of receiver
      const receiverDoc = await db.collection("users").doc(receiverId).get();
      const fcmToken = receiverDoc.data()?.fcmToken;

      if (!fcmToken) {
        functions.logger.log(`No FCM token for user ${receiverId}`);
        return;
      }

      // Get sender info (optional, for name display)
      const senderDoc = await db.collection("users").doc(senderId).get();
      const senderName = senderDoc.data()?.name || "Jemand";

      // Send notification
      const payload: admin.messaging.Message = {
        token: fcmToken,
        notification: {
          title: "Neue Freundschaftsanfrage",
          body: `${senderName} möchte sich mit dir verbinden.`,
        },
        data: {
          type: "friend_request",
          from: senderId,
        },
      };

      await admin.messaging().send(payload);
      functions.logger.log(`Notification sent to ${receiverId}`);
    } catch (error) {
      functions.logger.error("Error handling friend request:", error);
    }
  });

exports.onFriendRequestAccepted = functions.firestore
  .document("friendships/{requestId}")
  .onUpdate(async (change: functions.Change<functions.firestore.QueryDocumentSnapshot>, context: functions.EventContext) => {
    const before = change.before.data();
    const after = change.after.data();

    if (!before || !after) {
      functions.logger.error("Missing before or after data");
      return;
    }

    const prevStatus = before.status;
    const newStatus = after.status;

    if (prevStatus === newStatus || newStatus !== "accepted") {
      return;
    }

    const senderRef = after.sender;
    const receiverRef = after.receiver;

    if (!senderRef || !receiverRef) {
      functions.logger.log("Missing sender or receiver");
      return;
    }

    try {
      const senderId = senderRef.id;
      const receiverId = receiverRef.id;

      // Get FCM token of sender
      const senderDoc = await db.collection("users").doc(senderId).get();
      const fcmToken = senderDoc.data()?.fcmToken;

      if (!fcmToken) {
        functions.logger.log(`No FCM token for sender ${senderId}`);
        return;
      }

      // Optional: get receiver name
      const receiverDoc = await db.collection("users").doc(receiverId).get();
      const receiverName = receiverDoc.data()?.name || "Ein Benutzer";

      const payload: admin.messaging.Message = {
        token: fcmToken,
        notification: {
          title: "Freundschaftsanfrage angenommen",
          body: `${receiverName} hat deine Anfrage akzeptiert.`,
        },
        data: {
          type: "friend_request_accepted",
          from: receiverId,
        },
      };

      await admin.messaging().send(payload);
      functions.logger.log(`Acceptance notification sent to ${senderId}`);
    } catch (error) {
      functions.logger.error("Error sending acceptance notification:", error);
    }
  });