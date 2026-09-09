const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");

initializeApp();

/**
 * Push channel: FCM (Firebase Cloud Messaging).
 * Sends a system notification when a text message is created.
 */
exports.onMessageCreated = onDocumentCreated(
  "rooms/{roomId}/messages/{messageId}",
  async (event) => {
    const snap = event.data;
    if (!snap) return;

    const message = snap.data();
    if (!message || message.type === "system") return;

    const roomId = event.params.roomId;
    const senderId = message.senderId;
    const senderName = message.senderName || "Someone";
    const body = message.body || "";
    const roomName = roomId === "general" ? "General" : roomId;

    const membersSnap = await getFirestore()
      .collection("rooms")
      .doc(roomId)
      .collection("members")
      .get();

    const tokens = [];
    membersSnap.forEach((doc) => {
      if (doc.id === senderId) return;
      const data = doc.data() || {};
      // Only notify members who are currently offline / backgrounded.
      if (data.isOnline === true) return;
      const list = Array.isArray(data.fcmTokens) ? data.fcmTokens : [];
      list.forEach((t) => {
        if (typeof t === "string" && t.length > 0) tokens.push(t);
      });
    });

    if (tokens.length === 0) return;

    const uniqueTokens = [...new Set(tokens)];
    await getMessaging().sendEachForMulticast({
      tokens: uniqueTokens,
      notification: {
        title: `${senderName} · ${roomName}`,
        body,
      },
      data: {
        roomId,
        roomName,
        senderName,
        body,
        route: "/chat",
      },
      android: {
        priority: "high",
      },
    });
  }
);
