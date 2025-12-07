import { onCall } from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

export const rejectItem = onCall(async (request) => {
  const itemId = request.data.itemId;

  if (!itemId) throw new Error("Missing itemId");

  await admin.firestore().collection("pending_items").doc(itemId).update({
    status: "rejected",
    reviewedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  return { success: true };
});
