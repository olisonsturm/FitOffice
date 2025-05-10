const { onDocumentWritten } = require("firebase-functions/v2/firestore");
const { onRequest } = require("firebase-functions/v2/https");
const admin = require("firebase-admin");
admin.initializeApp();

exports.sendFriendRequestNotification = onDocumentWritten('friendships/{friendshipId}', async (event) => {
  const snap = event.data; // Dokument-Snapshot
  const data = snap.data();
  const senderRef = data.sender;
  const receiverRef = data.receiver;
  const status = data.status;

  if (status !== 'pending') return null;

  // Empfänger-Daten holen
  const receiverSnap = await receiverRef.get();
  const receiverData = receiverSnap.data();

  // FCM Token prüfen
  const fcmToken = receiverData.fcmToken;
  if (!fcmToken) return null;

  // Optional: Sender-Daten für Anzeige holen
  const senderSnap = await senderRef.get();
  const senderData = senderSnap.data();
  const senderName = senderData?.username ?? 'Ein Nutzer';

  // Nachricht senden
  const message = {
    token: fcmToken,
    notification: {
      title: 'Neue Freundschaftsanfrage',
      body: `${senderName} möchte sich mit dir verbinden.`,
    },
    data: {
      type: 'friend_request',
      senderUsername: senderName,
    }
  };

  await admin.messaging().send(message);
  return null;
});
