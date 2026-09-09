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
      // Skip only if the member looks freshly online (app in foreground).
      // Killed / crashed clients often still have isOnline=true.
      const lastSeen = data.lastSeen && typeof data.lastSeen.toMillis === "function"
        ? data.lastSeen.toMillis()
        : 0;
      const freshOnline =
        data.isOnline === true && lastSeen > 0 && Date.now() - lastSeen < 45000;
      if (freshOnline) return;
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
